import 'package:equatable/equatable.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';

abstract class SongPlayerState extends Equatable {
  const SongPlayerState();

  @override
  List<Object> get props => [];
}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final SongEntity currentSong;
  final Duration songPosition;
  final Duration songDuration;
  final bool isPlaying;

  const SongPlayerLoaded({
    required this.currentSong,
    required this.songPosition,
    required this.songDuration,
    required this.isPlaying,
  });

  @override
  List<Object> get props => [currentSong, songPosition, songDuration, isPlaying];
}

class SongPlayerFailure extends SongPlayerState {
  final String error;

  const SongPlayerFailure({required this.error});

  @override
  List<Object> get props => [error];
}
