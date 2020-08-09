import 'package:rxdart/rxdart.dart';



class CategoryBloc {
  CategoryBloc._internal();

  static final CategoryBloc instance = CategoryBloc._internal();

  BehaviorSubject<List<String>> _categoryStreamController = BehaviorSubject<List<String>>();

  Stream<List<String>> get categoryStream {
    return _categoryStreamController;
  }

  void addNewCategory(List<String> category) {
    _categoryStreamController.sink.add(category);
  }

  Future<List<String>> getLastCategories() async{
    print(await _categoryStreamController.first);
    return await _categoryStreamController.first;
  }

  void clearRefresh() {
    _categoryStreamController.sink.add([]);
  }

  void dispose() {
    _categoryStreamController?.close();
  }
}
