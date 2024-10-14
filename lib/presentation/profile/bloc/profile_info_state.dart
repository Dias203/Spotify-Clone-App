import 'package:equatable/equatable.dart';
import 'package:spotify_clone/domain/entities/auth/user.dart';

abstract class ProfileInfoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInfoLoading extends ProfileInfoState {}

class ProfileInfoLoaded extends ProfileInfoState {
  final UserEntity userEntity;
  
  ProfileInfoLoaded(this.userEntity);
  
  @override
  List<Object?> get props => [userEntity];
}

class ProfileInfoFailure extends ProfileInfoState {
  final String message;

  ProfileInfoFailure(this.message);

  @override
  List<Object?> get props => [message];
}