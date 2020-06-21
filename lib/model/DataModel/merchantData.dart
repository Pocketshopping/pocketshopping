import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/component/dynamicLinks.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';

class MerchantDataModel extends Data {
  String bID;
  String uid;
  String bName;
  String bAddress;
  String bCategory;
  int bDelivery;
  String bDescription;
  String bPhoto;
  String bOpenTime;
  String bCloseTime;
  String bTelephone;
  String bTelephone2;
  String bEmail;
  Map<String, dynamic> bSocial;
  File bCroppedPhoto;
  GeoPoint bGeopint;
  bool isBranch;
  String bParent;
  String bStatus;
  String bCountry;
  String bBranchUnique;

  MerchantDataModel({
    this.bID = '',
    this.uid = '',
    this.bName = '',
    this.bAddress = '',
    this.bCategory = '',
    this.bDelivery = 0,
    this.bDescription = '',
    this.bPhoto,
    this.bOpenTime = '',
    this.bCloseTime = '',
    this.bTelephone = '',
    this.bTelephone2 = '',
    this.bGeopint,
    this.bEmail = '',
    this.bSocial,
    this.isBranch = false,
    this.bParent = '',
    this.bStatus,
    this.bCountry,
  });

  final databaseReference = Firestore.instance;

  @override
  Future<String> save() async {
    String bid = "";
    await databaseReference.collection("merchants").add({
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
      'businessGeopint': bGeopint,
      'businessDelivery': bDelivery,
      'businessSocials': bSocial,
      'businessDescription': bDescription,
      'isBranch': isBranch,
      'businessParent': bParent.isNotEmpty
          ? databaseReference.document('merchants/' + bParent)
          : '',
      'businessID': bID,
      'businessStatus': bStatus,
      'businessCountry': bCountry,
      'branchUnique': bBranchUnique,
      'businessCreatedAt': DateTime.now(),
    }).then((value) => bid = value.documentID.toString());

    return bid;
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

        var temp = await document.data['merchant'].get(source: Source.server);
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
        .getDocuments(source: Source.server);

    if (document.documents.length > 0)
      return false;
    else
      return true;
  }

  @override
  Future<Map<String, dynamic>> getOne() async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('uid', isEqualTo: uid)
        .getDocuments(source: Source.server);

    return document.documents[0].data;
  }

  Future<Map<String, dynamic>> getAnyOne() async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('businessID', isEqualTo: bID)
        .getDocuments(source: Source.server);

    if (document.documents.length > 0) {
      Map<String, dynamic> doc = document.documents[0].data;
      doc.putIfAbsent('documentID', () => document.documents[0].documentID);
      return doc;
    } else
      return {};
  }

  Future<DocumentSnapshot> getAnyOneUsingID(String mid) async {
    var document =
        await Firestore.instance.collection('merchants').document(mid).get(source: Source.server);
    return document;
  }

  Future<List<DocumentSnapshot>> getBranch(String mid) async {
    var document = await Firestore.instance
        .collection('merchants')
        .where('businessParent',
            isEqualTo: databaseReference.document('merchants/' + mid))
        .where('isBranch', isEqualTo: true)
        .orderBy('businessCreatedAt', descending: false)
        .getDocuments(source: Source.server);

    if (document.documents.length > 0) {
      return document.documents;
    } else
      return [];
  }
}
