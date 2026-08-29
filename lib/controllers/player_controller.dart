import 'dart:async';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../data/models/track_model.dart';

class PlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Observable state properties
  final Rxn<Track> currentTrack = Rxn<Track>();
  final RxList<Track> playlist = <Track>[].obs;
  final RxInt currentIndex = (-1).obs;

  final RxBool isPlaying = false.obs;
  final RxBool isLoadingAudio = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> bufferedPosition = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;

  final RxBool isShuffleMode = false.obs;
  final RxBool isRepeatMode = false.obs;

  // Stream Subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;

  @override
  void onInit() {
    super.onInit();
    _initAudioStreams();
  }

  void _initAudioStreams() {
    // Listen to player state (playing, buffering, completed)
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      final processingState = state.processingState;

      if (processingState == ProcessingState.buffering ||
          processingState == ProcessingState.loading) {
        isLoadingAudio.value = true;
      } else {
        isLoadingAudio.value = false;
      }

      // Auto-play next track when current track ends
      if (processingState == ProcessingState.completed) {
        onTrackCompleted();
      }
    });

    // Listen to position updates
    _positionSubscription = _audioPlayer.positionStream.listen((pos) {
      position.value = pos;
    });

    // Listen to buffered position updates
    _bufferedPositionSubscription =
        _audioPlayer.bufferedPositionStream.listen((buffered) {
      bufferedPosition.value = buffered;
    });

    // Listen to track duration updates
    _durationSubscription = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        duration.value = dur;
      }
    });
  }

  /// Play a specific track and optionally set a playlist queue
  Future<void> playTrack(Track track, {List<Track>? newPlaylist}) async {
    try {
      if (newPlaylist != null && newPlaylist.isNotEmpty) {
        playlist.assignAll(newPlaylist);
        currentIndex.value = playlist.indexWhere((t) => t.id == track.id);
      }

      currentTrack.value = track;
      duration.value = Duration(seconds: track.duration);
      position.value = Duration.zero;
      isLoadingAudio.value = true;

      // Stop previous playback and load new URL
      await _audioPlayer.stop();
      await _audioPlayer.setUrl(track.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      isLoadingAudio.value = false;
      Get.snackbar(
        'Playback Error',
        'Unable to play track: ${track.name}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Toggle play / pause state
  Future<void> togglePlayPause() async {
    if (currentTrack.value == null) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  /// Play next song in queue
  Future<void> playNext() async {
    if (playlist.isEmpty) return;

    if (isShuffleMode.value) {
      playlist.shuffle();
    }

    if (currentIndex.value < playlist.length - 1) {
      currentIndex.value++;
    } else {
      // Loop back to beginning of queue
      currentIndex.value = 0;
    }

    await playTrack(playlist[currentIndex.value]);
  }

  /// Play previous song in queue
  Future<void> playPrevious() async {
    if (playlist.isEmpty) return;

    // If current song is played for more than 3 seconds, restart it
    if (position.value.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      currentIndex.value = playlist.length - 1;
    }

    await playTrack(playlist[currentIndex.value]);
  }

  /// Seek to custom position
  Future<void> seek(Duration newPosition) async {
    await _audioPlayer.seek(newPosition);
  }

  /// Handle track completion
  void onTrackCompleted() {
    if (isRepeatMode.value) {
      seek(Duration.zero);
      _audioPlayer.play();
    } else {
      playNext();
    }
  }

  /// Toggle Shuffle mode
  void toggleShuffle() {
    isShuffleMode.value = !isShuffleMode.value;
  }

  /// Toggle Repeat mode
  void toggleRepeat() {
    isRepeatMode.value = !isRepeatMode.value;
  }

  @override
  void onClose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _bufferedPositionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.onClose();
  }
}
