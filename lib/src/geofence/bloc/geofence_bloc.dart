import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/category/repository/categoryRepo.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';

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
    } else if (event is FetchAllNearByMerchant) {
      yield* _mapFetchAllNearByMerchantToState(event.position,);
    } else if (event is CategorySelected) {
      yield* _mapCategorySelectedToState(event.selected);
    } else if (event is UpdateMerchant) {
      yield* _mapUpdateMerchantToState(event.merchant);
    } else if (event is Categories) {
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

    yield GeoFenceState.loading(
        category: state.category,
        currentPosition: state.currentPosition,
        nearByMerchants: state.nearByMerchants,
        categories: state.categories);
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

    if(_position == null)
      yield GeoFenceState.failure(
          category: state.category,
          categories: state.categories,
          nearByMerchants: state.nearByMerchants,
          currentPosition: state.currentPosition);

    else{
      List<Merchant> data = List();
      GeoFirePoint center = geo.point(latitude: _position.latitude, longitude: _position.longitude);
      var collectionReference = Firestore.instance
          .collection('merchants')
          .where('businessCategory', isEqualTo: category)
          .where('businessActive',isEqualTo: true)
          .limit(10);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: radius, field: field, strictMode: true);


      _merchantSubscription?.cancel();
      _merchantSubscription = stream.listen((event) {
        event.forEach((element) {
          data.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
        });
        data.toSet().toList();
        add(UpdateMerchant(merchant: data));
      });

      yield state.update(category: category);
    }

    //}
  }

  Stream<GeoFenceState> _mapFetchAllNearByMerchantToState(
      Position _position) async* {
    yield state.update(currentPosition: _position);
    yield GeoFenceState.loading(
        category: 'Restuarant',
        currentPosition: state.currentPosition,
        nearByMerchants: state.nearByMerchants,
        categories: state.categories);

    if(_position == null)
      yield GeoFenceState.failure(
          category: state.category,
          categories: state.categories,
          nearByMerchants: state.nearByMerchants,
          currentPosition: state.currentPosition);

    else{
      List<Merchant> data = List();
      GeoFirePoint center = geo.point(latitude: _position.latitude, longitude: _position.longitude);
      var collectionReference = Firestore.instance
          .collection('merchants')
          .where('businessActive',isEqualTo: true)
          .limit(10);
      Stream<List<DocumentSnapshot>> stream = geo
          .collection(collectionRef: collectionReference)
          .within(center: center, radius: radius, field: field, strictMode: true);
      _merchantSubscription?.cancel();
      _merchantSubscription = stream.listen((event) {
        event.forEach((element) {
          data.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
        });
        data.toSet().toList();
        add(UpdateMerchant(merchant: data));
      });

      yield state.update(category: 'Restuarant');
    }

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


      if(state.currentPosition == null){
        geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation).then((value)
            {
              if(category != 'All')
                add(FetchNearByMerchant(position: value, category: category));
              else
                add(FetchAllNearByMerchant(position: value));
            }

        );
      }

      _positionSubscription = geolocator
          .getPositionStream(LocationOptions(
              accuracy: LocationAccuracy.bestForNavigation,
              timeInterval: 60000))
          .listen((position) {
            if(category != 'All')
              add(FetchNearByMerchant(position: position, category: category));
            else
              add(FetchAllNearByMerchant(position: position));
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
    _positionSubscription?.cancel();
    _merchantSubscription?.cancel();
    return super.close();
  }
}
