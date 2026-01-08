


import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_mile/controllers/recent_song_controller.dart';
import 'package:sound_mile/model/extended_song_model.dart';
import 'package:sound_mile/util/color_category.dart';
import 'package:sound_mile/util/pref_data.dart';

final RecentSongController recentSongController =
Get.put(RecentSongController());

class PlayerController extends GetxController {
  static final PlayerController _instance = PlayerController._internal();

  factory PlayerController() => _instance;
  PlayerController._internal();

  final AudioPlayer audioPlayer = AudioPlayer();

  var isPlaying = false.obs;
  var currentIndex = 0.obs;
  var isShuffle = false.obs;
  var userInitiatedPlayback = false.obs;

  var loopMode = LoopMode.off.obs;
  var playList = <ExtendedSongModel>[].obs;
  var recentSongs = <ExtendedSongModel>[].obs;
  var allSongs = <ExtendedSongModel>[].obs;
  var favouriteSongsIds = <int>[].obs;
  var playingSong = Rx<ExtendedSongModel?>(null);
  var imageColor = Rx<Color?>(null);
  var secondColor = Rx<Color?>(null);

  List<AudioSource> songList = [];

  @override
  void onInit() {
    super.onInit();
    // loadLastPlayedSong(); // Load last played song before initializing listeners
    setupAudioSession();
    _initPlayerListener();
  }

  bool wasPlayingBeforeInterruption = false; // Track user intent

  Future<void> setupAudioSession() async {
    try {
      // 1. Get the shared audio session instance
      final session = await AudioSession.instance;

      // 2. Configure the session for music playback (important for Android/iOS)
      await session.configure(AudioSessionConfiguration.music());

      // 3. Handle the "becoming noisy" event (e.g., unplugging headphones)
      session.becomingNoisyEventStream.listen((_) {
        try {
          // Pause playback to avoid blasting sound from device speaker
          audioPlayer.pause();
        } catch (e, stack) {
          debugPrint('Error pausing on becoming noisy: $e\n$stack');
        }
      });

      // 4. Handle audio interruptions (e.g., phone call, another media app)
      session.interruptionEventStream.listen((event) async {
        try {
          if (event.begin) {
            // An interruption has started
            // Save whether the user was playing audio
            userInitiatedPlayback.value = audioPlayer.playing;

            // Pause playback during the interruption
            await audioPlayer.pause();
          } else {
            // The interruption has ended
            if (userInitiatedPlayback.value && !audioPlayer.playing) {
              // If the user had initiated playback before interruption
              // and playback is not currently active...

              // Reactivate the session
              await session.setActive(true);

              // Resume playback
              audioPlayer.play();
            }
          }
        } catch (e, stack) {
          debugPrint('Error handling interruption: $e\n$stack');
        }
      });
    } catch (e, stack) {
      debugPrint('Error setting up audio session: $e\n$stack');
    }
  }

  // Future<void> setupAudioSession() async {
  //   try {
  //     final session = await AudioSession.instance;
  //     await session.configure(AudioSessionConfiguration.music());

  //     // Handle unplugged headphones
  //     session.becomingNoisyEventStream.listen((_) {
  //       try {
  //         audioPlayer.pause();
  //       } catch (e, stack) {
  //         debugPrint('Error pausing on becoming noisy: $e\n$stack');
  //       }
  //     });

  //     // Handle interruptions (phone calls, Instagram, etc.)
  //     session.interruptionEventStream.listen((event) async {
  //       try {
  //         if (event.begin) {
  //           userInitiatedPlayback.value = audioPlayer.playing;
  //           await audioPlayer.pause();
  //         } else {
  //           if (userInitiatedPlayback.value && !audioPlayer.playing) {
  //             await session.setActive(true); // Important to restore session
  //             await audioPlayer.play();
  //           }
  //         }
  //       } catch (e, stack) {
  //         debugPrint('Error handling interruption: $e\n$stack');
  //       }
  //     });
  //   } catch (e, stack) {
  //     debugPrint('Error setting up audio session: $e\n$stack');
  //   }
  // }

  void restoreMediaSessionIfNeeded() {
    // If audioPlayer is not playing but should be, or notification is missing, restore it
    if (playingSong.value != null && !audioPlayer.playing && isPlaying.value) {
// Optionally re-set the audio source and update notification
// Example: In your play button handler
      userInitiatedPlayback.value = true;

      audioPlayer.play();
    }
    // Optionally call just_audio_background or audio_service methods to update notification
  }

