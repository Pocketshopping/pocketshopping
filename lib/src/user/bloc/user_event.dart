import 'package:equatable/equatable.dart';
import 'package:pocketshopping/src/user/package_user.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUser extends UserEvent {
  final String uid;

  const LoadUser(this.uid);

  @override
  List<Object> get props => [uid];

  @override
  String toString() => 'LoadUser { user: $uid }';
}

class AddUser extends UserEvent {
  final User user;

  const AddUser(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'AddUser { user: $user }';
}

class UpdateUser extends UserEvent {
  final User user;

  const UpdateUser(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'UpdateUser { user: $user }';
}

class UserUpdated extends UserEvent {
  final Session user;

  const UserUpdated(this.user);

  @override
  List<Object> get props => [user];
}

class DeleteUser extends UserEvent {
  final User user;

  const DeleteUser(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'DeleteUser { user: $user }';
}
