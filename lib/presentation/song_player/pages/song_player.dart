import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/common/widgets/appbar/app_bar.dart';
import 'package:spotify_clone/core/configs/constants/app_urls.dart';
import 'package:spotify_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';
import 'package:spotify_clone/presentation/song_player/bloc/song_player_cubit.dart';
import 'package:spotify_clone/presentation/song_player/bloc/song_player_state.dart';

class SongPlayerPage extends StatefulWidget {
  final SongEntity songEntity;
  final List<SongEntity> playlist; // Danh sách bài hát

  const SongPlayerPage({
    required this.songEntity,
    required this.playlist,
    super.key,
  });

  @override
  _SongPlayerPageState createState() => _SongPlayerPageState();
}

class _SongPlayerPageState extends State<SongPlayerPage> {
  int currentIndex = 0; // Vị trí hiện tại trong danh sách bài hát

  @override
  void initState() {
    super.initState();
    // Tìm vị trí bài hát hiện tại trong playlist
    currentIndex = widget.playlist.indexOf(widget.songEntity);
  }

  // Chuyển đến bài hát tiếp theo
  void _nextSong() {
    setState(() {
      if (currentIndex < widget.playlist.length - 1) {
        currentIndex++;
        _loadSong();
      }
    });
  }

  // Chuyển về bài hát trước đó
  void _previousSong() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
        _loadSong();
      }
    });
  }

  // Tải bài hát mới từ playlist
  void _loadSong() {
    final song = widget.playlist[currentIndex];
    context.read<SongPlayerCubit>().loadSong(
        '${AppURLs.songFirestorage}${song.artist} - ${song.title}.mp3?${AppURLs.mediaAlt}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: const Text(
          'Now playing',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        action: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ),
      body: BlocProvider(
        create: (_) => SongPlayerCubit()
          ..loadSong(
              '${AppURLs.songFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.mp3?${AppURLs.mediaAlt}'),
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
    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            '${AppURLs.coverFirestorage}${widget.songEntity.artist} - ${widget.songEntity.title}.jpg?${AppURLs.mediaAlt}',
          ),
        ),
      ),
    );
  }

  Widget _songDetail() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.songEntity.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 5),
            Text(
              widget.songEntity.artist,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            // handler event click favorite icon button
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

  Widget _songPlayer(BuildContext context) {
    return BlocBuilder<SongPlayerCubit, SongPlayerState>(
      builder: (context, state) {
        if (state is SongPlayerLoading) {
          return const CircularProgressIndicator();
        }
        if (state is SongPlayerLoaded) {
          // Hiển thị giao diện điều khiển bài hát với các nút Next, Back
          return Column(
            children: [
              Slider(
                value: state.songPosition.inMilliseconds.toDouble(),
                min: 0.0,
                max: state.songDuration.inMilliseconds.toDouble(),
                onChanged: (value) {
                  context
                      .read<SongPlayerCubit>()
                      .seek(Duration(milliseconds: value.toInt()));
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatDuration(state.songPosition)),
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
                    onPressed: _previousSong, // Nút quay lại bài trước
                    icon: const Icon(Icons.skip_previous, size: 40),
                  ),
                  const SizedBox(width: 10),
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
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _nextSong, // Nút tới bài tiếp theo
                    icon: const Icon(Icons.skip_next, size: 40),
                  ),
                ],
              ),
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
