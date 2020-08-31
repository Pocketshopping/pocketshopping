import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketshopping/src/channels/repository/channelObj.dart';

class ChannelRepo {

  static final databaseReference = FirebaseFirestore.instance;
  static final FirebaseMessaging _fcm = FirebaseMessaging();


  static Future<Channels> get(String mid) async {
    var docs = await databaseReference.collection("channels").doc(mid).get(GetOptions(source: Source.serverAndCache));
    return Channels.fromSnap(docs);
  }

  static Future<String> getAgentChannel(String agent)async{
    var docs = await databaseReference.collection("users").doc(agent).get(GetOptions(source: Source.serverAndCache));
    return docs.data()['notificationID'];
  }

  static Future<void> update(String mid, String uid) async {
    String fcmToken = await _fcm.getToken();
    var docs = await databaseReference.collection("channels").doc(mid).get(GetOptions(source: Source.serverAndCache));
    var data = Channels.toUpdate(docs, uid, fcmToken);
    await databaseReference
        .collection("channels")
        .doc(mid)
        .update(data);
    //print('toupdate $data');
  }
}
