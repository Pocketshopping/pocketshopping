part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object> get props => [];
}

class Uninitialized extends AuthenticationState {}

class Authenticated extends AuthenticationState {
  final FirebaseUser user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'Instance of AuthenticationState<Authenticated>';
}

class Unauthenticated extends AuthenticationState {
  final Uri link;

  const Unauthenticated({this.link});

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'Instance of AuthenticationState<Unauthenticated>';
}

class SetupBusiness extends AuthenticationState {
  final FirebaseUser user;

  const SetupBusiness(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'Instance of AuthenticationState<SetupBusiness>';
}

class DLink extends AuthenticationState {
  final FirebaseUser user;
  final Uri link;

  const DLink(this.user, this.link);

  @override
  List<Object> get props => [user, link];

  @override
  String toString() => 'Instance of AuthenticationState<DLink>';
}
