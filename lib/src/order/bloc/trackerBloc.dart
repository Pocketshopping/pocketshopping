import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:rxdart/rxdart.dart';

class TrackerBloc {
  TrackerBloc._internal();

  static final TrackerBloc instance = TrackerBloc._internal();

  BehaviorSubject<Map<String,Timestamp>> _trackerStreamController = BehaviorSubject<Map<String,Timestamp>>();

  Stream<Map<String,Timestamp>> get trackerStream {
    return _trackerStreamController;
  }

  void newDateTime(Map<String,Timestamp> timeStamp) {
    _trackerStreamController.sink.add(timeStamp);
  }

  void clearDateTime() {
    _trackerStreamController.sink.add(null);
  }

  void dispose() {
    _trackerStreamController?.close();
  }
}
