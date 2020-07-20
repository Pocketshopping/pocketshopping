import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class LocationBloc {
  LocationBloc._internal();

  static final LocationBloc instance = LocationBloc._internal();

  BehaviorSubject<LocationData> _locationStreamController = BehaviorSubject<LocationData>();

  Stream<LocationData> get locationStream {
    return _locationStreamController;
  }

  void newLocationUpdate(LocationData cLoc) {
    _locationStreamController.sink.add(cLoc);
  }

  void clearLocationUpdate() {
    _locationStreamController.sink.add(null);
  }

  void dispose() {
    _locationStreamController?.close();
  }
}
