import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:rxdart/rxdart.dart';



class SessionBloc {
  SessionBloc._internal();

  static final SessionBloc instance = SessionBloc._internal();

  BehaviorSubject<UserRepository> _sessionStreamController = BehaviorSubject<UserRepository>();

  Stream<UserRepository> get sessionStream {
    return _sessionStreamController;
  }

  void addSession(UserRepository session) {
    _sessionStreamController.sink.add(session);
  }

  Future<UserRepository> getSession() async{

    return await _sessionStreamController.first;
  }

  void clearServer() {
    _sessionStreamController.sink.add(null);
  }

  void dispose() {
    _sessionStreamController?.close();
  }
}
