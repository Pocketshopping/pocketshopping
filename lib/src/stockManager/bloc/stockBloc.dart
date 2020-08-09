import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:rxdart/rxdart.dart';



class StockBloc {
  StockBloc._internal();

  static final StockBloc instance = StockBloc._internal();

  BehaviorSubject<List<Stock>> _stockStreamController = BehaviorSubject<List<Stock>>();

  Stream<List<Stock>> get stockStream {
    return _stockStreamController;
  }

  void stocks(List<Stock> stocks) {
    _stockStreamController.sink.add(stocks);
  }



  void dispose() {
    _stockStreamController?.close();
  }
}
