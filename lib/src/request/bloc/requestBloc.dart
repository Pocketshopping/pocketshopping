import 'package:rxdart/rxdart.dart';



class RequestBloc {
  RequestBloc._internal();

  static final RequestBloc instance = RequestBloc._internal();

  BehaviorSubject<int> _requestCounterController = BehaviorSubject<int>();

  Stream<int> get requestCounter {
    return _requestCounterController;
  }

  void newCount(int count) {
    _requestCounterController.sink.add(count);
  }

  void clearCount() {
    _requestCounterController.sink.add(0);
  }

  void dispose() {
    _requestCounterController?.close();
  }
}
