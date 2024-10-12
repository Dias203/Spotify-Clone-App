import 'package:equatable/equatable.dart';

abstract class SongPlayerState extends Equatable {
  const SongPlayerState();

  @override
  List<Object?> get props => [];
}

class SongPlayerLoading extends SongPlayerState {}

class SongPlayerLoaded extends SongPlayerState {
  final Duration songPosition;
  final Duration songDuration;
  final bool isPlaying;

  const SongPlayerLoaded({
    required this.songPosition,
    required this.songDuration,
    required this.isPlaying,
  });

  @override
  List<Object?> get props => [songPosition, songDuration, isPlaying];
}

class SongPlayerFailure extends SongPlayerState {
  final String error;

  const SongPlayerFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
