import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/ui_constants.dart';


class ViewModel extends ChangeNotifier {
  static const int ItemRequestThreshold = 15;

  List<String> _items;
  List<String> get items => _items;

  int _currentPage = 0;

  final String searchTerm;
  ViewModel({this.searchTerm}) {
    _items = List<String>.generate(15, (index) => 'Title $index');
    //handleSearch(search: searchTerm);
  }

  Future handleItemCreated(int index,{String search}) async {
    var itemPosition = index + 1;
    var requestMoreData =
        itemPosition % ItemRequestThreshold == 0 && itemPosition != 0;
    var pageToRequest = itemPosition ~/ ItemRequestThreshold;

    if (requestMoreData && pageToRequest > _currentPage) {
      print('handleItemCreated | pageToRequest: $pageToRequest');
      _currentPage = pageToRequest;
      _showLoadingIndicator();

      await Future.delayed(Duration(seconds: 5));
      var newFetchedItems = List<String>.generate(
          15, (index) => 'Title page:$_currentPage item: $index');
      _items.addAll(newFetchedItems);

      _removeLoadingIndicator();
    }
    else{}
  }

  void _showLoadingIndicator() {
    _items.add(LoadingIndicatorTitle);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _items.remove(LoadingIndicatorTitle);
    notifyListeners();
  }

  Future handleSearch({String search})async{
     if(search.isNotEmpty){
    _items.clear();
    _showLoadingIndicator();
    await Future.delayed(Duration(seconds: 5));

    var newFetchedItems = List<String>.generate(
    5, (index) => 'Title page:$_currentPage item: $index');
    _items.addAll(newFetchedItems);
    //empty search result
    _items.add(SearchEmptyIndicatorTitle);

    _removeLoadingIndicator();
    }
     else{}
  }

  Future handleQRcodeSearch({String search})async{
    if(search.isNotEmpty){
      _items.clear();
      _showLoadingIndicator();
      await Future.delayed(Duration(seconds: 5));

      var newFetchedItems = List<String>.generate(
          5, (index) => 'Title page:$_currentPage item: $index');
      _items.addAll(newFetchedItems);
      //empty search result
      _items.add(SearchEmptyIndicatorTitle);

      _removeLoadingIndicator();
    }
    else{}
  }

}