

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/business/business.dart';


abstract class GeoFenceEvent extends Equatable {
  const GeoFenceEvent();

  @override
  List<Object> get props => [];
}

class NearByMerchant extends GeoFenceEvent {
  final String category;

  const NearByMerchant({@required this.category});

  @override
  List<Object> get props => [category];

  @override
  String toString() => 'NearByMerchant { category :$category }';
}

class FetchNearByMerchant extends GeoFenceEvent {
  final String category;
  final Position position;

  const FetchNearByMerchant({@required this.category, @required this.position});

  @override
  List<Object> get props => [category];

  @override
  String toString() => 'FetchNearByMerchant { category :$category, position:$position }';
}

class UpdateMerchant extends GeoFenceEvent {
  final List<Merchant> merchant;

  const UpdateMerchant({@required this.merchant});

  @override
  List<Object> get props => [merchant];

  @override
  String toString() => 'UpdateMerchant { merchant :${merchant.length} }';
}

class CategorySelected extends GeoFenceEvent {
  final int selected;

  const CategorySelected({@required this.selected});

  @override
  List<Object> get props => [selected];

  @override
  String toString() => 'CategorySelected { selected :$selected }';
}

