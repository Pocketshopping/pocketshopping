import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart' as geocode;
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareRepo.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/ui/shared/dynamicLinks.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

//cleared
class MerchantRepo {
  static final databaseReference = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  static final Geoflutterfire geo = Geoflutterfire();


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
    int bStatus,
    String bCountry,
    String bBranchUnique,
    bool adminUploaded,
    String walletID
  }) async {
    DocumentReference bid;
    var user;
    GeoFirePoint merchantLocation = geo.point(latitude: bGeopint.latitude, longitude: bGeopint.longitude);
    var temp = Utility.makeIndexList(bName);
    temp.addAll(Utility.makeIndexList(bCategory));
    if(bDelivery == 'Yes')
    {temp.addAll(Utility.makeIndexList('Logistic'));}

    if(!adminUploaded)
      user = await UserRepo().getOne(uid: uid);


    try{

      bid = await databaseReference.collection("merchants").add({
        'businessCreator': databaseReference.doc('users/' + uid),
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
        'businessParent': databaseReference.doc('merchants/' + bParent),
        'businessID': bID,
        'businessStatus': bStatus,
        'businessCountry': bCountry,
        'branchUnique': bBranchUnique,
        'businessCreatedAt': DateTime.now(),
        'adminUploaded':adminUploaded,
        'businessActive':true,
        'businessWallet':!adminUploaded?user.user.walletId:'',
        'index': temp,
        'bikeCount':0,
        'carCount':0,
        'vanCount':0,
      });

      if(bid != null)
        if(!adminUploaded) {
          await UserRepo().upDate(uid: uid, role: 'admin', bid: bid.id);
          await channelMaker(bid.id, uid);
          await CustomerCareRepo.saveCustomerCare(bid.id, [CustomerCareLine(number: bTelephone,name:bName.headerCase ),
            if(bTelephone2.isNotEmpty)CustomerCareLine(number: bTelephone2,name:bName.headerCase ),
          ]);
          await updateUrl(bid.id);
          await Utility.updateWallet(uid: user.user.walletId,cid: user.user.walletId,type: 3);
        }

    }catch(_){
      //print(_);
    }


    return bid.id;
  }


  Future<void> channelMaker(String mid, String uid) async {
    String fcm = await _fcm.getToken();
    await databaseReference.collection("channels").doc(mid).set({
      'Messaging': {uid: fcm},
      'Ordering': {uid: fcm},
      'Delivery&Pickup': {uid: fcm},
      'Cashier': {uid: fcm}
    });
  }

  Future<void> categoryMaker(String category) async {
    CollectionReference catRef = FirebaseFirestore.instance.collection('categories');
    var document = await catRef
        .where('title', isEqualTo: category)
        .get(GetOptions(source: Source.serverAndCache));
    if (document.docs.isEmpty) {
      catRef.add({'title': category, 'sort': 1});
    }
  }



  Future<Map<String, dynamic>> getOTP(String mid) async {
    var document = await FirebaseFirestore.instance
        .collection('merchantsOTP')
        .doc(mid)
        .get(GetOptions(source: Source.server));

    if (document.exists) {
      if (getDifference(document.data()['createdAt']) > 60)
        return {};
      else {
        Map<String, dynamic> collection = Map();
        collection.addAll(document.data());

        var temp = await document.data()['merchant'].get(GetOptions(source: Source.serverAndCache));
        collection.putIfAbsent('merchantID', () => temp.id);
        collection.addAll(temp.data);
        return collection;
      }
    } else {
      return {};
    }
  }

  static Future<String> updateUrl(String mid) async {
    String url = (await DynamicLinks.createLinkWithParams({'merchant': '$mid'})).toString();
    await FirebaseFirestore.instance.collection('merchants').doc(mid).update({'businessSocials':{'url':url}});
    return url;
  }

  int getDifference(var created) {
    //print(DateTime.parse(created.toDate().toString()));
    var now = DateTime.now();
    Duration difference =
        now.difference(DateTime.parse(created.toDate().toString()));
    //print(difference.inMinutes.toString());
    return difference.inMinutes;
  }

  Future<bool> branchNameUnique(String mid, String branchName) async {
    try{
      var document = await FirebaseFirestore.instance
          .collection('merchants')
          .where('businessParent',
          isEqualTo: databaseReference.doc('merchants/' + mid))
          .where('isBranch', isEqualTo: true)
          .where('branchUnique', isEqualTo: branchName)
          .get(GetOptions(source: Source.server)).timeout(
        Duration(seconds: TIMEOUT),
        onTimeout: () {
          throw Exception;
        },
      );

      if (document.docs.length > 0)
        return false;
      else
        return true;
    }
    catch(_){
      return true;
    }
  }

  Future<Map<String, dynamic>> getOne(String uid) async {
    var document = await FirebaseFirestore.instance
        .collection('merchants')
        .where('uid', isEqualTo: uid)
        .get(GetOptions(source: Source.serverAndCache));

    return document.docs[0].data();
  }

  static Future<Merchant> getMerchant(String mid,{int source=0}) async {
    Merchant merchant;
    if(mid.isEmpty)
      return null;

    else{
      try{
        try{
          if(source == 1) throw Exception;
          var value = await FirebaseFirestore.instance.doc('merchants/$mid').get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(!value.exists){throw Exception;}

          merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(value));
          return merchant;
        }
        catch(_){
          var value = await FirebaseFirestore.instance.doc('merchants/$mid').get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(value));
          return merchant;
        }
      }catch(_){
        return null;
      }
    }
  }

  static Future<Merchant> getMerchantByWallet(String mid,{int source=0})async{
    Merchant merchant;
    if(mid.isEmpty)
      return null;

    else{
      try{
        try{
          if(source == 1) throw Exception;
          var value = await FirebaseFirestore.instance.collection('merchants').where('businessWallet',isEqualTo:mid )
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(value.docs.isEmpty){throw Exception;}
          merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(value.docs.last));
          return merchant;
        }
        catch(_){
          var value = await FirebaseFirestore.instance.collection('merchants').where('businessWallet',isEqualTo:mid )
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          merchant = Merchant.fromEntity(MerchantEntity.fromSnapshot(value.docs.last));
          return merchant;
        }
      }catch(_){
        return null;
      }
    }
  }

  static Future<List<Merchant>> getMyBusiness(String uid, Merchant lastDoc,{int source=0}) async {

    try{
      var uRef = FirebaseFirestore.instance.doc('users/$uid');
      List<Merchant> tmp = List();
      var document;

      if (lastDoc == null) {
        try{
          if(source == 1) throw Exception;
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .orderBy('businessCreatedAt', descending: true)
              .where('businessCreator', isEqualTo: uRef)
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty){throw Exception;}
        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .orderBy('businessCreatedAt', descending: true)
              .where('businessCreator', isEqualTo: uRef)
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      } else {
        try{
          if(source == 1) throw Exception;
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .orderBy('businessCreatedAt', descending: true)
              .where('businessCreator', isEqualTo: uRef)
              .startAfter([DateTime.parse(lastDoc.bCreatedAt.toDate().toString())])
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty){throw Exception;}

        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .orderBy('businessCreatedAt', descending: true)
              .where('businessCreator', isEqualTo: uRef)
              .startAfter([DateTime.parse(lastDoc.bCreatedAt.toDate().toString())])
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      }
      document.docs.forEach((element) {
        tmp.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
      });

      return tmp;
    }
    catch(_){return [];}

  }


  static Future<List<Merchant>> searchMyBusiness(String uid, Merchant lastDoc,String key,{int source}) async {
    try{
      var uRef = FirebaseFirestore.instance.doc('users/$uid');
      List<Merchant> tmp = List();
      var document;

      if (lastDoc == null) {
        try{
          if(source == 1) throw Exception;
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .where('businessCreator', isEqualTo: uRef)
              .where('index',arrayContains: key)
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty){throw Exception;}
        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .where('businessCreator', isEqualTo: uRef)
              .where('index',arrayContains: key)
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      } else {
        try{
          if(source == 1) throw Exception;
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .where('businessCreator', isEqualTo: uRef)
              .where('index',arrayContains: key)
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty){throw Exception;}
        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('merchants')
              .where('businessCreator', isEqualTo: uRef)
              .where('index',arrayContains: key)
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      }
      document.docs.forEach((element) {
        tmp.add(Merchant.fromEntity(MerchantEntity.fromSnapshot(element)));
      });

      return tmp;
    }
    catch(_){
      return [];
    }

  }

  static String getMerchantName(String mid) {
    String merchant = "";
    getMerchant(mid).then((value) => merchant = value.bName);
    //print(merchant);
    return merchant;
    //
  }

  Future<Map<String, dynamic>> getAnyOne(String bID) async {
    var document = await FirebaseFirestore.instance
        .collection('merchants')
        .where('businessID', isEqualTo: bID)
        .get(GetOptions(source: Source.serverAndCache));

    if (document.docs.length > 0) {
      Map<String, dynamic> doc = document.docs[0].data();
      doc.putIfAbsent('documentID', () => document.docs[0].id);
      return doc;
    } else
      return {};
  }

  Future<DocumentSnapshot> getAnyOneUsingID(String mid) async {
    var document =
        await FirebaseFirestore.instance.collection('merchants').doc(mid).get(GetOptions(source: Source.serverAndCache));
    return document;
  }

  Future<List<DocumentSnapshot>> getBranch(String mid) async {
    var document = await FirebaseFirestore.instance
        .collection('merchants')
        .where('businessParent',
            isEqualTo: databaseReference.doc('merchants/' + mid))
        .where('isBranch', isEqualTo: true)
        .orderBy('businessCreatedAt', descending: false)
        .get(GetOptions(source: Source.serverAndCache));

    if (document.docs.length > 0) {
      return document.docs;
    } else
      return [];
  }

  Future<List<String>> getCategory(String category) async {
    List<String> suggestion = List();
    var document = await FirebaseFirestore.instance
        .collection('categories')
        .where('title', isGreaterThanOrEqualTo: category)
        .where('title', isLessThan: category + 'z')
        .get(GetOptions(source: Source.serverAndCache));
    document.docs.forEach((element) {
      suggestion.add(element.data()['title']);
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
    if(bid.id.isNotEmpty)
      return true;
    else
      return false;
  }


  static Future<Merchant> getNearByMerchant(Position mpos, String name) async {
    GeoFirePoint center = geo.point(latitude: mpos.latitude, longitude: mpos.longitude);
    var collectionReference = FirebaseFirestore.instance
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


  static Future<bool> update(String mid, Map<String,dynamic> data)async{
    try {


      GetBar(
          title: 'Updating',
          messageText: Text('Business updating',style: TextStyle(color: Colors.black),),
          duration: Duration(days: 365),
          backgroundColor: Colors.grey,
          snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
      ).show();
      await FirebaseFirestore.instance.collection('merchants').doc(mid).update(data);
      Get.back();
      GetBar(
          title:'Updated',
          messageText: Text('Business updated',style: TextStyle(color: Colors.white),),
          duration: Duration(seconds: 3),
          backgroundColor: PRIMARYCOLOR,
          snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
      ).show();

      return true;
    }
    catch(_){return false;}
  }





}
