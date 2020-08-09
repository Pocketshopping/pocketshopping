import 'package:rxdart/rxdart.dart';



class GeofenceRefreshBloc {
  GeofenceRefreshBloc._internal();

  static final GeofenceRefreshBloc instance = GeofenceRefreshBloc._internal();

  BehaviorSubject<DateTime> _productStreamController = BehaviorSubject<DateTime>();

  Stream<DateTime> get serverStream {
    return _productStreamController;
  }

  void addNextRefresh(DateTime server) {
    _productStreamController.sink.add(server);
  }

  Future<int> getLastRefresh() async{
    try{
      DateTime last = await _productStreamController.first;
      print(last);
      return DateTime.now().difference(last).inMinutes > 10?1:0;
    }
    catch(_){return 1;}
  }

  void clearRefresh() {
    _productStreamController.sink.add(null);
  }

  void dispose() {
    _productStreamController?.close();
  }
}
