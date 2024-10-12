// song_player_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_clone/core/configs/constants/app_urls.dart';
import 'package:spotify_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';
import 'package:spotify_clone/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_clone/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerPage extends StatefulWidget {
  final List<SongEntity> playlist;
  final int initialIndex;

  const SongPlayerPage({
    required this.playlist,
    this.initialIndex = 0,
    super.key,
    required SongEntity songEntity,
  });

  @override
  _SongPlayerPageState createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  double _sliderValue = 0.0;
  bool _isSeeking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 18),
        ),
        action: IconButton(
          onPressed: () {
          },
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: BlocProvider(
        create: (_) => SongPlayerCubit(playlist: widget.playlist)
          ..loadSongAtIndex(widget.initialIndex),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              _songCover(context),
              const SizedBox(
                height: 20,
              ),
              _songDetail(),
              const SizedBox(
                height: 30,
              ),
              _songPlayer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _songCover(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoaded) {
          return Container(
            height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(
                  '${AppURLs.coverFirestorage}${state.currentSong.artist} - ${state.currentSong.title}.jpg?${AppURLs.mediaAlt}',
                ),
              ),
            ),
          );
        }
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          color: Colors.grey,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _songDetail() {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoaded) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.currentSong.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    state.currentSong.artist,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  // Xử lý sự kiện khi nhấn vào nút yêu thích
                },
                icon: const Icon(
                  Icons.favorite_outline_outlined,
                  size: 35,
                  color: AppColors.darkGrey,
                ),
              )
            ],
          );
        }
        return Container();
      },
    );
  }

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoading) {
          return const CircularProgressIndicator();
        }
        if (state is SongPlayerLoaded) {
          // Nếu đang kéo thanh trượt, sử dụng giá trị từ biến cục bộ
          double currentPosition = _isSeeking
              ? _sliderValue
              : state.songPosition.inMilliseconds.toDouble();
          double totalDuration = state.songDuration.inMilliseconds.toDouble();

          return Column(
            children: [
              Slider(
                value: currentPosition.clamp(0.0, totalDuration),
                min: 0.0,
                max: totalDuration > 0 ? totalDuration : 1.0, // Tránh max = 0
                onChanged: (value) {
                  setState(() {
                    _isSeeking = true;
                    _sliderValue = value;
                  });
                },
                onChangeEnd: (value) {
                  context.read<SongPlayerCubit>().seek(
                        Duration(milliseconds: value.toInt()),
                      );
                  setState(() {
                    _isSeeking = false;
                  });
                },
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(
                      Duration(milliseconds: currentPosition.toInt()))),
                  Text(formatDuration(state.songDuration)),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_previous),
                    onPressed: () {
                      context.read<SongPlayerCubit>().playPrevious();
                    },
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      context.read<SongPlayerCubit>().playOrPause();
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.skip_next),
                    onPressed: () {
                      context.read<SongPlayerCubit>().playNext();
                    },
                  ),
                ],
              )
            ],
          );
        }
        if (state is SongPlayerFailure) {
          return Text('Error: ${state.error}');
        }
        return Container();
      },
    );
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
