import 'package:flutter/material.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';

class ViewModel extends ChangeNotifier {
  static const int ItemRequestThreshold = 10;

  List<dynamic> _items = List();

  List<dynamic> get items => _items;

  int _currentPage = 0;

  String searchTerm;
  final query;

  ViewModel({this.searchTerm, this.query}) {
    delayer(null, query['category']).then((value) => null);
  }

  Future<void> delayer(dynamic lastItem, String category) async {
    _showLoadingIndicator();
    switch (query['typeOf']) {
      case 'PRODUCT':
        var result =
            await ProductRepo().fetchProduct(query['mid'], lastItem, category);
        _items.addAll(result);

        break;
      default:
        _items = [];
        break;
    }
    _removeLoadingIndicator();
  }

  Future<void> searcher(dynamic lastItem, String search) async {
    _showLoadingIndicator();
    switch (query['typeOf']) {
      case 'PRODUCT':
        searchTerm = search;
        var result =
            await ProductRepo().SearchProduct(query['mid'], lastItem, search);
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
      //print('handleItemCreated | pageToRequest: $pageToRequest');
      //print(items[items.length - 1]);
      _currentPage = pageToRequest;
      await delayer(items[items.length - 1], query['category']);
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
      await delayer(null, category);
    } else {}
  }

  Future handleSearch({String search}) async {
    if (search.isNotEmpty && searchTerm != search) {
      _items.clear();
      await searcher(null, search);
    } else {}
  }

  Future handleQRcodeSearch({String search}) async {
    if (search.isNotEmpty) {
      _items.clear();
      _showLoadingIndicator();
      await Future.delayed(Duration(seconds: 5));

      var newFetchedItems = List<dynamic>.generate(
          5, (index) => 'Title page:$_currentPage item: $index');
      _items.addAll(newFetchedItems);
      //empty search result
      _items.add(SearchEmptyIndicatorTitle);

      _removeLoadingIndicator();
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
  }
}
