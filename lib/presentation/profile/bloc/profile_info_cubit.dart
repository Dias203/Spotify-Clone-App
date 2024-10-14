import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_clone/domain/entities/auth/user.dart';
import 'package:spotify_clone/domain/usecases/auth/get_user.dart';
import 'package:spotify_clone/presentation/profile/bloc/profile_info_state.dart';
import 'package:spotify_clone/service_locator.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit() : super(ProfileInfoLoading());

  Future<void> getUser() async {
    try {
      print('Fetching user profile data...');
      // Simulate fetching user data with a delay
      await Future.delayed(Duration(seconds: 2));
      // Replace this with actual data fetching logic
      final userEntity = UserEntity(
        imageURL: 'https://example.com/profile.jpg',
        email: 'user@example.com',
        fullName: 'John Doe',
      );
      print('Data fetched successfully: $userEntity');
      emit(ProfileInfoLoaded(userEntity));
    } catch (e) {
      print('Error fetching data: $e');
      emit(ProfileInfoFailure(e.toString()));
    }
  }
}
