import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MerchantDataModel extends Data{


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
   Map<String,dynamic> bSocial;
   File bCroppedPhoto;
   GeoPoint bGeopint;
   bool isBranch;
   String bParent;
   String bStatus;
   String bCountry;

  MerchantDataModel({
    this.bID='',
    this.uid='',
    this.bName='',
    this.bAddress='',
    this.bCategory='',
    this.bDelivery=0,
    this.bDescription='',
    this.bPhoto,
    this.bOpenTime='',
    this.bCloseTime='',
    this.bTelephone='',
    this.bTelephone2='',
    this.bGeopint,
    this.bEmail='',
    this.bSocial,
    this.isBranch=false,
    this.bParent='',
    this.bStatus,
    this.bCountry,

  });
  final databaseReference = Firestore.instance;
  @override
  Future<String> save() async{
    String bid="";
    await databaseReference.collection("merchants")
        .add({
      'businessCreator': databaseReference.document('users/'+uid),
      'businessName': bName,
      'businessAdress': bAddress,
      'businessCategory':bCategory,
      'businessOpenTime':bOpenTime,
      'businessCloseTime':bCloseTime,
      'businessPhoto':bPhoto,
      'businessTelephone':bTelephone,
      'businessTelephone2':bTelephone2,
      'businessEmail':bEmail,
      'businessGeopint':bGeopint,
      'businessDelivery':bDelivery,
      'businessSocials':bSocial,
      'businessDescription':bDescription,
      'isBranch':isBranch,
      'businessParent':bParent.isNotEmpty?databaseReference.document('merchants/'+bParent):'',
      'businessID':bID,
      'businessStatus':bStatus,
      'businessCountry':bCountry,
      'businessCreatedAt':DateTime.now(),

    }).then((value) => bid = value.documentID.toString());


    return bid;


  }

  @override
  Future<Map<String,dynamic>> getOne()async {
    var document = await Firestore.instance.collection('merchants').where('uid',isEqualTo: uid).getDocuments();

    return document.documents[0].data;
  }

  Future<Map<String,dynamic>> getAnyOne()async {
     var document = await Firestore.instance.collection('merchants').where('businessID',isEqualTo: bID).getDocuments();

     if(document.documents.length>0){
       Map<String,dynamic> doc =document.documents[0].data;
       doc.putIfAbsent('documentID', () => document.documents[0].documentID);
       return doc;
     }

     else
       return {};
   }

}