  void saveLastPlayedSong(List<ExtendedSongModel> songs) async {
    try {
      final songIds = songs
      // ignore: unnecessary_null_comparison
          .where((song) => song.id != null)
          .map((song) => song.id)
          .toList();

      if (songIds.isNotEmpty) {
        await prefData.saveRecentPlayedSongIds(songIds);
      } else {
        debugPrint('No valid song IDs to save.');
      }
    } catch (e, stack) {
      debugPrint('Error saving last played songs: $e\n$stack');
    }
  }

  // Fetch artwork bytes directly
  Future<Uint8List?> _getArtwork(int? songId) async {
    if (songId == null) return null;

    try {
      final artwork =
      await OnAudioQuery().queryArtwork(songId, ArtworkType.AUDIO);
      return artwork;
    } catch (e, stack) {
      debugPrint('Error fetching artwork for songId $songId: $e\n$stack');
      return null;
    }
  }

// Extract dominant color from image bytes
  Future<Color> _getImageDominantColor(Uint8List imageData) async {
    try {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        MemoryImage(imageData),
        size: const Size(200, 200), // Optimize speed by limiting image size
        maximumColorCount: 10, // Optimize speed by limiting color count
      );
      return paletteGenerator.dominantColor?.color ?? bg;
    } catch (e, stack) {
      debugPrint('Error extracting dominant color: $e\n$stack');
      return bg;
    }
  }

  Future<Color> _getImageSecondColor(Uint8List imageData) async {
    try {
      final PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(
        MemoryImage(imageData),
        size: const Size(200, 200), // Optimize speed by limiting image size
        maximumColorCount: 10, // Optimize speed by limiting color count
      );
      return paletteGenerator.lightMutedColor?.color ?? accentColor;
    } catch (e, stack) {
      debugPrint('Error extracting second color: $e\n$stack');
      return accentColor;
    }
  }

