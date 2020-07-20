import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/category/repository/merchatCategoryObj.dart';

@immutable
class GeoFenceState {
  final String category;
  final Position currentPosition;
  final List<MCategory> categories;
  final List<Merchant> nearByMerchants;
  final bool isLoading;
  final bool isSuccess;
  final bool isFailure;
  final int selected;

  GeoFenceState({
    this.selected,
    this.nearByMerchants,
    this.category,
    this.categories,
    this.currentPosition,
    @required this.isLoading,
    @required this.isSuccess,
    @required this.isFailure,
  });

  factory GeoFenceState.empty() {
    return GeoFenceState(
      isLoading: false,
      isSuccess: false,
      isFailure: false,
      selected: 0,
      currentPosition: null,
      category: 'Restuarant',
      categories: [
        MCategory(
            categoryName: 'Logistic',
            categoryURI:
            'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Ffood-delivery.png?alt=media&token=12f6a851-658c-42af-919c-2a2feda94979',
            categoryView: 12,
            desc: 'Have riders(motorcycle, car, van) run your errand.'

        ),
        MCategory(
            categoryName: 'Restuarant',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Ffork.png?alt=media&token=1774a1cc-6367-49c2-8b3d-efab8b9dc7cc',
            categoryView: 10,
            desc: 'Get food delivered  to you from near by restaurant and also try out new restaurant.'),
        MCategory(
            categoryName: 'Store',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Fstore.png?alt=media&token=04d66f40-42f3-4105-a187-80fbb45b7af1',
            categoryView: 9,
            desc: 'You can buy anything from our stores and have them delivered to you.'),
        MCategory(
            categoryName: 'Bakery&Pastry',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Fbread.png?alt=media&token=3d21a0a6-aa7e-4433-880c-bb6e826e08e3',
            categoryView: 6,
            desc: 'Looking for near by bakery and pastry. check out our list'),
      ],
      nearByMerchants: [],
    );
  }

  factory GeoFenceState.loading({
    String category = 'Restuarant',
    List<Merchant> nearByMerchants,
    List<MCategory> categories,
    int selected = 0,
    Position currentPosition,
  }) {
    return GeoFenceState(
      categories: categories,
      category: category,
      nearByMerchants: nearByMerchants ?? [],
      selected: selected,
      currentPosition: currentPosition,
      isLoading: true,
      isSuccess: false,
      isFailure: false,
    );
  }

  factory GeoFenceState.failure(
      {String category = 'Restuarant',
      List<Merchant> nearByMerchants,
      List<MCategory> categories,
      int selected,
      Position currentPosition}) {
    return GeoFenceState(
      categories: categories,
      nearByMerchants: nearByMerchants ?? [],
      category: category,
      selected: 0,
      currentPosition: currentPosition,
      isLoading: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory GeoFenceState.success({
    String category = 'Restuarant',
    List<Merchant> nearByMerchants,
    List<MCategory> categories,
    int selected = 0,
    Position currentPosition,
  }) {
    return GeoFenceState(
      categories: categories,
      nearByMerchants: nearByMerchants ?? [],
      category: category,
      selected: selected,
      currentPosition: currentPosition,
      isLoading: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  GeoFenceState update(
      {String category,
      List<Merchant> nearByMerchants,
      List<MCategory> categories,
      int selected,
      Position currentPosition}) {
    return copyWith(
      categories: categories,
      nearByMerchants: nearByMerchants,
      selected: selected,
      category: category,
      currentPosition: currentPosition,
      isLoading: false,
      isSuccess: false,
      isFailure: false,
    );
  }

  GeoFenceState copyWith({
    String category,
    List<Merchant> nearByMerchants,
    List<MCategory> categories,
    int selected,
    Position currentPosition,
    bool isLoading,
    bool isSuccess,
    bool isFailure,
  }) {
    return GeoFenceState(
      categories: categories ?? this.categories,
      category: category ?? this.category,
      selected: selected ?? this.selected,
      currentPosition: currentPosition ?? this.currentPosition,
      nearByMerchants: nearByMerchants ?? this.nearByMerchants,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''Instance of GeoFenceState''';
  }
}
