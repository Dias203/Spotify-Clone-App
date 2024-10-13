import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_state.dart';

// class SongPlayerCubit extends Cubit<SongPlayerState> {
//     final AudioPlayer audioPlayer = AudioPlayer();

//     SongPlayerCubit() : super(SongPlayerLoading()) {
//         // Lắng nghe sự thay đổi vị trí bài hát
//         audioPlayer.positionStream.listen((position) {
//             _emitLoadedState();
//         });

//         // Lắng nghe sự thay đổi tổng thời lượng bài hát
//         audioPlayer.durationStream.listen((duration) {
//             _emitLoadedState();
//         });

//         // Lắng nghe trạng thái phát/tạm dừng
//         audioPlayer.playerStateStream.listen((playerState) {
//             _emitLoadedState();
//         });
//     }

//     void _emitLoadedState() {
//         emit(SongPlayerLoaded(
//             songPosition: audioPlayer.position,
//             songDuration: audioPlayer.duration ?? Duration.zero,
//             isPlaying: audioPlayer.playing,
//         ));
//     }

//     Future<void> loadSong(String url) async {
//         emit(SongPlayerLoading());
//         try {
//             await audioPlayer.setUrl(url);
//             _emitLoadedState();
//             playOrPause(); // Tự động phát bài hát khi tải thành công
//         } catch (e) {
//             emit(SongPlayerFailure(error: e.toString()));
//         }
//     }

//     void playOrPause() {
//         if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
//             // Nếu bài hát đã kết thúc, phát lại từ đầu
//             audioPlayer.seek(Duration.zero);
//         }

//         if (audioPlayer.playing) {
//             audioPlayer.stop();
//         } else {
//             audioPlayer.play();
//         }
//         // Trạng thái sẽ được cập nhật qua lắng nghe playerStateStream
//     }

//     Future<void> seek(Duration position) async {
//         await audioPlayer.seek(position);
//         // Trạng thái sẽ được cập nhật qua lắng nghe positionStream
//     }

//     @override
//     Future<void> close() {
//         audioPlayer.dispose();
//         return super.close();
//     }
// }

// song_player_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_state.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';
import 'package:spotify_clone/core/configs/constants/app_urls.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final List<SongEntity> playlist;
  int currentIndex = 0;

  SongPlayerCubit({required this.playlist}) : super(SongPlayerLoading()) {
    if (playlist.isNotEmpty) {
      loadSongAtIndex(currentIndex);
    }

    // Lắng nghe sự thay đổi vị trí bài hát
    audioPlayer.positionStream.listen((position) {
      _emitLoadedState();
    });

    // Lắng nghe sự thay đổi tổng thời lượng bài hát
    audioPlayer.durationStream.listen((duration) {
      _emitLoadedState();
    });

    // Lắng nghe trạng thái phát/tạm dừng
    audioPlayer.playerStateStream.listen((playerState) {
      _emitLoadedState();

      // Kiểm tra nếu bài hát đã kết thúc
      if (playerState.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  void _emitLoadedState() {
    if (playlist.isEmpty) return;

    final currentSong = playlist[currentIndex];
    final position = audioPlayer.position;
    final duration = audioPlayer.duration ?? Duration.zero;
    final isPlaying = audioPlayer.playing;

    emit(SongPlayerLoaded(
      currentSong: currentSong,
      songPosition: position,
      songDuration: duration,
      isPlaying: isPlaying,
    ));
  }

  Future<void> loadSongAtIndex(int index) async {
    if (index < 0 || index >= playlist.length) {
      // Optionally, handle index out of bounds
      return;
    }

    currentIndex = index;
    emit(SongPlayerLoading());

    try {
      final currentSong = playlist[currentIndex];
      final url =
          '${AppURLs.songFirestorage}${currentSong.artist} - ${currentSong.title}.mp3?${AppURLs.mediaAlt}';
      await audioPlayer.setUrl(url);
      audioPlayer.play(); // Optionally auto-play
      _emitLoadedState();
    } catch (e) {
      emit(SongPlayerFailure(error: e.toString()));
    }
  }

  void playOrPause() {
    if (playlist.isEmpty) return;

    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      // Nếu bài hát đã kết thúc, tua lại từ đầu trước khi phát
      if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
        audioPlayer.seek(Duration.zero);
      }
      audioPlayer.play();
    }
    // Trạng thái sẽ được cập nhật tự động thông qua các stream lắng nghe
  }

  Future<void> seek(Duration position) async {
    if (playlist.isEmpty) return;

    await audioPlayer.seek(position);
    // Trạng thái sẽ được cập nhật tự động thông qua các stream lắng nghe
  }

  void playNext() {
    if (playlist.isEmpty) return;

    if (currentIndex < playlist.length - 1) {
      loadSongAtIndex(currentIndex + 1);
    } else {
      // Tùy chọn: Lặp lại từ đầu playlist
      loadSongAtIndex(0);
    }
  }

  void playPrevious() {
    if (playlist.isEmpty) return;

    if (audioPlayer.position > Duration(seconds: 3)) {
      // Nếu vị trí hiện tại > 3 giây, tua lại đầu bài hát
      audioPlayer.seek(Duration.zero);
    } else {
      if (currentIndex > 0) {
        loadSongAtIndex(currentIndex - 1);
      } else {
        // Tùy chọn: Lặp lại từ cuối playlist
        loadSongAtIndex(playlist.length - 1);
      }
    }
  }

  SongEntity? findSongByUrl(String url) {
    for (var song in playlist) {
      if (url ==
          '${AppURLs.songFirestorage}${song.artist} - ${song.title}.mp3?${AppURLs.mediaAlt}') {
        return song;
      }
    }
    return null;
  }

  Future<void> loadSongByUrl(String url) async {
    final song = findSongByUrl(url);
    if (song != null) {
      final index = playlist.indexOf(song);
      loadSongAtIndex(index);
    } else {
      emit(SongPlayerFailure(error: 'Song not found'));
    }
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
