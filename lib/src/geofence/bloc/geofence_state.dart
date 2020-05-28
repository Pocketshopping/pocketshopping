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
            categoryName: 'Restuarant',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Frestuarant.jpg?alt=media&token=a4c93ec0-6889-4849-9fdf-74d8da74252f',
            categoryView: 10),
        MCategory(
            categoryName: 'Store',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2FpsCover.png?alt=media&token=690ccf94-1c3a-4263-9e88-f898116d4aa2',
            categoryView: 9),
        MCategory(
            categoryName: 'Bar',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Fbar.jpeg?alt=media&token=77b0124e-acfe-423a-a006-5ad2e597bd9a',
            categoryView: 7),
        MCategory(
            categoryName: 'Bakery&Pastry',
            categoryURI:
                'https://firebasestorage.googleapis.com/v0/b/pocketshopping-a57c2.appspot.com/o/MerchantCover%2Fbakery.png?alt=media&token=b962f7ca-7572-4a3b-b625-84d9d6c4dc3a',
            categoryView: 6),
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
