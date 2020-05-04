import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends RegisterEvent {
  final String email;

  const EmailChanged({@required this.email});

  @override
  List<Object> get props => [email];

  @override
  String toString() => 'EmailChanged { email :$email }';
}

class TelephoneChanged extends RegisterEvent {
  final String telephone;

  const TelephoneChanged({@required this.telephone});

  @override
  List<Object> get props => [telephone];

  @override
  String toString() => 'TelephoneChanged { email :$telephone }';
}

class NameChanged extends RegisterEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'NameChanged { name :$name }';
}

class CountryCodeChanged extends RegisterEvent {
  final String country;

  const CountryCodeChanged({@required this.country});

  @override
  List<Object> get props => [country];

  @override
  String toString() => 'CountryCodeChanged { CountryCode :$country }';
}

class PasswordChanged extends RegisterEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'PasswordChanged { password: $password }';
}

class ConfirmPasswordChanged extends RegisterEvent {
  final String confirmpassword;

  const ConfirmPasswordChanged({@required this.confirmpassword});

  @override
  List<Object> get props => [confirmpassword];

  @override
  String toString() => 'ConfirmPasswordChanged { password: $confirmpassword }';
}

class AgreedChanged extends RegisterEvent {
  final bool agreed;

  const AgreedChanged({@required this.agreed});

  @override
  List<Object> get props => [agreed];

  @override
  String toString() => 'Agreed { agreed: $agreed }';
}

class Submitted extends RegisterEvent {
  final String email;
  final String password;
  final String name;
  final String telephone;

  const Submitted(
      {@required this.email,
      @required this.password,
      @required this.name,
      @required this.telephone});

  @override
  List<Object> get props => [email, password, name, telephone];

  @override
  String toString() {
    return 'Submitted { email: $email, password: $password, name: $name, telephone: $telephone }';
  }
}
