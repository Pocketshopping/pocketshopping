import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:rxdart/rxdart.dart';

class OrderBloc {
  OrderBloc._internal();

  static final OrderBloc instance = OrderBloc._internal();

  BehaviorSubject<List<Order>> _orderStreamController = BehaviorSubject<List<Order>>();

  Stream<List<Order>> get orderStream {
    return _orderStreamController;
  }

  void newOrder(List<Order> order) {
    _orderStreamController.sink.add(order);
  }

  void clearOrder() {
    _orderStreamController.sink.add(null);
  }

  void dispose() {
    _orderStreamController?.close();
  }
}
