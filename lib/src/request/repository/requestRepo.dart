import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';

class RequestRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(dynamic request) async {
    DocumentReference bid;
    bid = await databaseReference.collection("request").add(request.toMap());
    return bid.documentID;
  }

  static Future<List<Request>> getAll(String uid) async {
    var docs = await databaseReference
        .collection("request")
        .orderBy('requestCreatedAt', descending: true)
        .where('requestReceiver', isEqualTo: uid)
        .where('requestCleared', isEqualTo: false)
        .getDocuments();
    return Request.fromListSnap(docs.documents);
  }

  static Future<bool> clear(String requestID) async {
    await databaseReference
        .collection("request")
        .document(requestID)
        .updateData(
            {'requestCleared': true, 'requestClearedAt': Timestamp.now()});
    return true;
  }
}
