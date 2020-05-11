import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepo {
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

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
      'wallet':user.walletId
    });

    return data;
  }

  @override
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
    bool success = false;
    String fcmToken = await _fcm.getToken();
    print(fcmToken);
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
        ))
        .then((value) => success = true);

    return success;
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
      data['behaviour'] =
          databaseReference.document('userBehaviour/' + behaviour);

    //print(data.toString());
    return data;
  }

  Stream<Session> getOne({String uid}) async* {
    Merchant merchant;
    User user;
    var userRef = Firestore.instance.document('users/$uid');
    var temp = await Firestore.instance
        .collection('merchants')
        .where('businessCreator', isEqualTo: userRef)
        .getDocuments();
    yield* Firestore.instance
        .collection('users')
        .document(uid)
        .snapshots()
        .map((snapshot) {
      user = User.fromEntity(UserEntity.fromSnapshot(snapshot));

      if (temp.documents.length > 0) {
        merchant =
            Merchant.fromEntity(MerchantEntity.fromSnapshot(temp.documents[0]));
      }
      return Session(user: user, merchant: merchant);
    });
  }

  Stream<Merchant> getMyMerchant(DocumentReference mid) {
    return Firestore.instance
        .collection('merchants')
        .document(mid.documentID)
        .snapshots()
        .map((merchantSnap) {
      print('Roooooole: ${merchantSnap.documentID}');
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
