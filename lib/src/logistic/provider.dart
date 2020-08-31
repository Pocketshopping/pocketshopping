import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/locRepo.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

import 'locationUpdate/agentLocUp.dart';

class LogisticRepo {
  static final databaseReference = FirebaseFirestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();



  static Stream<int> fetchMyAvailableAgents(String company)async*{

    yield* databaseReference
        .collection("agentLocationUpdate")
        .where('agentParent',isEqualTo: company)
        .where('availability',isEqualTo: true)
        .where('autoAssigned',isEqualTo: true)
        .snapshots().map((event) {return event.docs.length;});

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

  static Future<List<Agent>> fetchCompanyAgents(String company,{int source = 0 })async{

    try{
     try{
       if(source == 1) throw Exception;
       QuerySnapshot document;
       document = await FirebaseFirestore.instance
           .collection('agent')
           .where('hasEnded',isEqualTo: false)
           .where('agentWorkPlace',isEqualTo: company)
           .get(GetOptions(source: Source.cache))
           .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
       if(document.docs.isEmpty){throw Exception;}
       return Agent.fromListSnap(document.docs);
     }
     catch(_){
       QuerySnapshot document;
       document = await FirebaseFirestore.instance
           .collection('agent')
           .where('hasEnded',isEqualTo: false)
           .where('agentWorkPlace',isEqualTo: company)
           .get(GetOptions(source: Source.serverAndCache))
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); throw Exception;});
       return Agent.fromListSnap(document.docs);
     }
    }
    catch(_){
      return [];
    }

  }

  static Future<List<AgentLocUp>> fetchMyAgents(String company,AgentLocUp last,{int source=0, int count =10})async{

    try{
      QuerySnapshot document;
      if (last == null) {
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .orderBy('startedAt')
            .where('agentParent',isEqualTo: company)
            .limit(count)
            .get(GetOptions(source: Source.server));
      } else {
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .orderBy('startedAt')
            .where('agentParent',isEqualTo: company)
            .startAfter([DateTime.parse(last.startedAt.toDate().toString())])
            .limit(count)
            .get(GetOptions(source: Source.server));
      }
      return AgentLocUp.fromListSnap(document.docs);
    }
    catch(_){
      return [];
    }

  }

  static Future<List<AgentLocUp>> agentUpForTask(String company,AgentLocUp last,{int source=0, int count =10,String keyword=''})async{
    if(keyword.isNotEmpty){
      return searchMyAgent(company, last, keyword,source: 1);
    }
    else{
      return await fetchMyAgents(company,last,source: source,count: count);
    }
  }

  static Future<Map<String,AutoMobile>> fetchMyAutomobile(String company,AutoMobile last)async{
    QuerySnapshot document;
    if (last == null) {
      document = await FirebaseFirestore.instance
          .collection('automobile')
          .orderBy('autoAddedAt',descending: true)
          .where('autoLogistic',isEqualTo: company)
          .limit(10)
          .get(GetOptions(source: Source.server));
    } else {
      document = await FirebaseFirestore.instance
          .collection('automobile')
          .orderBy('autoAddedAt',descending: true)
          .where('autoLogistic',isEqualTo: company)
          .startAfter([DateTime.parse(last.autoAddedAt.toDate().toString())])
          .limit(10)
          .get(GetOptions(source: Source.server));
    }

    return AutoMobile.fromListSnap(document.docs);

  }

  static Future<bool> deleteAutomobile(String autoID,{String lid,int bCount=0, int cCount=0, int vCount=0})async{
    try{
      await FirebaseFirestore.instance.collection('automobile').doc(autoID).delete();
      await databaseReference.collection("merchants").doc(lid).update({
        'bikeCount':bCount,
        'carCount':cCount,
        'vanCount':vCount,
      });
      return true;
    }
    catch(_){return false;}
  }

  static Future<Map<String,AutoMobile>> searchMyAutomobile(String mID, AutoMobile last, String search,{int source=0}) async {
   try{
     QuerySnapshot document;

     if (last == null) {
       try{
         if(source == 1) throw Exception;
         document = await FirebaseFirestore.instance
             .collection('automobile')
             .where('autoLogistic', isEqualTo: mID)
             .where('index', arrayContains: search.toLowerCase())
             .limit(10)
             .get(GetOptions(source: Source.cache))
             .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
         if(document.docs.isEmpty){throw Exception;}
       }
       catch(_){
         document = await FirebaseFirestore.instance
             .collection('automobile')
             .where('autoLogistic', isEqualTo: mID)
             .where('index', arrayContains: search.toLowerCase())
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
       }
     } else {
       try{
         if(source == 1) throw Exception;
         document = await FirebaseFirestore.instance
             .collection('automobile')
             .where('autoLogistic', isEqualTo: mID)
             .where('index', arrayContains: search.toLowerCase())
             .startAfter([DateTime.parse(last.autoAddedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.cache)
         ).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
         if(document.docs.isEmpty){throw Exception;}
       }
       catch(_){
         document = await FirebaseFirestore.instance
             .collection('automobile')
             .where('autoLogistic', isEqualTo: mID)
             .where('index', arrayContains: search.toLowerCase())
             .startAfter([DateTime.parse(last.autoAddedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
       }
     }

     return AutoMobile.fromListSnap(document.docs);
   }
   catch(_){
     return {};
   }
  }

  static Future<List<AgentLocUp>> searchMyAgent(String mID, AgentLocUp last, String search,{int source=0}) async {
    QuerySnapshot document;

    if (last == null) {
      try{
        if(source == 1) throw Exception;
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .where('agentParent', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .limit(10)
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty){throw Exception;}
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .where('agentParent', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    } else {
      try{
        if(source == 1) throw Exception;
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .where('agentParent', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .startAfter([DateTime.parse(last.startedAt.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty){throw Exception;}
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('agentLocationUpdate')
            .where('agentParent', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .startAfter([DateTime.parse(last.startedAt.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    }

    return AgentLocUp.fromListSnap(document.docs);
  }



  static Future<String> saveAutomobile(AutoMobile automobile,{int bCount=0, int cCount=0, int vCount=0}) async {
    DocumentReference bid;
    bid = await databaseReference.collection("automobile").add(automobile.toMap());

    await databaseReference.collection("merchants").doc(automobile.autoLogistic).update({
      'bikeCount':bCount,
      'carCount':cCount,
      'vanCount':vCount,
    });
    return bid.id;
  }

  static Future<bool> updateAgentTrackerLocation(String uid,LocationData point) async {
    try{
      await Future.delayed(Duration(seconds: 10));
      Geoflutterfire geo = Geoflutterfire();
      GeoFirePoint agentLocation = geo.point(latitude: point.latitude, longitude: point.longitude);
      Agent agent = await getOneAgentByUid(uid);
      await databaseReference.collection("agentLocationUpdate").doc(agent.agentID).update({'agentLocation':agentLocation.data})
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      CurrentPathLine cpl = await OrderRepo.getCurrentPathLine(agent.agent);
      if(cpl != null){
        CurrentPathLine temp = await cpl.proximityCheck(Position(latitude: point.latitude,longitude: point.longitude));
        await OrderRepo.setCurrentPathLine(temp);
      }
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> saveAgent(Agent agent, Request request, AgentStatistic agentStatistic) async {
    try{
      DocumentReference bid;
      bid = await databaseReference.collection("agent").add(agent.toMap()).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      request = request.update(requestInitiatorID: bid.id, requestInitiator: 'agent');
      await RequestRepo.save(request);
      await StatisticRepo.updateAgentStatistic(agent.agent);
      await reAssignAutomobile(agent .autoAssigned,agent.agent,);
     /* await LocRepo.update({
        'agentParent':agent.agentWorkPlace,
        'wallet':agent.agentWallet,
        'agentID':bid.id,
        'agentLocation':{},
        'agentAutomobile':agent.autoType,
        'agentName':'',
        'agentTelephone':'',
        'availability':false,
        'pocket':true,
        'parent':true,
        'remitted':true,
        'busy':false,
        'accepted':false,
        'device':'',
        'UpdatedAt':Timestamp.now(),
        'address':'',
        'workPlaceWallet':agent.workPlaceWallet,
        'profile':'',
        'limit':agent.limit,
        'index':[],
        'autoAssigned':true,
      });*/
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> removeAgent(Agent agent,{String logistic,String fcm}) async {
   try{
     //Request request,
     bool isDeleted = await deleteAgentLocUpdate(agent.agentID);
     if(isDeleted){
       //var doc =await RequestRepo.save(request);
       await UserRepo().upDate(uid: agent.agent,role: 'user',bid: 'null');
       await reAssignAutomobile(agent.autoAssigned,'Unassign',isAssigned: false);
       await updateAgent(agent.agentID, {'endDate':Timestamp.now(),'autoAssigned':'Unassign','agentStatus':0,'hasEnded':true,'accepted':false});
       await Utility.updateWallet(uid: agent.agentWallet,cid:agent.workPlaceWallet,type: 2 );
       await Utility.pushNotifier(
         fcm: fcm,
         body: 'You are no longer a rider of $logistic. Contact $logistic for more information',
         title: '$logistic',
         notificationType: 'RemoveRiderResponse',
         /*data: {
            'requestId':doc,
          }*/
       );
     }
     return true;
   }
   catch(_){
     return false;
   }
  }

  static Future<bool> deleteAgentLocUpdate(String agentId)async{
    try{
      await databaseReference.collection('agentLocationUpdate').doc(agentId).delete()
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){return false;}
  }

  static Future<bool> reAssignAutomobile(String autoID,String agent,{bool isAssigned = true}) async {
    try{
      await databaseReference.collection("automobile").doc(autoID).update({
        'autoAssigned':isAssigned,
        'assignedTo':agent,
      })
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> updateAgent(String agent,Map<String,dynamic> data) async {
    try{
      await databaseReference.collection("agent").doc(agent).update(data)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }


  static Future<bool> updateAgentLoc(String agent,Map<String,dynamic> data) async {
    try{
      await databaseReference.collection("agentLocationUpdate").doc(agent).update(data)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }




  static Future<Agent> getOneAgent(String agentID,{int source=0}) async {
    try{
      try{
        if(source == 1)throw Exception;
        var doc = await databaseReference.collection("agent").doc(agentID).get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(!doc.exists){throw Exception;}
        return Agent.fromSnap(doc);
      }
      catch(_){
        var doc = await databaseReference.collection("agent").doc(agentID).get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        return Agent.fromSnap(doc);
      }
    }
    catch(_){
      return null;
    }
  }

  static Future<Agent> getOneAgentByUid(String uid,{int source=0}) async {
    try{
      try{
        if(source == 1)throw Exception;
        var doc = await databaseReference.collection("agent")
            .where('agent',isEqualTo: uid)
            .where('endDate',isEqualTo: null)
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(doc.docs.isEmpty){throw Exception;}
        return doc.docs.isNotEmpty?Agent.fromSnap(doc.docs.first):null;
      }
      catch(_){
        var doc = await databaseReference.collection("agent")
            .where('agent',isEqualTo: uid)
            .where('endDate',isEqualTo: null)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        return doc.docs.isNotEmpty?Agent.fromSnap(doc.docs.first):null;
      }
    }
    catch(_){
      return null;
    }
  }

  static Future<AgentLocUp> getOneAgentLocation(String agentID) async {
   try{
     var doc = await databaseReference.collection("agentLocationUpdate").doc(agentID).get(GetOptions(source: Source.server))
         .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
     return doc.exists?AgentLocUp.fromSnap(doc):null;
   }
   catch(_){
     return null;
   }
  }

  static Stream<AgentLocUp> getOneAgentLocationStream(String agentID) async* {
    yield* databaseReference.collection("agentLocationUpdate").doc(agentID).snapshots().map((event) {return AgentLocUp.fromSnap(event);});

  }


  static Future<AgentLocUp> getOneAgentLocationUsingUid(String uid) async {
    try{
      Agent agent = await getOneAgentByUid(uid);
      var doc = await databaseReference.collection("agentLocationUpdate")
          .doc(agent.agentID).get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return AgentLocUp.fromSnap(doc);
    }
    catch(_){
      return null;
    }
  }

  static Future<bool> makeAgentBusy(String uid,{bool isBusy=true}) async {
    try{
      Agent agent = await getOneAgentByUid(uid);
      //bool remit = await remittance(agent.agentWallet);
      if(agent != null)
      {
        await updateAgentLoc(agent.agentID,{'busy':isBusy})
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        if(!isBusy) {
          revalidateAgentAllowance(uid);
        }
        return isBusy;
      }
      else{
        return false;
      }
    }
    catch(_){
      return false;
    }
  }


  static Future<bool> revalidateAgentAllowance(String uid,) async {
    try{
      User user = await UserRepo.getOneUsingUID(uid);
      if(user != null){
        Wallet agentWallet = await WalletRepo.getWallet(user.walletId);
        Agent agent = await getOneAgentByUid(uid);
        bool remit;
        if(agent != null) {
          remit = await remittance(user.walletId, limit: agent.limit);

          if (agentWallet.pocketUnitBalance < 100) {
            if (agent != null)
              await updateAgentLoc(agent.agentID, {
                'pocket': false,
                if(remit != null) 'remitted': remit
              }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          }
          else {
            await updateAgentLoc(agent.agentID, {
              'pocket': true,
              if(remit != null) 'remitted': remit
            }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          }
        }
        return true;
      }
      else return false;

    }
    catch(_){ return false;}
  }

  static Future<AutoMobile> getAutomobile(String autoID) async {
    try{
      var doc = await databaseReference.collection("automobile").doc(autoID).get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return AutoMobile.fromSnap(doc);
    }
    catch(_){return null;}
  }

  static Future<bool> agentAccept(String agentID, String requestID, String uid) async {
    try{
      await updateAgent(agentID, {'agentStatus': 1, 'startDate': Timestamp.now(),'accepted':true});
      Agent agent = await getOneAgent(agentID);
      var agentAcct = await UserRepo.getOneUsingUID(agent.agent);
      await RequestRepo.clear(requestID);
      await UserRepo().upDate(role: 'rider', uid: uid, bid: agent.agentWorkPlace);
      await UserRepository().changeRole('rider');
      await Utility.updateWallet(uid: agentAcct.walletId,cid:agent.workPlaceWallet,type: 5 );
      await LocRepo.update({
        'agentParent':agent.agentWorkPlace,
        'wallet':agent.agentWallet,
        'agentID':agent.agentID,
        'agentLocation':{},
        'agentAutomobile':agent.autoType,
        'agentName':agentAcct.fname,
        'agentTelephone':agentAcct.telephone,
        'availability':true,
        'pocket':true,
        'parent':true,
        'remitted':true,
        'busy':false,
        'accepted':true,
        'device':agentAcct.notificationID,
        'UpdatedAt':Timestamp.now(),
        'address':'',
        'workPlaceWallet':agent.workPlaceWallet,
        'profile':agentAcct.profile,
        'limit':agent.limit,
        'index':Utility.makeIndexList(agentAcct.fname),
        'autoAssigned':true,
      });
      return true;
    }
    catch(_){return false;}
  }

  static Future<List<String>> getNearByAgent(
      Position mpos, String autoType, {bool isDevice=true}) async {
    List<String> collect = List();
    GeoFirePoint center =
        geo.point(latitude: mpos.latitude, longitude: mpos.longitude);
    var collectionReference = FirebaseFirestore.instance
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
            radius: 1,
            field: 'agentLocation',
            strictMode: true);
    var doc = await alu.first;
    if(isDevice)
    return AgentLocUp.getDeviceToken(AgentLocUp.fromListSnap(doc));
    else
      return AgentLocUp.getAgent(AgentLocUp.fromListSnap(doc));

  }

  static Future<bool> decline(String agentID, String requestID) async {
    try{
      Agent agent  = await getOneAgent(agentID);
      AutoMobile auto = await getAutomobile(agent.autoAssigned);
      await databaseReference.collection('agent').doc(agentID).delete()
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await reAssignAutomobile(auto.autoID, 'Unassign',isAssigned: false);
      //await updateAgent(agentID,{'agentStatus': 0, 'startDate': Timestamp.now()});
      await RequestRepo.clear(requestID);
      return true;
    }
    catch(_){
      return false;
    }
  }


  static Future<bool> alreadyAdded(String logistic, String plate) async {
    try{
      var docs = await databaseReference
          .collection("automobile")
          .where(
        'autoPlateNumber',
        isEqualTo: plate,
      )
          .where('autoLogistic', isEqualTo: logistic)
          .get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return docs.docs.length > 0 ? true : false;
    }
    catch(_){
      return false;
    }
  }



  static Future<Map<String, AutoMobile>> getType(
      String logistic, String type) async {
    try{
      var docs = await databaseReference
          .collection("automobile")
          .where(
        'autoType',
        isEqualTo: type,
      )
          .where('autoLogistic', isEqualTo: logistic)
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return AutoMobile.fromListSnap(docs.docs);
    }
    catch(_){
      return {};
    }
  }

  static Future<Map<String, AutoMobile>> getUnassignedType(
      String logistic, String type,{bool isAssigned = false}) async {
    try{
      var docs = await databaseReference
          .collection("automobile")
          .where(
        'autoType',
        isEqualTo: type,
      )
          .where('autoLogistic', isEqualTo: logistic)
          .where('autoAssigned',isEqualTo: isAssigned)
          .get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return AutoMobile.fromListSnap(docs.docs);
    }
    catch(_){
      return {};
    }
  }

  static Future<Map<String, AutoMobile>> getAllAutomobile(
      String logistic,bool assign) async {
    try{
      var docs = await databaseReference
          .collection("automobile")
          .where('autoAssigned',isEqualTo: assign)
          .where('autoLogistic', isEqualTo: logistic)
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return AutoMobile.fromListSnap(docs.docs);
    }
    catch(_){
      return {};
    }
  }


  static Future<bool> remittance(String wid,{int limit=10000,String key=''})async{
    try{
      var remit = await Utility.generateRemittance(aid: wid,limit: limit,key: key);
      //print(remit);
      if(remit['remittance']){
        return false;
      }
      else{
        return true;
      }
    }
    catch(_){
      return false;
    }
  }

  static Future<Map<String,dynamic>> getRemittance(String wid,{int limit=10000})async{
    var remit = await Utility.generateRemittance(aid: wid,limit: limit);
    return remit;
  }

}
