
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/business/business.dart';

@immutable
class GeoFenceState {
  final String category;
  final Position currentPosition;
  final List<String> categories;
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
      categories: ['Restuarant','Eatery','Bar','Store','Park'],
      nearByMerchants: [],


    );
  }

  factory GeoFenceState.loading({
    String category= 'Restuarant',
    List<Merchant> nearByMerchants,
    List<String> categories,
    int selected=0,
    Position currentPosition,
}) {
    return GeoFenceState(
      categories: categories,
      category: category,
      nearByMerchants: nearByMerchants??[],
      selected: selected,
      currentPosition: currentPosition,
      isLoading: true,
      isSuccess: false,
      isFailure: false,
    );
  }


  factory GeoFenceState.failure({
    String category= 'Restuarant',
    List<Merchant> nearByMerchants,
    List<String> categories,
    int selected,
    Position currentPosition
  }) {
    return GeoFenceState(
      categories: categories,
      nearByMerchants: nearByMerchants??[],
      category: category,
      selected: 0,
      currentPosition:currentPosition,
      isLoading: false,
      isSuccess: false,
      isFailure: true,
    );
  }

  factory GeoFenceState.success({
    String category= 'Restuarant',
    List<Merchant> nearByMerchants,
    List<String> categories,
    int selected=0,
    Position currentPosition,
  }) {
    return GeoFenceState(
      categories: categories,
      nearByMerchants: nearByMerchants??[],
      category: category,
      selected: selected,
      currentPosition: currentPosition,
      isLoading: false,
      isSuccess: true,
      isFailure: false,
    );
  }

  GeoFenceState update({
    String category,
    List<Merchant> nearByMerchants,
    List<String> categories,
    int selected,
    Position currentPosition
  }) {
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
    List<String> categories,
    int selected,
    Position currentPosition,
    bool isLoading,
    bool isSuccess,
    bool isFailure,
  }) {
    return GeoFenceState(
      categories: categories??this.categories,
      category: category??this.category,
      selected: selected??this.selected,
      currentPosition: currentPosition??this.currentPosition,
      nearByMerchants: nearByMerchants??this.nearByMerchants,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isFailure: isFailure ?? this.isFailure,
    );
  }

  @override
  String toString() {
    return '''GeoFenceState { 
       category:$category,  
      isLoading: $isLoading,
      isSuccess: $isSuccess,
      isFailure: $isFailure,
      selected:$selected,
      currentPosition:$currentPosition,
      nearByMerchants:${nearByMerchants.length}
    }''';
  }
}

