import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/user/package_user.dart';

import 'locationUpdate/agentLocUp.dart';

class LogisticRepo {
  static final databaseReference = Firestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  static Future<String> saveAutomobile(dynamic automobile) async {
    DocumentReference bid;
    bid = await databaseReference
        .collection("automobile")
        .add(automobile.toMap());
    return bid.documentID;
  }

  static Future<String> saveAgent(dynamic agent, Request request) async {
    DocumentReference bid;
    bid = await databaseReference.collection("agent").add(agent.toMap());
    request = request.update(
        requestInitiatorID: bid.documentID, requestInitiator: 'agent');
    await RequestRepo.save(request);
    return bid.documentID;
  }

  static Future<Agent> getOneAgent(String agentID) async {
    var doc = await databaseReference.collection("agent").document(agentID).get();
    return Agent.fromSnap(doc);
  }

  static Future<AgentLocUp> getOneAgentLocation(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").document(agentID).get();
    return AgentLocUp.fromSnap(doc);
  }

  static Future<AutoMobile> getAutomobile(String autoID) async {
    var doc = await databaseReference.collection("automobile").document(autoID).get();
    return AutoMobile.fromSnap(doc);
  }

  static Future<bool> accept(
      String agentID, String requestID, String uid) async {
    await databaseReference
        .collection("agent")
        .document(agentID)
        .updateData({'agentStatus': 'ACTIVE', 'startDate': Timestamp.now()});
    var agent = await getOneAgent(agentID);
    await RequestRepo.clear(requestID);
    await UserRepo().upDate(role: 'staff', uid: uid, bid: agent.agentWorkPlace);
    await UserRepository().changeRole('staff');

    return true;
  }

  static Future<List<String>> getNearByAgent(
      Position mpos, String autoType) async {
    List<String> collect = List();
    GeoFirePoint center =
        geo.point(latitude: mpos.latitude, longitude: mpos.longitude);
    var collectionReference = Firestore.instance
        .collection('agentLocationUpdate')
        .where('availability', isEqualTo: true)
        .where('pocket', isEqualTo: true)
        .where('parent', isEqualTo: true)
        .where('remitted', isEqualTo: true)
        .where('busy', isEqualTo: false)
        .where('agentAutomobile', isEqualTo: autoType)
        .limit(5);
    Stream<List<DocumentSnapshot>> alu = geo
        .collection(collectionRef: collectionReference)
        .within(
            center: center,
            radius: 10,
            field: 'agentLocation',
            strictMode: true);
    var doc = await alu.first;
    return AgentLocUp.getDeviceToken(AgentLocUp.fromListSnap(doc));
  }

  static Future<bool> decline(String agentID, String requestID) async {
    await databaseReference
        .collection("agent")
        .document(agentID)
        .updateData({'agentStatus': 'DECLINE', 'startDate': Timestamp.now()});
    await RequestRepo.clear(requestID);
    return true;
  }

  static Future<bool> alreadyAdded(String logistic, String plate) async {
    var docs = await databaseReference
        .collection("automobile")
        .where(
          'autoPlateNumber',
          isEqualTo: plate,
        )
        .where('autoLogistic', isEqualTo: logistic)
        .getDocuments();
    return docs.documents.length > 0 ? true : false;
  }

  static Future<Map<String, AutoMobile>> getType(
      String logistic, String type) async {
    var docs = await databaseReference
        .collection("automobile")
        .where(
          'autoType',
          isEqualTo: type,
        )
        .where('autoLogistic', isEqualTo: logistic)
        .getDocuments();
    return AutoMobile.fromListSnap(docs.documents);
  }
}
