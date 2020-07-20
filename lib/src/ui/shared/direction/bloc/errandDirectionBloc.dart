import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:rxdart/rxdart.dart';



class ErrandDirectionBloc {
  ErrandDirectionBloc._internal();

  static final ErrandDirectionBloc instance = ErrandDirectionBloc._internal();

  BehaviorSubject<CurrentPathLine> _pathController = BehaviorSubject<CurrentPathLine>();

  Stream<CurrentPathLine> get currentPath {
    return _pathController;
  }

  void newPath(CurrentPathLine path) {
    _pathController.sink.add(path);
  }

  void clearPath() {
    _pathController.sink.add(null);
  }

  void dispose() {
    _pathController?.close();
  }
}
