import 'package:rxdart/rxdart.dart';



class ProductRefreshBloc {
  ProductRefreshBloc._internal();

  static final ProductRefreshBloc instance = ProductRefreshBloc._internal();

  BehaviorSubject<DateTime> _productStreamController = BehaviorSubject<DateTime>();

  Stream<DateTime> get productStream {
    return _productStreamController;
  }

  void addNextRefresh(DateTime time) {
    _productStreamController.sink.add(time);
  }

  Future<int> getLastRefresh() async{
    //print ('${await _productStreamController.first}');
    try{
      DateTime last = await _productStreamController.first;
      print (last);
      if(last == null)throw Exception;
      return DateTime.now().difference(last).inMinutes > 15?1:0;
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
