import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';

class RequestRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<String> save(dynamic request) async {
    try{
      DocumentReference bid;
      bid = await databaseReference.collection("request").add(request.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return bid.id;
    }
    catch(_){
      return '';
    }
  }

  static Future<List<Request>> getAll(String uid) async {
    try{
      var docs = await databaseReference
          .collection("request")
          .orderBy('requestCreatedAt', descending: true)
          .where('requestReceiver', isEqualTo: uid)
          .where('requestCleared', isEqualTo: false)
          .get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return Request.fromListSnap(docs.docs);
    }
    catch(_){
      return [];
    }
  }

  static Future<List<Request>> getSpecific(String uid,String wid) async {
    try{
      var docs = await databaseReference
          .collection("request")
          .where('requestReceiver', isEqualTo: uid)
          .where('requestInitiatorID', isEqualTo: wid)
          .get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return Request.fromListSnap(docs.docs);
    }
    catch(_){
      return [];
    }
  }

  static Future<bool> deleteSpecific(String uid,String wid) async {
    try{
      WriteBatch batch  =  databaseReference.batch();
      List<Request> requests = await getSpecific(uid, wid);
      requests.forEach((request) async{
        batch.delete(databaseReference.collection("request").doc(request.requestID));
      });
      await batch.commit();
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> clear(String requestID) async {
    try{
      await databaseReference
          .collection("request")
          .doc(requestID)
          .update(
          {'requestCleared': true, 'requestClearedAt': Timestamp.now()})
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<List<Request>> getSacked(String uid) async {
  try{
    var docs = await databaseReference
        .collection("request")
        .orderBy('requestCreatedAt', descending: true)
        .where('requestReceiver', isEqualTo: uid)
        .where('requestCleared', isEqualTo: false)
        .where('requestAction', isEqualTo: "REMOVEWORK")
        .get(GetOptions(source: Source.serverAndCache))
        .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
    return Request.fromListSnap(docs.docs);
  }
  catch(_){
    return [];
  }
  }
}
