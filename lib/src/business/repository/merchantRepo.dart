import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/component/dynamicLinks.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class MerchantRepo {
  final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  Geoflutterfire geo = Geoflutterfire();

  Future<String> save({
    String bID,
    String uid,
    String bName,
    String bAddress,
    String bCategory,
    String bDelivery,
    String bDescription,
    String bPhoto,
    String bOpenTime,
    String bCloseTime,
    String bTelephone,
    String bTelephone2,
    String bEmail,
    Map<String, dynamic> bSocial,
    GeoPoint bGeopint,
    bool isBranch,
    String bParent,
    String bStatus,
    String bCountry,
    String bBranchUnique,
  }) async {
    DocumentReference bid;
    GeoFirePoint merchantLocation =
        geo.point(latitude: bGeopint.latitude, longitude: bGeopint.longitude);
    bid = await databaseReference.collection("merchants").add({
      'businessCreator': databaseReference.document('users/' + uid),
      'businessName': bName,
      'businessAdress': bAddress,
      'businessCategory': bCategory,
      'businessOpenTime': bOpenTime,
      'businessCloseTime': bCloseTime,
      'businessPhoto': bPhoto,
      'businessTelephone': bTelephone,
      'businessTelephone2': bTelephone2,
      'businessEmail': bEmail,
      'businessGeopint': merchantLocation.data,
      'businessDelivery': bDelivery,
      'businessSocials': bSocial,
      'businessDescription': bDescription,
      'isBranch': isBranch,
      'businessParent': databaseReference.document('merchants/' + bParent),
      'businessID': bID,
      'businessStatus': bStatus,
      'businessCountry': bCountry,
      'branchUnique': bBranchUnique,
      'businessCreatedAt': DateTime.now(),
      'index': makeIndexList(bName)
    });
    await UserRepo().upDate(uid: uid, role: 'admin', bid: bid.documentID);
    await ChannelMaker(bid.documentID, uid);

    return bid.documentID;
  }

  List<String> makeIndexList(String bName) {
    List<String> indexList = [];
    var temp = bName.split(' ');
    for (int i = 0; i < temp.length; i++) {
      for (int y = 1; y < temp[i].length + 1; y++) {
        indexList.add(temp[i].substring(0, y).toLowerCase());
      }
    }
    return indexList;
  }

  Future<void> ChannelMaker(String mid, String uid) async {
    String fcm = await _fcm.getToken();
    await databaseReference.collection("channels").document(mid).setData({
      'Messaging': {uid: fcm},
      'Ordering': {uid: fcm},
      'Delivery&Pickup': {uid: fcm},
      'Cashier': {uid: fcm}
    });
  }

  Future<void> CategoryMaker(String category) async {
    CollectionReference catRef = Firestore.instance.collection('categories');
    var document = await catRef
        .where('title', isEqualTo: category)
        .getDocuments(source: Source.server);
    if (document.documents.isEmpty) {
      catRef.add({'title': category, 'sort': 1});
    }
  }

  Future<String> BranchOTP(String mid) async {
    Random random = new Random();
    int randomNumber = random.nextInt(999999);
    var result = {};
    result = await getOTP(mid);
    var uri = await DynamicLinks.createLinkWithParams({
      'merchant': '$mid',
      'OTP': 'randomNumber.toString()',
      'route': 'branch'
    });

    if (result.isEmpty) {
      await databaseReference.collection("merchantsOTP").document(mid).setData({
        'merchant': databaseReference.document('merchants/' + mid),
        'OTP': randomNumber.toString(),
        'status': 'unread',
        'uri': uri.toString(),
        'createdAt': DateTime.now(),
      });
      return uri.toString();
    } else {
      return result['uri'].toString();
    }
  }

  Future<Map<String, dynamic>> getOTP(String mid) async {
    var document = await Firestore.instance
        .collection('merchantsOTP')
        .document(mid)
        .get(source: Source.server);

    if (document.exists) {
      if (getDifference(document.data['createdAt']) > 60)
        return {};
      else {
        Map<String, dynamic> collection = Map();
        collection.addAll(document.data);

        var temp = await document.data['merchant'].get();
        collection.putIfAbsent('merchantID', () => temp.documentID);
        collection.addAll(temp.data);
        return collection;
      }
    } else {
      return {};
    }
  }

  int getDifference(var created) {
    //print(DateTime.parse(created.toDate().toString()));
    var now = DateTime.now();
    Duration difference =
        now.difference(DateTime.parse(created.toDate().toString()));
    print(difference.inMinutes.toString());
    return difference.inMinutes;
  }

  Future<bool> branchNameUnique(String mid, String branchName) async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('businessParent',
            isEqualTo: databaseReference.document('merchants/' + mid))
        .where('isBranch', isEqualTo: true)
        .where('branchUnique', isEqualTo: branchName)
        .getDocuments();

    if (document.documents.length > 0)
      return false;
    else
      return true;
  }

  Future<Map<String, dynamic>> getOne(String uid) async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('uid', isEqualTo: uid)
        .getDocuments();

    return document.documents[0].data;
  }

  static Future<Merchant> getMerchant(String mid) async {
    Merchant merchant;
    var value = await Firestore.instance.document('merchants/$mid').get();
    merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(value));
    //print('$mid merchant ${merchant.bName}');
    return merchant;
    //
  }

  static String getMerchantName(String mid) {
    String merchant = "";
    getMerchant(mid).then((value) => merchant = value.bName);
    print(merchant);
    return merchant;
    //
  }

  Future<Map<String, dynamic>> getAnyOne(String bID) async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('businessID', isEqualTo: bID)
        .getDocuments();

    if (document.documents.length > 0) {
      Map<String, dynamic> doc = document.documents[0].data;
      doc.putIfAbsent('documentID', () => document.documents[0].documentID);
      return doc;
    } else
      return {};
  }

  Future<DocumentSnapshot> getAnyOneUsingID(String mid) async {
    var document =
        await Firestore.instance.collection('merchants').document(mid).get();
    return document;
  }

  Future<List<DocumentSnapshot>> getBranch(String mid) async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('businessParent',
            isEqualTo: databaseReference.document('merchants/' + mid))
        .where('isBranch', isEqualTo: true)
        .orderBy('businessCreatedAt', descending: false)
        .getDocuments();

    if (document.documents.length > 0) {
      return document.documents;
    } else
      return [];
  }

  Future<List<String>> getCategory(String Category) async {
    List<String> suggestion = List();
    var document = await Firestore.instance
        .collection('categories')
        .where('title', isGreaterThanOrEqualTo: Category)
        .where('title', isLessThan: Category + 'z')
        .getDocuments();
    document.documents.forEach((element) {
      suggestion.add(element.data['title']);
    });
    // print(suggestion);
    return suggestion;
  }

  static Future<List<String>> regio(Position position) async {
    final coordinates =
        new geocode.Coordinates(position.latitude, position.longitude);
    var address =
        await geocode.Geocoder.local.findAddressesFromCoordinates(coordinates);
    //print(address.);
    return [];
  }
}
