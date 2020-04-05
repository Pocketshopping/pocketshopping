
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

  NotificationDataModel({
    this.nTitle,
    this.nAction,
    this.nBody,
    this.nCleared,
    this.nReceiver,
    this.nInitiator
});


  @override
  Future<String> save() async {
    var nid = await databaseReference.collection("notification")
        .add({
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

}