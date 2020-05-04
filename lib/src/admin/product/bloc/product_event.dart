import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/user/package_user.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class PriceChanged extends ProductEvent {
  final double price;

  const PriceChanged({@required this.price});

  @override
  List<Object> get props => [price];

  @override
  String toString() => 'PriceChanged { price :$price }';
}

class CategoryChanged extends ProductEvent {
  final String category;

  const CategoryChanged({@required this.category});

  @override
  List<Object> get props => [category];

  @override
  String toString() => 'CategoryChanged { email :$category }';
}

class NameChanged extends ProductEvent {
  final String name;

  const NameChanged({@required this.name});

  @override
  List<Object> get props => [name];

  @override
  String toString() => 'NameChanged { name :$name }';
}

class CaptureBarCode extends ProductEvent {}

class ImageFromGallery extends ProductEvent {}

class ProductCount extends ProductEvent {
  final String mID;

  const ProductCount({@required this.mID});

  @override
  List<Object> get props => [mID];

  @override
  String toString() => 'ProductCount { merchants :$mID }';
}

class ProductCountUpdate extends ProductEvent {
  final int count;

  const ProductCountUpdate({@required this.count});

  @override
  List<Object> get props => [count];

  @override
  String toString() => 'ProductCountUpdate { ProductCountUpdate :$count }';
}

class ImageFromCamera extends ProductEvent {
  final File image;

  const ImageFromCamera({@required this.image});

  @override
  List<Object> get props => [image];

  @override
  String toString() => 'ImageFromCamera { image :$image }';
}

class Submitted extends ProductEvent {
  final String stock;
  final String category;
  final String name;
  final String description;
  final double price;
  final String unit;
  final Session user;

  const Submitted({
    @required this.stock,
    @required this.category,
    @required this.name,
    @required this.description,
    @required this.price,
    @required this.unit,
    @required this.user,
  });

  @override
  List<Object> get props =>
      [stock, category, name, description, price, unit, user];

  @override
  String toString() {
    return 'Submitted { '
        'price: $price, '
        'category: $category, '
        'name: $name, '
        'unit: $unit,'
        'description:$description,'
        'stock:$stock, '
        'user:$user }';
  }
}
