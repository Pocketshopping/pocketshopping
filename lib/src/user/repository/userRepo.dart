import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  final  databaseReference = Firestore.instance;
  final  _fcm = FirebaseMessaging();

  UserRepo();

  Future<Map<String, dynamic>> save(User user) async {
    Map<String, dynamic> data = {};
    String fcmToken = await _fcm.getToken();
    await databaseReference.collection("users").document(user.uid).setData({
      'fname': user.fname.trim(),
      'email': user.email.trim(),
      'telephone': user.telephone.trim(),
      'profile': user.profile.trim(),
      'notificationID': fcmToken,
      'defaultAddress': user.defaultAddress.trim(),
      'role': user.role.trim(),
      'business': user.bid,
      'createdAt': DateTime.now(),
      'behaviour': user.behaviour,
      'country': user.country,
      'wallet': user.walletId
    });

    return data;
  }

  Future<bool> upDate({
    String fname,
    String email,
    String telephone,
    String role,
    String notificationID,
    String defaultAddress,
    String profile,
    String uid,
    String bid,
    String behaviour,
    String country,
  }) async {
    String fcmToken = await _fcm.getToken();
    await databaseReference
        .collection("users")
        .document(uid)
        .updateData(makeData(
          fcmToken: fcmToken,
          fname: fname,
          uid: uid,
          email: email,
          telephone: telephone,
          role: role,
          notificationID: notificationID,
          defaultAddress: defaultAddress,
          profile: profile,
          bid: bid,
          behaviour: behaviour,
          country: country,
        ));

    return true;
  }

  Map<String, dynamic> makeData({
    String fcmToken,
    String fname,
    String email,
    String telephone,
    String role,
    String notificationID,
    String defaultAddress,
    String profile,
    String uid,
    String bid,
    String behaviour,
    String country,
  }) {
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
      data['behaviour'] = databaseReference.document('userBehaviour/' + behaviour);

    //print(data.toString());
    return data;
  }

  Future<Session> getOne({String uid}) async {
    Merchant merchant;
    User user;
    Agent agent;
    Staff staff;
    var doc = await Firestore.instance.collection('users').document(uid).get(source: Source.serverAndCache);
    user = User.fromEntity(UserEntity.fromSnapshot(doc));

    if (user.role == 'admin' || user.role == 'staff') {
      var temp = await user.bid.get(source: Source.serverAndCache);
      merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(temp));
      var _agent = await Firestore.instance
          .collection('agent')
          .where('agent', isEqualTo: uid)
          .getDocuments(source: Source.serverAndCache);
      if (_agent.documents.length > 0)
        agent = Agent.fromSnap(_agent.documents[0]);
    }
    return Session(user: user, merchant: merchant, agent: agent, staff: staff);
  }

  Stream<Merchant> getMyMerchant(DocumentReference mid) {
    return Firestore.instance
        .collection('merchants')
        .document(mid.documentID)
        .snapshots()
        .map((merchantSnap) {
      return Merchant.fromEntity(MerchantEntity.fromSnapshot(merchantSnap));
    });
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
        .getDocuments(source: Source.serverAndCache);
    if (document.documents.length > 0)
      return false;
    else
      return true;
  }

  Future<List<DocumentSnapshot>> getOneUsingEmail(String email) async {
    var document = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments(source: Source.serverAndCache);
    if (document.documents.length > 0)
      return document.documents;
    else
      return [];
  }

  Future<dynamic> getOneUsingWallet(String wallet) async {
    var document = await Firestore.instance
        .collection('users')
        .where('wallet', isEqualTo: wallet)
        .getDocuments(source: Source.serverAndCache);
    if (document.documents.length > 0) if (document.documents[0].data['role'] ==
        'user')
      return User.fromEntity(UserEntity.fromSnapshot(document.documents[0]));
    else
      return document.documents[0].data['role'];
    else
      return null;
  }


  static Future<User> getOneUsingUID(String uid) async {
    if(uid == null)
      return null;
    if(uid.isEmpty)
      return null;

    try{
      var document = await Firestore.instance
          .collection('users').document(uid).get(source: Source.serverAndCache);
      return User.fromEntity(UserEntity.fromSnapshot(document));
    }catch(_){
      return null;
    }
  }
}