// Combined method to get dominant color for the current song
  Future<void> updateDominantColor() async {
    final Uint8List? imageData = await _getArtwork(playingSong.value?.id);
    if (imageData != null) {
      imageColor.value = await _getImageDominantColor(imageData);
      var secondImageColor = await _getImageSecondColor(imageData);
      secondColor.value = secondImageColor.withOpacity(0.5);
    } else {
      imageColor.value = bg;
    }
  }

  Future<void> loadLastPlayedSong() async {
    try {
      // Load saved song IDs
      List<int> lastPlayedSongIds = await prefData.loadRecentPlayedSongIds();

      // Filter valid songs by ID
      List<ExtendedSongModel> matchedSongs = allSongs
          .where((song) => lastPlayedSongIds.contains(song.id))
          .toList();

      if (matchedSongs.isNotEmpty) {
        playingSong.value = matchedSongs.first;

        // Build audio sources
        final sources = matchedSongs.map((song) {
          return AudioSource.uri(
            Uri.parse(song.uri!),
            tag: MediaItem(
              id: song.id.toString(),
              album: song.album ?? "Unknown Album",
              title: song.displayNameWOExt,
              artUri: song.artworkUri,
            ),
          );
        }).toList();

        songList
          ..clear()
          ..addAll(sources);

        // Set audio player source
        await audioPlayer.setAudioSource(
          ConcatenatingAudioSource(children: sources),
          initialIndex: 0,
        );

        // Update current index
        currentIndex.value =
            playList.indexWhere((song) => song.id == matchedSongs.first.id);
      }
    } catch (e, stack) {
      debugPrint("Failed to load last played song: $e\n$stack");
    }
  }

  void _initPlayerListener() {
    // Listen to track changes
    audioPlayer.currentIndexStream.listen((index) {
      try {
        if (index != null && index >= 0 && index < playList.length) {
          currentIndex.value = index;
          playingSong.value = playList[index];

          // Update UI colors based on current song
          updateDominantColor();

          // Save to recent songs
          Get.find<RecentSongController>().addSongToRecent(playList[index]);
        }
      } catch (e, stack) {
        debugPrint("Error in currentIndexStream: $e\n$stack");
      }
    });

    // Listen to player state changes
    audioPlayer.playerStateStream.listen((state) async {
      try {
        if (state.processingState == ProcessingState.completed) {
          final noNext = !audioPlayer.hasNext;
          final loopingDisabled = loopMode.value == LoopMode.off;

          if (noNext && loopingDisabled) {
            isPlaying.value = false;

            // Optional: You can check if index 0 is safe before seeking
            if (playList.isNotEmpty) {
              await audioPlayer.seek(Duration.zero, index: 0);
            }

            await audioPlayer.stop();
          }
        }
      } catch (e, stack) {
        debugPrint("Error in playerStateStream: $e\n$stack");
      }
    });
  }

  // Future<List<ExtendedSongModel>> fetchSongs() async {
  //   try {
  //     // Fetch songs from the device
  //     List<SongModel> fetchedSongs = await OnAudioQuery().querySongs(
  //       ignoreCase: true,
  //       orderType: OrderType.ASC_OR_SMALLER,
  //       uriType: UriType.EXTERNAL,
  //     );

  //     // Use a Map to ensure uniqueness based on song ID

  //     final uniqueSongs = <int, ExtendedSongModel>{};

  //     for (var song in fetchedSongs) {
  //       String? artworkUri = await fetchArtworkUri(song.id);
  //       ExtendedSongModel extendedSong = ExtendedSongModel.fromSongModel(
  //         song,
  //         artworkUri != null ? Uri.parse(artworkUri) : null,
  //       );

  //       // Add to the map, using the song ID as the key
  //       uniqueSongs[song.id] = extendedSong;
  //     }

  //     // Update the allSongs list with unique songs
  //     allSongs.value = uniqueSongs.values.toList();

  //     // Update recent songs
  //     await getRecent(allSongs);
  //     // get recent Played songs
  //     await recentSongController.loadRecentPlayedSongs();

  //     return allSongs;
  //   } catch (e) {
  //     return [];
  //   }
  // }
  // Future<List<ExtendedSongModel>> fetchSongs() async {
  //   try {
  //     // Fetch songs from the device
  //     List<SongModel> fetchedSongs = await OnAudioQuery().querySongs(
  //       ignoreCase: true,
  //       orderType: OrderType.ASC_OR_SMALLER,
  //       uriType: UriType.EXTERNAL,
  //     );

  //     // Use a Map to ensure uniqueness based on song ID
  //     final uniqueSongs = <int, ExtendedSongModel>{};

  //     for (var song in fetchedSongs) {
  //       // Do NOT fetch artwork here
  //       ExtendedSongModel extendedSong = ExtendedSongModel.fromSongModel(
  //         song,
  //         null, // No artwork URI yet
  //       );
  //       uniqueSongs[song.id] = extendedSong;
  //     }

  //     allSongs.value = uniqueSongs.values.toList();

  //     await getRecent(allSongs);
  //     await recentSongController.loadRecentPlayedSongs();

  //     return allSongs;
  //   } catch (e) {
  //     return [];
  //   }
  // }
  Future<List<ExtendedSongModel>> fetchSongs() async {
    try {
      // Step 1: Fetch songs from device storage
      List<SongModel> fetchedSongs = await OnAudioQuery().querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
      );

      // Step 2: Create a list of futures to fetch artwork in parallel
      List<Future<ExtendedSongModel>> futures = fetchedSongs.map((song) async {
        String? artworkUri = await fetchArtworkUri(song.id);

        return ExtendedSongModel.fromSongModel(
          song,
          artworkUri != null ? Uri.parse(artworkUri) : null,
        );
      }).toList();

      // Step 3: Wait for all futures to complete in parallel
      List<ExtendedSongModel> extendedSongs = await Future.wait(futures);

      // Step 4: Use a map to ensure uniqueness based on song ID
      final uniqueSongs = <int, ExtendedSongModel>{};
      for (var song in extendedSongs) {
        uniqueSongs[song.id] = song;
      }

      // Step 5: Assign the unique list to your observable/list
      allSongs.value = uniqueSongs.values.toList();

      // Step 6: Optionally trigger additional async updates without blocking the main fetch
      unawaited(getRecent(allSongs));
      unawaited(recentSongController.loadRecentPlayedSongs());

      // Step 7: Return the result
      return allSongs;
    } catch (e) {
      return [];
    }
  }

  Future<List<ExtendedSongModel>> getRecent(
      List<ExtendedSongModel> allSongs) async {
    // Use a Set to filter out duplicates based on a unique property
    final uniqueSongs = <String, ExtendedSongModel>{};

    for (var song in allSongs) {
      uniqueSongs[song.uri.toString()] =
          song; // Assuming 'uri' is a unique property
    }

    recentSongs.value = uniqueSongs.values.toList()
      ..sort((a, b) => b.dateModified!.compareTo(a.dateModified!));

    return recentSongs;
  }

  Future<String?> fetchArtworkUri(int songId) async {
    final Uint8List? artwork = await OnAudioQuery().queryArtwork(
      songId,
      ArtworkType.AUDIO,
    );

    if (artwork != null) {
      final tempDir = await getTemporaryDirectory();
      final file =
      await File('${tempDir.path}/$songId.jpg').writeAsBytes(artwork);
      return file.uri.toString();
    }
    return null;
  }

  Future<void> setPlaylistAndPlaySong(
      List<ExtendedSongModel> songs, int index) async {
    try {
      songList.clear();
      playList.value = songs;

      for (var song in songs) {
        // Provide a default artwork URI if song.artworkUri is null
        final artUri = song.artworkUri ??
            Uri.parse(
                'https://raw.githubusercontent.com/flutter/website/master/src/assets/images/dash/dash-fainting.gif');
        songList.add(AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? "Unknown Album",
            title: song.displayNameWOExt,
            artUri: artUri,
          ),
        ));
        // RecentSongController().trackSongProgress();
      }

      await audioPlayer.setAudioSource(
        ConcatenatingAudioSource(children: songList),
        initialIndex: index,
      );
      isPlaying.value = true;

      currentIndex.value = index;
      playingSong.value = playList[index];

      await audioPlayer.play();
      // Add the current song to
      await recentSongController.addSongToRecent(playingSong.value!);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> updatePlaylistOrder(
      List<ExtendedSongModel> reorderedSongs) async {
    try {
      if (playList.isEmpty || audioPlayer.audioSource == null) return;

      final currentSong = playingSong.value;
      final currentAudioSource =
      audioPlayer.audioSource as ConcatenatingAudioSource;

      // Get original list of URIs to track reordering
      final originalUris = playList.map((e) => e.uri!).toList();

      for (int newIndex = 0; newIndex < reorderedSongs.length; newIndex++) {
        final newUri = reorderedSongs[newIndex].uri!;
        final oldIndex = originalUris.indexOf(newUri);

        // If the song has moved position, update in audio player source
        if (oldIndex != -1 && oldIndex != newIndex) {
          await currentAudioSource.move(oldIndex, newIndex);
          final moved = originalUris.removeAt(oldIndex);
          originalUris.insert(newIndex, moved);
        }
      }

      // Update internal playlist reference
      playList.value = reorderedSongs;

      // Find new index of the currently playing song
      final newCurrentIndex =
      reorderedSongs.indexWhere((s) => s.uri == currentSong?.uri);

      if (newCurrentIndex != -1 && newCurrentIndex != currentIndex.value) {
        // Only seek if the current song's index changed
        currentIndex.value = newCurrentIndex;
        playingSong.value = reorderedSongs[newCurrentIndex];
        await audioPlayer.seek(audioPlayer.position, index: newCurrentIndex);
      } else if (newCurrentIndex != -1) {
        // Just update state silently if same index
        currentIndex.value = newCurrentIndex;
        playingSong.value = reorderedSongs[newCurrentIndex];
      }
    } catch (e) {}
  }

  void togglePlayPause() async {
    if (audioPlayer.playing) {
      isPlaying.value = false;
      await audioPlayer.pause();
    } else {
      if (audioPlayer.currentIndex == null) {
        // Try to set audio source again if not set
        if (playList.isNotEmpty) {
          setPlaylistAndPlaySong(playList, currentIndex.value);
        }
      } else {
        isPlaying.value = true;
        await audioPlayer.play();
      }
    }
  }

  void toggleShuffleMode() {
    isShuffle.value = !isShuffle.value;
    audioPlayer.setShuffleModeEnabled(isShuffle.value);
  }

  void toggleLoopMode() {
    loopMode.value =
    LoopMode.values[(loopMode.value.index + 1) % LoopMode.values.length];
    audioPlayer.setLoopMode(loopMode.value);
  }

  Future<void> playNextSong() async {
    // if the Loop mode ==1
    if (loopMode.value == LoopMode.one) {
      if (audioPlayer.hasNext) {
        // checking id there is a next song on the playlist
        await audioPlayer.seek(Duration.zero,
            index: (audioPlayer.currentIndex! + 1));
      } else {
        await audioPlayer.seek(Duration.zero, index: 0);
      }
    } else {
      await audioPlayer.seekToNext();
    }
  }

  Future<void> playPreviousSong() async {
    // if the Loop mode ==1
    if (loopMode.value == LoopMode.one) {
      if (audioPlayer.hasPrevious) {
        // checking id there is a prev song on the playlist
        await audioPlayer.seek(Duration.zero,
            index: audioPlayer.currentIndex! - 1);
      } else {
        await audioPlayer.seek(Duration.zero, index: songList.length - 1);
      }
    } else {
      await audioPlayer.seekToPrevious();
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}