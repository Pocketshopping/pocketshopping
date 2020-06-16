import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

import 'locationUpdate/agentLocUp.dart';

class LogisticRepo {
  static final databaseReference = Firestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();



  static Stream<int> fetchMyAvailableAgents(String company)async*{

    yield* databaseReference
        .collection("agentLocationUpdate")
        .where('agentParent',isEqualTo: company)
        .where('availability',isEqualTo: true)
        .snapshots().map((event) {return event.documents.length;

    });

  }



  static Future<String> saveAutomobile(dynamic automobile) async {
    DocumentReference bid;
    bid = await databaseReference
        .collection("automobile")
        .add(automobile.toMap());
    return bid.documentID;
  }

  static Future<String> saveAgent(dynamic agent, Request request, AgentStatistic agentStatistic) async {
    DocumentReference bid;
    bid = await databaseReference.collection("agent").add(agent.toMap());
    request = request.update(requestInitiatorID: bid.documentID, requestInitiator: 'agent');
    await RequestRepo.save(request);
    await StatisticRepo.updateAgentStatistic(agent.agent);

    return bid.documentID;
  }

  static Future<Agent> getOneAgent(String agentID) async {
    var doc = await databaseReference.collection("agent").document(agentID).get();
    return Agent.fromSnap(doc);
  }

  static Future<Agent> getOneAgentByUid(String uid) async {
    var doc = await databaseReference.collection("agent")
        .where('agent',isEqualTo: uid)
        .where('endDate',isEqualTo: null)
        .getDocuments();
    return doc.documents.isNotEmpty?Agent.fromSnap(doc.documents.first):null;
  }

  static Future<AgentLocUp> getOneAgentLocation(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").document(agentID).get();
    return AgentLocUp.fromSnap(doc);
  }

  static Future<AgentLocUp> getOneAgentLocationUsingUid(String uid) async {
    Agent agent = await getOneAgentByUid(uid);
    var doc = await databaseReference.collection("agentLocationUpdate").document(agent.agentID).get();
    return AgentLocUp.fromSnap(doc);
  }

  static Future<bool> makeAgentBusy(String uid,{bool isBusy=true}) async {
    Agent agent = await getOneAgentByUid(uid);
    //bool remit = await remittance(agent.agentWallet);
    await databaseReference.collection("agentLocationUpdate").document(agent.agentID).updateData({
      'busy':isBusy,
     // 'remitted': remit,
    });

    if(!isBusy) {
      revalidateAgentAllowance(uid);
    }
    return isBusy;
  }


  static Future<void> revalidateAgentAllowance(String uid,) async {
    User user = await UserRepo.getOneUsingUID(uid);
    Wallet agentWallet = await WalletRepo.getWallet(user.walletId);
    bool remit = await remittance(user.walletId);
    Agent agent = await getOneAgentByUid(uid);
    if(agentWallet.pocketUnitBalance < 100) {
      if (agent != null)
        databaseReference.collection("agentLocationUpdate").document(
            agent.agentID).updateData({
          'pocket': false,
          'remitted':remit
        });
    }
    else{
      databaseReference.collection("agentLocationUpdate").document(
          agent.agentID).updateData({
        'pocket': true,
        'remitted':remit
      });
    }
  }

  static Future<AutoMobile> getAutomobile(String autoID) async {
    var doc = await databaseReference.collection("automobile").document(autoID).get();
    return AutoMobile.fromSnap(doc);
  }

  static Future<bool> accept(String agentID, String requestID, String uid) async {
    await databaseReference
        .collection("agent")
        .document(agentID)
        .updateData({'agentStatus': 'ACTIVE', 'startDate': Timestamp.now()});
    var agent = await getOneAgent(agentID);
    var agentAcct = await UserRepo.getOneUsingUID(agent.agent);
    await RequestRepo.clear(requestID);
    await UserRepo().upDate(role: 'staff', uid: uid, bid: agent.agentWorkPlace);
    await UserRepository().changeRole('staff');
    await Utility.updateWallet(uid: agentAcct.walletId,cid:agent.workPlaceWallet,type: 5 );
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


  static Future<bool> remittance(String wid,{int limit=10000})async{
    var remit = await Utility.generateRemittance(aid: wid,limit: limit);
    //print(remit);
    if(remit['remittance']){
      return false;
    }
    else{
      return true;
    }
  }

  static Future<dynamic> getRemittance(String wid,{int limit=10000})async{
    var remit = await Utility.generateRemittance(aid: wid,limit: limit);
    return remit;
  }

}
