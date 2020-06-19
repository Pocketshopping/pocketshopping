import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

abstract class BusinessEvent extends Equatable {
  const BusinessEvent();

  @override
  List<Object> get props => [];
}

class AddressChanged extends BusinessEvent {
  final String address;

  const AddressChanged({@required this.address});

  @override
  List<Object> get props => [address];

  @override
  String toString() => 'Instance of BusinessEvent<AddressChanged>';
}

class TelephoneChanged extends BusinessEvent {
  final String telephone;

  const TelephoneChanged({@required this.telephone});

  @override
  List<Object> get props => [telephone];

  @override
  String toString() => 'Instance of BusinessEvent<TelephoneChanged>';
}

class NameChanged extends BusinessEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'Instance of BusinessEvent<NameChanged>';
}

class CountryCodeChanged extends BusinessEvent {
  final String country;

  const CountryCodeChanged({@required this.country});

  @override
  List<Object> get props => [country];

  @override
  String toString() => 'Instance of BusinessEvent<CountryCodeChanged>';
}

class CategoryChanged extends BusinessEvent {
  final String category;

  const CategoryChanged({@required this.category});

  @override
  List<Object> get props => [category];

  @override
  String toString() => 'Instance of BusinessEvent<CategoryChanged>';
}

class CaptureCordinate extends BusinessEvent {
  @override
  String toString() => 'Instance of BusinessEvent<CaptureCordinate>';
}

class CaptureUpdated extends BusinessEvent {
  final Position position;

  const CaptureUpdated(this.position);

  @override
  List<Object> get props => [position];
}

class DeliveryChanged extends BusinessEvent {
  final String delivery;

  const DeliveryChanged({@required this.delivery});

  @override
  List<Object> get props => [delivery];

  @override
  String toString() => 'Instance of BusinessEvent<DeliveryChanged>';
}

class categoryChanged extends BusinessEvent {}

class Submitted extends BusinessEvent {
  final String address;
  final String category;
  final String name;
  final String telephone;
  final dynamic user;
  final bool isAgent;

  const Submitted({
    @required this.address,
    @required this.category,
    @required this.name,
    @required this.telephone,
    @required this.user,
    @required this.isAgent
  });

  @override
  List<Object> get props => [address, category, name, telephone, user,isAgent];

  @override
  String toString() {
    return 'Instance of BusinessEvent<Submitted>';
  }
}

class AgreedChanged extends BusinessEvent {
  final bool agreed;

  const AgreedChanged({@required this.agreed});

  @override
  List<Object> get props => [agreed];

  @override
  String toString() => 'Instance of BusinessEvent<AgreedChanged>';
}
