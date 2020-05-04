import 'package:equatable/equatable.dart';
import 'package:pocketshopping/src/user/package_user.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final Session user;

  const UserLoaded([this.user]);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UserLoaded { user: $user }';
}

class UserNotLoaded extends UserState {}
