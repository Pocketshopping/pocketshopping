import 'package:connectivity/connectivity.dart';
import 'package:rxdart/rxdart.dart';



class ConnectivityBloc {
  ConnectivityBloc._internal();

  static final ConnectivityBloc instance = ConnectivityBloc._internal();

  BehaviorSubject<ConnectivityResult > _connectivityStreamController = BehaviorSubject<ConnectivityResult >();

  Stream<ConnectivityResult > get connectivityStream {
    return _connectivityStreamController;
  }

  void newStatus(ConnectivityResult  result) {
    _connectivityStreamController.sink.add(result);
  }

  Future<ConnectivityResult> getStatus() async{
    return await _connectivityStreamController.last;
  }

  void dispose() {
    _connectivityStreamController?.close();
  }
}
