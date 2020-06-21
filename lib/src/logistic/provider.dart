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
        .where('autoAssigned',isEqualTo: true)
        .snapshots().map((event) {return event.documents.length;

    });

  }

  static Future<bool> setAgentLimit(String agentID,{int limit=10000})async{
    try {
      await updateAgent(agentID, {'limit': limit,});
      await updateAgentLoc(agentID, {'limit': limit,});
    return true;
  }catch(_){ return false;}
  }

  static Future<bool> activateDeactivateAgent(String agentID,{bool activate=true})async{
    try {
      await updateAgent(agentID, {'agentStatus': activate ? 1 : 0,});
      await updateAgentLoc(agentID, {'parent': activate,});
      return true;
    }catch(_){ return false;}

  }

  static Future<List<AgentLocUp>> fetchMyAgents(String company,AgentLocUp last)async{
    QuerySnapshot document;
    if (last == null) {
      document = await Firestore.instance
          .collection('agentLocationUpdate')
          .orderBy('startedAt')
          .where('agentParent',isEqualTo: company)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('agentLocationUpdate')
          .orderBy('startedAt')
          .where('agentParent',isEqualTo: company)
          .startAfter([DateTime.parse(last.startedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return AgentLocUp.fromListSnap(document.documents);

  }

  static Future<Map<String,AutoMobile>> fetchMyAutomobile(String company,AutoMobile last)async{
    QuerySnapshot document;
    if (last == null) {
      document = await Firestore.instance
          .collection('automobile')
          .orderBy('autoAddedAt',descending: true)
          .where('autoLogistic',isEqualTo: company)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('automobile')
          .orderBy('autoAddedAt',descending: true)
          .where('autoLogistic',isEqualTo: company)
          .startAfter([DateTime.parse(last.autoAddedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return AutoMobile.fromListSnap(document.documents);

  }

  static Future<bool> deleteAutomobile(String autoID)async{
    try{
      await Firestore.instance
          .collection('automobile').document(autoID).delete();
      return true;
    }
    catch(_){return false;}
  }

  static Future<Map<String,AutoMobile>> searchMyAutomobile(
      String mID, AutoMobile last, String search) async {
    QuerySnapshot document;

    if (last == null) {
      document = await Firestore.instance
          .collection('automobile')
          .where('autoLogistic', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('automobile')
          .where('autoLogistic', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .startAfter([DateTime.parse(last.autoAddedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return AutoMobile.fromListSnap(document.documents);
  }

  static Future<List<AgentLocUp>> searchMyAgent(
      String mID, AgentLocUp last, String search) async {
    QuerySnapshot document;

    if (last == null) {
      document = await Firestore.instance
          .collection('agentLocationUpdate')
          .where('agentParent', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('agentLocationUpdate')
          .where('agentParent', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .startAfter([DateTime.parse(last.startedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return AgentLocUp.fromListSnap(document.documents);
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
    await reAssignAutomobile((agent as Agent).autoAssigned,agent.agent,);
    return bid.documentID;
  }

  static Future<bool> reAssignAutomobile(String autoID,String agent,{bool isAssigned = true}) async {
    try{
      await databaseReference.collection("automobile").document(autoID).updateData({
        'autoAssigned':isAssigned,
        'assignedTo':agent,
      });
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> updateAgent(String agent,Map<String,dynamic> data) async {
    try{
      await databaseReference.collection("agent").document(agent).updateData(data);
      return true;
    }
    catch(_){
      return false;
    }
  }


  static Future<bool> updateAgentLoc(String agent,Map<String,dynamic> data) async {
    try{
      await databaseReference.collection("agentLocationUpdate").document(agent).updateData(data);
      return true;
    }
    catch(_){
      return false;
    }
  }




  static Future<Agent> getOneAgent(String agentID) async {
    var doc = await databaseReference.collection("agent").document(agentID).get(source: Source.serverAndCache);
    return Agent.fromSnap(doc);
  }

  static Future<Agent> getOneAgentByUid(String uid) async {
    var doc = await databaseReference.collection("agent")
        .where('agent',isEqualTo: uid)
        .where('endDate',isEqualTo: null)
        .getDocuments(source: Source.serverAndCache);
    return doc.documents.isNotEmpty?Agent.fromSnap(doc.documents.first):null;
  }

  static Future<AgentLocUp> getOneAgentLocation(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").document(agentID).get(source: Source.serverAndCache);
    return doc.exists?AgentLocUp.fromSnap(doc):null;
  }

  static Future<AgentLocUp> getOneAgentLocationUsingUid(String uid) async {
    Agent agent = await getOneAgentByUid(uid);
    var doc = await databaseReference.collection("agentLocationUpdate").document(agent.agentID).get(source: Source.serverAndCache);
    return AgentLocUp.fromSnap(doc);
  }

  static Future<bool> makeAgentBusy(String uid,{bool isBusy=true}) async {
    Agent agent = await getOneAgentByUid(uid);
    //bool remit = await remittance(agent.agentWallet);
    await updateAgentLoc(agent.agentID,{'busy':isBusy});
    if(!isBusy) {
      revalidateAgentAllowance(uid);
    }
    return isBusy;
  }


  static Future<void> revalidateAgentAllowance(String uid,) async {
    User user = await UserRepo.getOneUsingUID(uid);
    Wallet agentWallet = await WalletRepo.getWallet(user.walletId);
    Agent agent = await getOneAgentByUid(uid);
    bool remit;
    if(agent != null)
    remit = await remittance(user.walletId,limit:agent.limit);

    if(agentWallet.pocketUnitBalance < 100) {
      if (agent != null)
        await updateAgentLoc(agent.agentID,{
          'pocket': false,
          if(remit!=null) 'remitted':remit
        });
    }
    else{
      await updateAgentLoc(agent.agentID,{
        'pocket': true,
        if(remit!=null) 'remitted':remit
      });
    }
  }

  static Future<AutoMobile> getAutomobile(String autoID) async {
    var doc = await databaseReference.collection("automobile").document(autoID).get(source: Source.serverAndCache);
    return AutoMobile.fromSnap(doc);
  }

  static Future<bool> accept(String agentID, String requestID, String uid) async {
    await updateAgent(agentID, {'agentStatus': 'ACTIVE', 'startDate': Timestamp.now()});
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
        .where('autoAssigned', isEqualTo: true)
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
    await updateAgent(agentID,{'agentStatus': 'DECLINE', 'startDate': Timestamp.now()});
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
        .getDocuments(source: Source.serverAndCache);
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
        .getDocuments(source: Source.serverAndCache);
    return AutoMobile.fromListSnap(docs.documents);
  }

  static Future<Map<String, AutoMobile>> getUnassignedType(
      String logistic, String type,{bool isAssigned = false}) async {
    var docs = await databaseReference
        .collection("automobile")
        .where(
      'autoType',
      isEqualTo: type,
    )
        .where('autoLogistic', isEqualTo: logistic)
        .where('autoAssigned',isEqualTo: isAssigned)
        .getDocuments(source: Source.serverAndCache);
    return AutoMobile.fromListSnap(docs.documents);
  }

  static Future<Map<String, AutoMobile>> getAllAutomobile(
      String logistic,bool assign) async {
    var docs = await databaseReference
        .collection("automobile")
    .where('autoAssigned',isEqualTo: assign)
        .where('autoLogistic', isEqualTo: logistic)
        .getDocuments(source: Source.serverAndCache);
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

  static Future<Map<String,dynamic>> getRemittance(String wid,{int limit=10000})async{
    var remit = await Utility.generateRemittance(aid: wid,limit: limit);
    return remit;
  }

}
