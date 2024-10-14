import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/common/bloc/favorite_button/favorite_button_cubit.dart';
import 'package:spotify_clone/common/bloc/favorite_button/favorite_button_state.dart';
import 'package:spotify_clone/core/configs/theme/app_colors.dart';
import 'package:spotify_clone/domain/entities/song/song.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity songEntity;
  const FavoriteButton({required this.songEntity, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FavoriteButtonCubit(),
      child: BlocBuilder<FavoriteButtonCubit, FavoriteButtonState>(
        builder: (context, state){
          if(state is FavoriteButtonInitial) {
            return IconButton(
              onPressed: () {
                // handler event click favorite icon button
                context.read<FavoriteButtonCubit>().favoriteButtonUpdated(songEntity.songId);
              },
              icon: Icon(
                songEntity.isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
                size: 30,
                color: AppColors.darkGrey,
              ),
            );
          }

          if(state is FavoriteButtonUpdated) {
            return IconButton(
              onPressed: () {
                // handler event click favorite icon button
                context.read<FavoriteButtonCubit>().favoriteButtonUpdated(songEntity.songId);
              },
              icon: Icon(
                state.isFavorite ? Icons.favorite : Icons.favorite_outline_outlined,
                size: 30,
                color: AppColors.darkGrey,
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
