import 'package:dartz/dartz.dart';
import 'package:spotify_clone/data/sources/songs/song_firebase_service.dart';
import 'package:spotify_clone/domain/repository/Song/song.dart';
import 'package:spotify_clone/service_locator.dart';

class SongRepositoryImpl extends SongsRepository {

  @override
  Future<Either> getNewsSongs() async {
    return await sl<SongFirebaseService>().getNewsSongs();
  }

}
