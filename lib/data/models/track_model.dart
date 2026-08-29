class Track {
  final String id;
  final String name;
  final int duration; // in seconds
  final String artistName;
  final String albumName;
  final String image;
  final String audioUrl;
  final String? releaseDate;

  Track({
    required this.id,
    required this.name,
    required this.duration,
    required this.artistName,
    required this.albumName,
    required this.image,
    required this.audioUrl,
    this.releaseDate,
  });

  /// Factory constructor to parse track from Jamendo API JSON response
  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id']?.toString() ?? '',
      name: (json['name'] != null && json['name'].toString().isNotEmpty)
          ? json['name'].toString()
          : 'Unknown Track',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      artistName: (json['artist_name'] != null && json['artist_name'].toString().isNotEmpty)
          ? json['artist_name'].toString()
          : 'Unknown Artist',
      albumName: json['album_name']?.toString() ?? 'Single',
      // Jamendo returns 'image' or 'album_image'
      image: (json['image'] != null && json['image'].toString().isNotEmpty)
          ? json['image'].toString()
          : (json['album_image'] != null && json['album_image'].toString().isNotEmpty)
              ? json['album_image'].toString()
              : '',
      audioUrl: json['audio']?.toString() ?? '',
      releaseDate: json['releasedate']?.toString(),
    );
  }

  /// Convert track instance to JSON map for local caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'artist_name': artistName,
      'album_name': albumName,
      'image': image,
      'audio': audioUrl,
      'releasedate': releaseDate,
    };
  }

  /// Formatted duration string e.g. "03:45"
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final remainingSeconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Track && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
