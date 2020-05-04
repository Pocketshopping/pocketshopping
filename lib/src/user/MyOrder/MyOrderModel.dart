import 'package:flutter/material.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';

class MyOrderModel extends ChangeNotifier {
  static const int ItemRequestThreshold = 10;

  List<dynamic> _items = List();

  List<dynamic> get items => _items;

  int _currentPage = 0;
  final query;

  MyOrderModel(this.query) {
    delayer(null, query['category'], query['uid']).then((value) => null);
  }

  Future<void> delayer(dynamic lastItem, String category, String uid) async {
    _showLoadingIndicator();
    switch (query['category']) {
      case 'PROCESSING':
        var result = await OrderRepo.get(lastItem, category, uid);
        _items.clear();
        if (result.isNotEmpty)
          _items.addAll(result);
        else
          _items.add(SearchEmptyIndicatorTitle);
        break;
      default:
        _items = [];
        break;
    }
    _removeLoadingIndicator();
  }

  Future handleItemCreated(int index, {String search}) async {
    var itemPosition = index + 1;
    var requestMoreData =
        itemPosition % ItemRequestThreshold == 0 && itemPosition != 0;
    var pageToRequest = itemPosition ~/ ItemRequestThreshold;

    if (requestMoreData && pageToRequest > _currentPage) {
      print('handleItemCreated | pageToRequest: $pageToRequest');
      print(items[items.length - 1]);
      _currentPage = pageToRequest;
      await delayer(items[items.length - 1], query['category'], query['uid']);
    } else {}
  }

  void _showLoadingIndicator() {
    _items.add(LoadingIndicatorTitle);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _items.remove(LoadingIndicatorTitle);
    notifyListeners();
  }

  Future handleChangeCategory({String category}) async {
    if (category.isNotEmpty) {
      _items.clear();
      query['category'] = category;
      await delayer(null, category, query['uid']);
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
  }
}
