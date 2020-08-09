import 'package:rxdart/rxdart.dart';



class PromoBloc {
  PromoBloc._internal();

  static final PromoBloc instance = PromoBloc._internal();

  BehaviorSubject<bool> _promoStreamController = BehaviorSubject<bool>();

  Stream<bool> get promoStream {
    return _promoStreamController;
  }

  void reload(bool reload) {
    _promoStreamController.sink.add(reload);
  }


  void dispose() {
    _promoStreamController?.close();
  }
}
