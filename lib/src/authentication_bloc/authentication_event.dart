part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}

class Setup extends AuthenticationEvent {}

class DeepLink extends AuthenticationEvent {
  final Uri link;

  DeepLink(this.link);

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'DLink { link: $link }';
}
