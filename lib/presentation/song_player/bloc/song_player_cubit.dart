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
            playOrPause(); // Tự động phát bài hát khi tải thành công
        } catch (e) {
            emit(SongPlayerFailure(error: e.toString()));
        }
    }

    void playOrPause() {
        if (audioPlayer.position >= (audioPlayer.duration ?? Duration.zero)) {
            // Nếu bài hát đã kết thúc, phát lại từ đầu
            audioPlayer.seek(Duration.zero);
        }

        if (audioPlayer.playing) {
            audioPlayer.stop();
        } else {
            audioPlayer.play();
        }
        // Trạng thái sẽ được cập nhật qua lắng nghe playerStateStream
    }

    Future<void> seek(Duration position) async {
        await audioPlayer.seek(position);
        // Trạng thái sẽ được cập nhật qua lắng nghe positionStream
    }

    @override
    Future<void> close() {
        audioPlayer.dispose();
        return super.close();
    }
}
