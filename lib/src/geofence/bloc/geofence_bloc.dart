import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/category/repository/categoryRepo.dart';

class GeoFenceBloc extends Bloc<GeoFenceEvent, GeoFenceState> {
  Geolocator geolocator = Geolocator();
  StreamSubscription _positionSubscription;
  StreamSubscription _merchantSubscription;
  final Geoflutterfire geo = Geoflutterfire();
  final double radius = 50;
  final String field = 'businessGeopint';

  @override
  GeoFenceState get initialState => GeoFenceState.empty();

  @override
  Stream<GeoFenceState> mapEventToState(
    GeoFenceEvent event,
  ) async* {
    if (event is NearByMerchant) {
      yield* _mapNearByMerchantToState(event.category);
    } else if (event is FetchNearByMerchant) {
      yield* _mapFetchNearByMerchantToState(event.position, event.category);
    } else if (event is CategorySelected) {
      yield* _mapCategorySelectedToState(event.selected);
    } else if (event is UpdateMerchant) {
      yield* _mapUpdateMerchantToState(event.merchant);
    }else if (event is Categories) {
      yield* _mapCategoriesToState();
    }
  }

  Stream<GeoFenceState> _mapCategoriesToState() async* {
    yield state.update(categories: await CategoryRepo.getAll());
  }

  Stream<GeoFenceState> _mapCategorySelectedToState(int selected) async* {
    yield state.update(selected: selected);
  }

  Stream<GeoFenceState> _mapUpdateMerchantToState(
      List<Merchant> merchant) async* {

    yield state.update(nearByMerchants: merchant);
    yield GeoFenceState.success(
        category: state.category,
        nearByMerchants: merchant,
        categories: state.categories,
        currentPosition: state.currentPosition);


  }

  Stream<GeoFenceState> _mapFetchNearByMerchantToState(
      Position _position, String category) async* {
    yield state.update(currentPosition: _position);
    yield GeoFenceState.loading(
        category: category,
        currentPosition: state.currentPosition,
        nearByMerchants: state.nearByMerchants,
        categories: state.categories);
    List<Merchant> data = List();
    GeoFirePoint center =
        geo.point(latitude: _position.latitude, longitude: _position.longitude);
    var collectionReference = Firestore.instance
        .collection('merchants')
        .where('businessCategory', isEqualTo: category)
        .limit(10);
    Stream<List<DocumentSnapshot>> stream = geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: true);

    _merchantSubscription?.cancel();
    _merchantSubscription = stream.listen((event) {
      event.forEach((element) {
        data.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
      });
      add(UpdateMerchant(merchant: data));
    });

    yield state.update(category: category);

    //}
  }

  Stream<GeoFenceState> _mapNearByMerchantToState(String category) async* {
    add(Categories());
    yield GeoFenceState.loading(
        category: state.category,
        categories: state.categories,
        nearByMerchants: state.nearByMerchants,
        currentPosition: state.currentPosition);
    try {
      _positionSubscription?.cancel();
      _positionSubscription = geolocator
          .getPositionStream(LocationOptions(
              accuracy: LocationAccuracy.bestForNavigation,
              timeInterval: 30000))
          .listen((position) {
        add(FetchNearByMerchant(position: position, category: category));
      });
    } catch (e) {
      yield GeoFenceState.failure(
          category: state.category,
          categories: state.categories,
          nearByMerchants: state.nearByMerchants,
          currentPosition: state.currentPosition);
    }
  }

  @override
  Future<void> close() {
    _positionSubscription.cancel();
    _merchantSubscription.cancel();
    return super.close();
  }
}
