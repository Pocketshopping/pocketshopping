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
  String toString() => 'Authenticated { email: ${user.email} }';
}

class Unauthenticated extends AuthenticationState {
  final Uri link;

  const Unauthenticated({this.link});

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'DLink { link: $link }';
}

class SetupBusiness extends AuthenticationState {
  final FirebaseUser user;

  const SetupBusiness(this.user);

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'SetupBusiness { email: ${user.email} }';
}

class DLink extends AuthenticationState {
  final FirebaseUser user;
  final Uri link;

  const DLink(this.user,this.link);

  @override
  List<Object> get props => [user,link];

  @override
  String toString() => 'DLink { link: $link }';
}