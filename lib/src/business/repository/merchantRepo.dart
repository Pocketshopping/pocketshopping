import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/component/dynamicLinks.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

class MerchantRepo {
  static final databaseReference = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final Geoflutterfire geo = Geoflutterfire();
  //Geoflutterfire geo = Geoflutterfire();

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
    bool adminUploaded
  }) async {
    DocumentReference bid;
    GeoFirePoint merchantLocation = geo.point(latitude: bGeopint.latitude, longitude: bGeopint.longitude);
    bid = await databaseReference.collection("merchants").add({
      'businessCreator': databaseReference.document('users/' + uid),
      'businessName': bName.headerCase,
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
      'adminUploaded':adminUploaded,
      'businessActive':true,
      'index': Utility.makeIndexList(bName)
    });
    if(!adminUploaded) {
      await UserRepo().upDate(uid: uid, role: 'admin', bid: bid.documentID);
      await ChannelMaker(bid.documentID, uid);
    }

    return bid.documentID;
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

  static Future<List<Merchant>> getMyBusiness(String uid, Merchant lastDoc,) async {
    var uRef = Firestore.instance.document('users/$uid');
    List<Merchant> tmp = List();
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('merchants')
          .orderBy('businessCreatedAt', descending: true)
          .where('businessCreator', isEqualTo: uRef)
          .limit(10)
          .getDocuments();
    } else {
      document = await Firestore.instance
          .collection('merchants')
          .orderBy('businessCreatedAt', descending: true)
          .where('businessCreator', isEqualTo: uRef)
          .startAfter([DateTime.parse(lastDoc.bCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
    }
    document.documents.forEach((element) {
      tmp.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
    });

    return tmp;

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


  static Future<bool> claim(Position position,String uid,String mid) async {
    GeoFirePoint claimLocation = geo.point(latitude: position.latitude, longitude: position.longitude);
    var bid = await databaseReference.collection("claims").add({
      'location': claimLocation.data,
      'user':uid,
      'merchant':mid,
      'loggedAt':Timestamp.now(),
    });
    if(bid.documentID.isNotEmpty)
      return true;
    else
      return false;
  }


  static Future<Merchant> getNearByMerchant(Position mpos, String name) async {
    GeoFirePoint center = geo.point(latitude: mpos.latitude, longitude: mpos.longitude);
    var collectionReference = Firestore.instance
        .collection('merchants')
        .where('businessName', isEqualTo: name)
        .limit(5);
    Stream<List<DocumentSnapshot>> alu = geo
        .collection(collectionRef: collectionReference)
        .within(
        center: center,
        radius: 0.3,
        field: 'businessGeopint',
        strictMode: true);
    var doc = await alu.first;
    if(doc.length>0)
    return Merchant.fromEntity(MerchantEntity.fromSnapshot(doc.first));
    else return null;
  }


  static Future<void> update(String mid, Map<String,dynamic> data)async{
    try {
      Get.snackbar('Updating',
          'Business updating',duration: Duration(days: 365),
          backgroundColor: Colors.grey,
          colorText: Colors.black,
          snackStyle: SnackStyle.GROUNDED
      );
      await Firestore.instance.collection('merchants').document(mid).updateData(data);
      Get.back();
      Get.snackbar('Updated',
          'Business updated',duration: Duration(seconds: 3),
          backgroundColor: PRIMARYCOLOR,
          colorText: Colors.white,
          snackStyle: SnackStyle.GROUNDED
      );
    }
    catch(_){}
  }

}
