import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devicelocale/devicelocale.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/validators.dart';

class BusinessBloc extends Bloc<BusinessEvent, BusinessState> {
  Geolocator geolocator = Geolocator();
  StreamSubscription _positionSubscription;

  @override
  BusinessState get initialState => BusinessState.empty();

  @override
  Stream<BusinessState> mapEventToState(
    BusinessEvent event,
  ) async* {
    if (event is AddressChanged) {
      yield* _mapAddressChangedToState(event.address);
    } else if (event is CategoryChanged) {
      yield* _mapCategoryChangedToState(event.category);
    } else if (event is CaptureCordinate) {
      yield* _mapCaptureChangedToState();
    } else if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    } else if (event is TelephoneChanged) {
      yield* _mapTelephoneChangedToState(event.telephone);
    } else if (event is CountryCodeChanged) {
      yield* _mapCountryCodeChangedToState(event.country);
    } else if (event is DeliveryChanged) {
      yield* _mapDeliveryChangedToState(event.delivery);
    } else if (event is CaptureUpdated) {
      yield* _mapCaptureUpdatedToState(event.position);
    } else if (event is AgreedChanged) {
      yield* _mapAgreedChangedToState(event.agreed);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(
          event.address,
          event.name,
          event.telephone,
          event.user,
          event.isAgent,
      );
    }
  }

  Stream<BusinessState> _mapAgreedChangedToState(bool agreed) async* {
    yield state.update(isAgreedValid: agreed);
  }

  Stream<BusinessState> _mapDeliveryChangedToState(String delivery) async* {
    yield state.update(delivery: delivery);
  }

  Stream<BusinessState> _mapCaptureUpdatedToState(Position _position) async* {
    if (state.position == null)
      yield state.update(position: _position);
    else if (_position.accuracy < state.position.accuracy)
      yield state.update(position: _position);
    else {
      // print('from state: ${state.position.accuracy}');
      //print('${_position.accuracy}');
    }
  }

  Stream<BusinessState> _mapCountryCodeChangedToState(String country) async* {
    yield state.update(code: country);
  }

  Stream<BusinessState> _mapAddressChangedToState(String address) async* {
    yield state.update(
      isAddressValid: Validators.isValidAddress(address),
    );
  }

  Stream<BusinessState> _mapCaptureChangedToState() async* {
    yield state.update(isCapturing: "YES");
    try {
      _positionSubscription?.cancel();
      _positionSubscription = geolocator
          .getPositionStream(LocationOptions(
              accuracy: LocationAccuracy.bestForNavigation, timeInterval: 1000))
          .listen((position) {
        print(position);
        add(CaptureUpdated(position));
      });
    } catch (e) {
      //print(e);
    }

    //await Future.delayed(Duration(seconds: 15));
    //_positionSubscription?.cancel();
    //yield state.update(isCapturing: "COMPLETED", isCaptureValid: true);
  }

  Stream<BusinessState> _mapCategoryChangedToState(String category) async* {
    yield state.update(
      category: category,
    );
  }

  Stream<BusinessState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameValid: Validators.isValidName(name),
    );
  }

  Stream<BusinessState> _mapTelephoneChangedToState(String telephone) async* {
    yield state.update(
      isTelephoneValid:
          Validators.isValidTelephone(telephone, ccode: state.code),
    );
  }

  Stream<BusinessState> _mapFormSubmittedToState(
    String address,
    String name,
    String telephone,
    dynamic  user,
    bool isAgent
  ) async* {
    yield BusinessState.loading(
        isUploading: false,
        isCapturing: state.isCapturing,
        position: state.position,
        delivery: state.delivery,
        code: state.code,
        category: state.category);
    try {
      await MerchantRepo().save(
        bAddress: address,
        bBranchUnique: "",
        bCategory: state.category,
        bCloseTime: "20:00",
        bDelivery: state.delivery,
        bDescription: "",
        bEmail: user.email,
        bOpenTime: "08:00",
        bTelephone: state.code + (telephone.substring(1)),
        bName: name,
        bTelephone2: "",
        bID: "",
        bPhoto: PocketShoppingDefaultCover,
        bStatus: 1,
        bSocial: {},
        bCountry: await Devicelocale.currentLocale,
        bParent: 'null',
        isBranch: false,
        uid: user.uid,
        bGeopint: GeoPoint(state.position.latitude, state.position.longitude),
        adminUploaded: isAgent,
      );
      if(!isAgent)
      await UserRepository().upDateUserRole('admin', user);

      yield BusinessState.success();
    } catch (_) {
      yield state.update(isCapturing: _.toString());
      yield BusinessState.failure(
          isUploading: false,
          isCapturing: state.isCapturing,
          position: state.position,
          delivery: state.delivery,
          code: state.code,
          category: state.category);
      print(_);
    }

    //yield BusinessState.loading(false);
    //await Future.delayed(Duration(milliseconds: 5000));
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    return super.close();
  }
}
