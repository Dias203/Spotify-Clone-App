// song_player_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'song_player_state.dart';

class SongPlayerCubit extends Cubit<SongPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();

  SongPlayerCubit() : super(SongPlayerLoading()) {
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
        // Khi bài hát hoàn thành, đặt vị trí về đầu
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
        _emitLoadedState();
      }
    });
  }

  void _emitLoadedState() {
    emit(SongPlayerLoaded(
      songPosition: audioPlayer.position,
      songDuration: audioPlayer.duration ?? Duration.zero,
      isPlaying: audioPlayer.playing,
    ));
  }

  Future<void> loadSong(String url) async {
    emit(SongPlayerLoading());
    try {
      await audioPlayer.setUrl(url);
      _emitLoadedState();
      playOrPause();
    } catch (e) {
      emit(SongPlayerFailure(error: e.toString()));
    }
  }

  void playOrPause() {
    if (audioPlayer.playing) {
      audioPlayer.stop();
    } else {
      // Kiểm tra nếu bài hát đã kết thúc
      if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
        audioPlayer.seek(Duration.zero);
      }
      audioPlayer.play();
    }
    // Trạng thái sẽ được cập nhật tự động thông qua các stream lắng nghe
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
    // Trạng thái sẽ được cập nhật tự động thông qua các stream lắng nghe
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
