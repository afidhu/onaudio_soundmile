import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  MyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // 1️⃣ ADD MEDIA ITEM (REQUIRED FOR NOTIFICATION)
    final mediaItemData = MediaItem(
      id: 'song_1',
      title: 'My Song',
      artist: 'My Artist',
      album: 'My Album',
      duration: const Duration(minutes: 4),
      artUri: Uri.parse(
        'https://via.placeholder.com/300',
      ),
    );

    mediaItem.add(mediaItemData);

    // 2️⃣ Set audio source
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse("https://www.example.com/song.mp3"),
        ),
      );
    } catch (e) {
      print("Error loading audio source: $e");
    }

    // 3️⃣ Broadcast playback state
    _player.playbackEventStream.listen((event) {
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            MediaControl.pause,
            MediaControl.play,
            MediaControl.stop,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          playing: _player.playing,
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
        ),
      );
    });
  }


  @override
  Future<void> play() async => _player.play();

  @override
  Future<void> pause() async => _player.pause();

  @override
  Future<void> stop() async => _player.stop();

  @override
  Future<void> seek(Duration position) async => _player.seek(position);
}
