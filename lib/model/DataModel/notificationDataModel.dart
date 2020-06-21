import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';

class NotificationDataModel extends Data {
  final databaseReference = Firestore.instance;

  String nTitle;
  String nAction;
  String nBody;
  bool nCleared;
  String nReceiver;
  DocumentReference nInitiator;
  String uid;
  String nid;

  NotificationDataModel(
      {this.nTitle,
      this.nAction,
      this.nBody,
      this.nCleared,
      this.nReceiver,
      this.nInitiator,
      this.uid,
      this.nid});

  @override
  Future<String> save() async {
    var nid = await databaseReference.collection("notification").add({
      'notificationTitle': nTitle,
      'notificationAction': nAction,
      'notificationBody': nBody,
      'notificationReceiver': databaseReference.document('users/$nReceiver'),
      'notificationInitiator': nInitiator,
      'notificationCreatedAt': DateTime.now(),
      'notificationCleared': nCleared,
      'notificationClearedAt': null,
    });

    return nid.documentID;
  }

  @override
  Future<List<DocumentSnapshot>> getAll() async {
    var user = databaseReference.collection("users").document(uid);
    var data = await databaseReference
        .collection("notification")
        .where('notificationReceiver', isEqualTo: user)
        .where('notificationCleared', isEqualTo: nCleared)
        .orderBy('notificationCreatedAt', descending: false)
        .getDocuments(source: Source.server);

    return data.documents;
  }

  @override
  Future<void> upDate() async {
    await databaseReference
        .collection("notification")
        .document(nid)
        .updateData({
      'notificationCleared': true,
      'notificationClearedAt': DateTime.now(),
    });
  }
}
