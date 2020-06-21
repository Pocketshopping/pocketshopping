import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketshopping/src/channels/repository/channelObj.dart';

class ChannelRepo {

  static final databaseReference = Firestore.instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging();


  static Future<Channels> get(String mid) async {
    var docs = await databaseReference.collection("channels").document(mid).get(source: Source.serverAndCache);
    return Channels.fromSnap(docs);
  }

  static Future<String> getAgentChannel(String agent)async{
    var docs = await databaseReference.collection("users").document(agent).get(source: Source.serverAndCache);
    return docs.data['notificationID'];
  }

  static Future<void> update(String mid, String uid) async {
    String fcmToken = await _fcm.getToken();
    var docs = await databaseReference.collection("channels").document(mid).get(source: Source.serverAndCache);
    var data = Channels.toUpdate(docs, uid, fcmToken);
    await databaseReference
        .collection("channels")
        .document(mid)
        .updateData(data);
    //print('toupdate $data');
  }
}
