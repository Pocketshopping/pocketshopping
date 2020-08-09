import 'package:pocketshopping/src/user/package_user.dart';
import 'package:rxdart/rxdart.dart';



class UserBroadcaster {
  UserBroadcaster._internal();

  static final UserBroadcaster instance = UserBroadcaster._internal();

  BehaviorSubject<User> _userBroadcasterStreamController = BehaviorSubject<User>();

  Stream<User> get userStream {
    return _userBroadcasterStreamController;
  }

  void newUser(User user) {
    _userBroadcasterStreamController.sink.add(user);
  }

  void clearUser() {
    _userBroadcasterStreamController.sink.add(null);
  }

  void dispose() {
    _userBroadcasterStreamController?.close();
  }
}
