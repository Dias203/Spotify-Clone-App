import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spotify_clone/core/configs/constants/app_urls.dart';
import 'package:spotify_clone/domain/entities/auth/user.dart';
import 'package:spotify_clone/presentation/profile/bloc/profile_info_state.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  ProfileInfoCubit() : super(ProfileInfoLoading());

  Future<void> getUser() async {
    try {
      print('Fetching user profile data...');
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      String userId = currentUser.uid;
      print('Current userId: $userId');

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      final userEntity = UserEntity(
        imageURL: AppURLs.defaultImage, // Bạn có thể thêm trường hình ảnh nếu cần
        email: userData['email'],
        fullName: userData['name'],
      );

      print('Data fetched successfully: $userEntity');
      emit(ProfileInfoLoaded(userEntity));
    } catch (e) {
      print('Error fetching data: $e');
      emit(ProfileInfoFailure(e.toString()));
    }
  }
}
