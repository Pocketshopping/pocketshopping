import 'package:rxdart/rxdart.dart';

class LocalNotification {
  final String type;
  final Map data;

  LocalNotification(this.type, this.data);
}

class NotificationsBloc {
  NotificationsBloc._internal();

  static final NotificationsBloc instance = NotificationsBloc._internal();

  BehaviorSubject<LocalNotification> _notificationsStreamController =
      BehaviorSubject<LocalNotification>();

  Stream<LocalNotification> get notificationsStream {
    return _notificationsStreamController;
  }

  void newNotification(LocalNotification notification) {
    _notificationsStreamController.sink.add(notification);
  }

  void clearNotification() {
    _notificationsStreamController.sink.add(null);
  }

  void dispose() {
    _notificationsStreamController?.close();
  }
}
