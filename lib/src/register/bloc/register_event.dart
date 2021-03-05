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
  String toString() => 'Instance of RegisterEvent<EmailChanged>';
}

class TelephoneChanged extends RegisterEvent {
  final String telephone;

  const TelephoneChanged({@required this.telephone});

  @override
  List<Object> get props => [telephone];

  @override
  String toString() => 'Instance of RegisterEvent<TelephoneChanged>';
}

class NameChanged extends RegisterEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'Instance of RegisterEvent<NameChanged>';
}

class CountryCodeChanged extends RegisterEvent {
  final String country;

  const CountryCodeChanged({@required this.country});

  @override
  List<Object> get props => [country];

  @override
  String toString() => 'Instance of RegisterEvent<CountryCodeChanged>';
}

class PasswordChanged extends RegisterEvent {
  final String password;

  const PasswordChanged({@required this.password});

  @override
  List<Object> get props => [password];

  @override
  String toString() => 'Instance of RegisterEvent<PasswordChanged>';
}

class ConfirmPasswordChanged extends RegisterEvent {
  final String confirmpassword;

  const ConfirmPasswordChanged({@required this.confirmpassword});

  @override
  List<Object> get props => [confirmpassword];

  @override
  String toString() => 'Instance of RegisterEvent<ConfirmPasswordChanged>';
}

class AgreedChanged extends RegisterEvent {
  final bool agreed;

  const AgreedChanged({@required this.agreed});

  @override
  List<Object> get props => [agreed];

  @override
  String toString() => 'Instance of RegisterEvent<AgreedChanged>';
}

class Submitted extends RegisterEvent {
  final String email;
  final String password;
  final String name;
  final String telephone;
  final String referral;
  final String cPassword;


  const Submitted({
    @required this.email,
    @required this.password,
    @required this.name,
    @required this.telephone,
    @required this.referral,
    @required this.cPassword,
  });

  @override
  List<Object> get props => [email, password, name, telephone, referral, cPassword];

  @override
  String toString() {
    return 'Instance of RegisterEvent<Submitted>';
  }
}
