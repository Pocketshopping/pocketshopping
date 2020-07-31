

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

class ProductRepo {
  final databaseReference = Firestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  Future<String> save({
    String mID,
    String pName,
    double pPrice,
    String pCategory,
    String pDesc,
    List<String> pPhoto,
    String pGroup,
    int pStockCount,
    String pQRCode,
    String pUploader,
    String pUnit,
    int status=1,
    int availability=1,
    GeoPoint pGeopoint,
  }) async {
    DocumentReference bid;
    try{
      GeoFirePoint productLocation = geo.point(latitude: pGeopoint.latitude, longitude: pGeopoint.longitude);
      bid = await databaseReference.collection("products").add({
      'productMerchant': databaseReference.document('merchants/$mID'),
      'productName': pName.isNotEmpty?pName.sentenceCase:"",
      'productPrice': pPrice,
      'productCategory': pCategory.isNotEmpty?pCategory.sentenceCase:"",
      'productDesc': pDesc.isNotEmpty?pDesc.sentenceCase:"",
      'productPhoto': pPhoto,
      'productGroup': pGroup,
      'productStockCount': pStockCount,
      'productQRCode': pQRCode,
      'productUploader': pUploader,
      'productUnit': pUnit.toUpperCase(),
      'productCreatedAt': DateTime.now(),
      'productStatus':  status,
      'productAvailability':availability,
      'productGeoPoint': productLocation.data,
      'index': await makeIndexList(pName,mID,pCategory,pGroup),
    }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      if(bid != null){
        await saveCategory(pCategory, mID);
        await saveProductStock(bid.documentID, pUploader, pStockCount);
      }
    }catch(_){

    }

    return bid != null ?bid.documentID:'';
  }



  Future<bool> saveCategory(String pCategory, String mid) async {
    try{
      await databaseReference
          .collection("productsCategory")
          .document(pCategory)
          .setData({
        'productCategory': pCategory,
        'updatedAt': DateTime.now(),
        'productMerchant': [mid],
      }, merge: true).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      return true;
    }
    catch(_){
      return false;
    }
  }

/*  Future<void> saveCategory(String pCategory, String mid) async {
    var cat= await databaseReference.collection("productsCategory")
     .document(mid).get(source: Source.serverAndCache);
    if(cat.exists){
      var proCate = ProductCategory.fromSnap(cat);
      await databaseReference.collection("productsCategory").document(mid).updateData(proCate.toMap(pCategory));
    }
    else{
      var proCate = ProductCategory(mid: mid,productCategory: []);
      await databaseReference.collection("productsCategory").document(mid).setData(proCate.toMap(pCategory));
    }
    return pCategory;
  }*/

  Future<String> saveProductStock(
    String pid,
    String pUploader,
    int pStockCount,
  ) async {
    try{
      String bid = "";
      await databaseReference.collection("productStock").add({
        'productID': databaseReference.document('products/$pid'),
        'restockedBy': pUploader,
        'restockCount': pStockCount,
        'oldStockCount': 0,
        'StockCount': pStockCount,
        'restockedAt': DateTime.now(),
      }).then((value) => bid = value.documentID.toString())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      return bid;
    }
    catch(_){
      return '';
    }
  }

  static Future<List<String>> makeIndexList(String pName, String mid,String category, String pGroup) async{
    List<String> temp=[];
    Merchant merchant = await MerchantRepo.getMerchant(mid);
    temp.addAll(Utility.makeIndexList(pName));
    temp.addAll(Utility.makeIndexList(merchant.bName));
    temp.addAll(Utility.makeIndexList(category));
    temp.addAll(Utility.makeIndexList(pGroup));
    return temp;

  }

  static Future<bool> updateProduct(String pID, Map<String, dynamic> data) async {
    try {
      await Firestore.instance.collection('products').document(pID).updateData(data)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});
      Get.snackbar('Update',
          'Product updated',duration: Duration(seconds: 3),
          backgroundColor: PRIMARYCOLOR,
        colorText: Colors.white,
        snackStyle: SnackStyle.GROUNDED
      );
      return true;
    }catch(_){return false;}
  }

  static Future<bool> deleteProduct(String pID) async {
    try {
      await Firestore.instance.collection('products').document(pID).delete()
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});
      return true;
    }catch(_){return false;}
  }


  Future<Map<String, dynamic>> getOne(String pID) async {
    try{
      var document = await Firestore.instance.collection('products')
          .document(pID).get(source: Source.serverAndCache)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      if(document != null)
        return document.data;
      else
        return {};
    }
    catch(_){
      return {};
    }
  }

  Stream<int> getCount(String mID) {
    var businessRef = databaseReference.document('merchants/$mID');
    return Firestore.instance
        .collection('products')
        .where('productMerchant', isEqualTo: businessRef)
        .snapshots()
        .map((element) {
      return element.documents.length;
    }).timeout(Duration(seconds: TIMEOUT),onTimeout: (sink){sink.add(0);});
  }

  Future<List<String>> getCategory(String pCategory) async {
    try{
      List<String> suggestion = List();
      var document = await Firestore.instance
          .collection('productsCategory')
          .where('productCategory', isGreaterThanOrEqualTo: pCategory)
          .where('productCategory', isLessThan: pCategory + 'z')
          .getDocuments(source: Source.serverAndCache)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      if(document != null){
        document.documents.forEach((element) {
          suggestion.add(element.documentID);
        });
      }

      return suggestion;
    }
    catch(_){return [];}
  }

  static Future<List<Product>> fetchAllProduct(String mID, dynamic lastDoc) async {
  try{
    var mRef = Firestore.instance.document('merchants/$mID');
    List<Product> tmp = List();
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('products')
          .orderBy('productCreatedAt', descending: true)
          .where('productMerchant', isEqualTo: mRef)
          .limit(10)
          .getDocuments(source: Source.serverAndCache)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
    } else {
      document = await Firestore.instance
          .collection('products')
          .orderBy('productCreatedAt', descending: true)
          .where('productMerchant', isEqualTo: mRef)
          .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
    }

    if(document != null){
      document.documents.forEach((element) {
        tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
      });
    }
    return tmp;
  }
  catch(_){return [];}
  }

  static Future<List<Product>> fetchCategoryProduct(String mID, dynamic lastDoc,String category) async {
   try{
     var mRef = Firestore.instance.document('merchants/$mID');
     List<Product> tmp = List();
     var document;


     if (lastDoc == null) {
       document = await Firestore.instance
           .collection('products')
           .orderBy('productCreatedAt', descending: true)
           .where('productMerchant', isEqualTo: mRef)
           .where('productCategory',isEqualTo: category)
           .limit(10)
           .getDocuments(source: Source.serverAndCache)
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ Utility.noInternet(); throw Exception;});
     } else {
       document = await Firestore.instance
           .collection('products')
           .orderBy('productCreatedAt', descending: true)
           .where('productMerchant', isEqualTo: mRef)
           .where('productCategory',isEqualTo: category)
           .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
           .limit(10)
           .getDocuments(source: Source.serverAndCache)
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ Utility.noInternet(); return null;});
     }

     if(document != null){
       document.documents.forEach((element) {
         tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
       });
     }
     return tmp;
   }
   catch(_){return [];}
  }

  Future<List<Product>> fetchProduct(
      String mID, dynamic lastDoc, String category) async {
   try{
     var mRef = Firestore.instance.document('merchants/$mID');
     List<Product> tmp = List();
     var document;

     if (lastDoc == null) {
       document = await Firestore.instance
           .collection('products')
           .orderBy('productCreatedAt', descending: true)
           .where('productMerchant', isEqualTo: mRef)
           .where('productCategory', isEqualTo: category)
           .limit(10)
           .getDocuments(source: Source.serverAndCache)
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); return null;});
     } else {
       //print(lastDoc !=null ?DateTime.parse(lastDoc.pCreatedAt.toDate().toString()):'');
       document = await Firestore.instance
           .collection('products')
           .orderBy('productCreatedAt', descending: true)
           .where('productMerchant', isEqualTo: mRef)
           .where('productCategory', isEqualTo: category)
           .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
           .limit(10)
           .getDocuments(source: Source.serverAndCache)
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); return null;});
     }

     if(document != null){
       document.documents.forEach((element) {
         tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
       });
     }
     return tmp;
   }
   catch(_){
     return [];
   }
  }

 static Future<List<Product>> searchProduct(
      String mID, dynamic lastDoc, String search) async {
    try{
      var mRef = Firestore.instance.document('merchants/$mID');
      List<Product> tmp = List();
      var document;

      if (lastDoc == null) {
        document = await Firestore.instance
            .collection('products')
            .where('productMerchant', isEqualTo: mRef)
            .where('index', arrayContains: search.toLowerCase())
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      } else {
        print(lastDoc != null
            ? DateTime.parse(lastDoc.pCreatedAt.toDate().toString())
            : '');
        document = await Firestore.instance
            .collection('products')
            .where('productMerchant', isEqualTo: mRef)
            .where('index', arrayContains: search.toLowerCase())
            .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      }

      if(document != null){
        document.documents.forEach((element) {
          tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
        });
      }


      return tmp;
    }
    catch(_){return [];}
  }




}

