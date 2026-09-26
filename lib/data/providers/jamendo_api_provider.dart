import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/track_model.dart';

class JamendoApiException implements Exception {
  final String message;
  JamendoApiException(this.message);

  @override
  String toString() => message;
}

class JamendoApiProvider {
  final http.Client _httpClient;

  JamendoApiProvider({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  /// Fetch list of tracks from Jamendo with pagination (limit & offset)
  Future<List<Track>> getTracks({
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tracksEndpoint}/'
      '?client_id=${ApiConstants.clientId}'
      '&format=${ApiConstants.formatJson}'
      '&limit=$limit'
      '&offset=$offset'
      '&include=musicinfo',
    );

    return _fetchTracksFromUri(uri);
  }

  /// Search tracks by name/keyword with pagination
  Future<List<Track>> searchTracks({
    required String query,
    int limit = ApiConstants.defaultLimit,
    int offset = 0,
  }) async {
    final encodedQuery = Uri.encodeComponent(query.trim());
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.tracksEndpoint}/'
      '?client_id=${ApiConstants.clientId}'
      '&format=${ApiConstants.formatJson}'
      '&namesearch=$encodedQuery'
      '&limit=$limit'
      '&offset=$offset'
      '&include=musicinfo',
    );

    return _fetchTracksFromUri(uri);
  }

  /// Internal helper to execute HTTP request and parse response
  Future<List<Track>> _fetchTracksFromUri(Uri uri) async {
    try {
      final response = await _httpClient
          .get(uri)
          .timeout(ApiConstants.timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final headers = body['headers'];

        if (headers != null && headers['status'] == 'success') {
          final List<dynamic> results = body['results'] ?? [];
          return results.map((json) => Track.fromJson(json)).toList();
        } else {
          final errorMsg =
              headers?['error_message'] ?? 'Failed to fetch tracks';
          throw JamendoApiException('API Error: $errorMsg');
        }
      } else {
        throw JamendoApiException(
          'Server responded with status code: ${response.statusCode}',
        );
      }
    } on TimeoutException {
      throw JamendoApiException(
        'Connection timed out. Please check your internet connection.',
      );
    } on SocketException {
      throw JamendoApiException(
        'No internet connection. Please check your network.',
      );
    } on http.ClientException {
      throw JamendoApiException('Network error occurred. Please try again.');
    } on FormatException {
      throw JamendoApiException('Invalid data format received from server.');
    } catch (e) {
      if (e is JamendoApiException) rethrow;
      throw JamendoApiException(
        'An unexpected error occurred: ${e.toString()}',
      );
    }
  }
}
