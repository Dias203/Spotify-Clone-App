import 'package:get_it/get_it.dart';
import 'package:spotify_clone/data/repository/auth/auth_repository_impl.dart';
import 'package:spotify_clone/data/repository/song/song.dart';
import 'package:spotify_clone/data/sources/auth/auth_firebase_service.dart';
import 'package:spotify_clone/data/sources/songs/song_firebase_service.dart';
import 'package:spotify_clone/domain/repository/Song/song.dart';
import 'package:spotify_clone/domain/repository/auth/auth.dart';
import 'package:spotify_clone/domain/usecases/auth/signin.dart';
import 'package:spotify_clone/domain/usecases/auth/signup.dart';
import 'package:spotify_clone/domain/usecases/song/get_news_songs.dart';
import 'package:spotify_clone/domain/usecases/song/get_play_list.dart';

// manage dependencies (AuthFirebaseService and AuthRepository) in the application.
// Instead of creating and passing objects (like repository, service)
// across multiple classes and widgets, get_it helps manage them centrally

final sl = GetIt.instance;

Future<void> initializeDependencies() async {

  // auth
  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl()
  );

  sl.registerSingleton<AuthRepository>(
      AuthRepositoryImpl()
  );

  sl.registerSingleton<SignupUseCase>(
      SignupUseCase()
  );

  sl.registerSingleton<SigninUseCase>(
      SigninUseCase()
  );

  // song
  sl.registerSingleton<SongFirebaseService>(
      SongFireBaseServiceImpl()
  );

  sl.registerSingleton<SongsRepository>(
      SongRepositoryImpl()
  );

  sl.registerSingleton<GetNewsSongsUseCase>(
      GetNewsSongsUseCase()
  );

  sl.registerSingleton<GetPlayListUseCase>(
      GetPlayListUseCase()
  );
}
