import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData extends Data {
  String fname;
  String email;
  String telephone;
  String role;
  String notificationID;
  String defaultAddress;
  String profile;
  String uid;
  String bid;
  String behaviour;
  String country;
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  UserData(
      {this.uid,
      this.email,
      this.telephone,
      this.fname,
      this.role = '',
      this.notificationID = '',
      this.defaultAddress = '',
      this.profile = '',
      this.bid,
      this.behaviour,
      this.country});

  @override
  Future<Map<String, dynamic>> save() async {
    Map<String, dynamic> data = {};
    String fcmToken = await _fcm.getToken();
    await databaseReference.collection("users").document(uid).setData({
      'fname': fname.trim(),
      'email': email.trim(),
      'telephone': telephone.trim(),
      'profile': profile.trim(),
      'notificationID': fcmToken,
      'defaultAddress': defaultAddress.trim(),
      'role': role.trim(),
      'business': '',
      'createdAt': DateTime.now(),
      'behaviour': '',
      'country': country
    });
    data = await getOne();

    return data;
  }

  @override
  Future<bool> upDate() async {
    bool success = false;
    String fcmToken = await _fcm.getToken();
    // print('updated');
    await databaseReference
        .collection("users")
        .document(uid)
        .updateData(makeData(fcmToken))
        .then((value) => success = true);

    return success;
  }

  Map<String, dynamic> makeData(String fcmToken) {
    Map<String, dynamic> data = {};

    if (email != null && email.isNotEmpty) data['email'] = email;
    if (telephone != null && telephone.isNotEmpty)
      data['telephone'] = telephone;
    if (role != null && role.isNotEmpty) data['role'] = role;
    if (notificationID == 'fcm') data['notificationID'] = fcmToken;
    if (defaultAddress != null && defaultAddress.isNotEmpty)
      data['defaultAddress'] = defaultAddress;
    if (profile != null && profile.isNotEmpty) data['profile'] = profile;
    if (bid != null && bid.isNotEmpty)
      data['business'] = databaseReference.document('merchants/' + bid);
    if (behaviour != null && behaviour.isNotEmpty)
      data['behaviour'] =
          databaseReference.document('userBehaviour/' + behaviour);

    //print(data.toString());
    return data;
  }

  @override
  Future<Map<String, dynamic>> getOne() async {
    Map<String, dynamic> collection = {};
    var data;
    var document = await Firestore.instance
        .collection('users')
        .document(uid)
        .get(source: Source.server);
    collection.addAll(document.data);

    if (document.data['role'].toString() == 'staff') {
      var userRef = Firestore.instance.collection('users').document(uid);
      var tdata = await Firestore.instance
          .collection('staff')
          .where('staff', isEqualTo: userRef)
          .getDocuments(source: Source.server);
      collection.putIfAbsent("staffID", () => tdata.documents[0].documentID);
      collection.addAll(tdata.documents[0].data);
    }

    if (document.data['business'].toString().isNotEmpty &&
        (document.data['role'].toString() == 'admin' ||
            document.data['role'].toString() == 'staff')) {
      data = await document.data['business'].get(source: Source.server);
      collection.putIfAbsent("merchantID", () => data.documentID);
      collection.addAll(data.data);
    }

    return collection;
  }

  FirstTimer() async {
    print('am working over here');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('uid', 'newUser');
  }

  Future<bool> IsNew(String email) async {
    var document = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    if (document.documents.length > 0)
      return false;
    else
      return true;
  }

  Future<List<DocumentSnapshot>> getOneUsingEmail(String email) async {
    var document = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    if (document.documents.length > 0)
      return document.documents;
    else
      return [];
  }
}
