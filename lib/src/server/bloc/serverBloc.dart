import 'package:rxdart/rxdart.dart';



class ServerBloc {
  ServerBloc._internal();

  static final ServerBloc instance = ServerBloc._internal();

  BehaviorSubject<Map<String,dynamic>> _serverStreamController = BehaviorSubject<Map<String,dynamic>>();

  Stream<Map<String,dynamic>> get serverStream {
    return _serverStreamController;
  }

  void addServer(Map<String,dynamic> server) {
    _serverStreamController.sink.add(server);
  }

  Future<String> getServerKey() async{
    var data =  await _serverStreamController.first;
    return data['key'];
  }

  void clearServer() {
    _serverStreamController.sink.add(null);
  }

  void dispose() {
    _serverStreamController?.close();
  }
}
