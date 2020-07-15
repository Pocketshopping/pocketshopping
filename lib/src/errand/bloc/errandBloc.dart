import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:rxdart/rxdart.dart';

class ErrandBloc {
  ErrandBloc._internal();

  static final ErrandBloc instance = ErrandBloc._internal();

  BehaviorSubject<List<AgentLocUp>> _errandStreamController = BehaviorSubject<List<AgentLocUp>>();

  Stream<List<AgentLocUp>> get errandStream {
    return _errandStreamController;
  }

  void newAgentLocList(List<AgentLocUp> agentLoc) {
    _errandStreamController.sink.add(agentLoc);
  }

  void clearAgentLocList() {
    _errandStreamController.sink.add(null);
  }

  void dispose() {
    _errandStreamController?.close();
  }
}
