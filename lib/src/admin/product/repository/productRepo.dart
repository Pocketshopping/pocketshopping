

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/admin/product/bloc/categoryBloc.dart';
import 'package:pocketshopping/src/admin/product/bloc/refreshBloc.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/geofence/bloc/geofenceRefreshBloc.dart';
import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:pocketshopping/src/stockManager/repository/stockRepo.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

//cleared
class ProductRepo {
  final databaseReference = FirebaseFirestore.instance;
  static final Geoflutterfire geo = Geoflutterfire();

  Future<String> save({
    String mID,
    String pName,
    double pPrice,
    String pCategory,
    String pDesc,
    List<String> pPhoto,
    String pGroup,
    int pStockCount=1,
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
      'productMerchant': databaseReference.doc('merchants/$mID'),
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
      'isManaging':pStockCount > 1?true:false,
      'productGeoPoint': productLocation.data,
      'index': await makeIndexList(pName,mID,pCategory,pGroup),
    }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      if(bid != null){
        await saveCategory(pCategory, mID);
        //await saveProductStock(bid.id, pUploader, pStockCount);
        await StockRepo.save(Stock(
          productID: bid.id,
          company: mID,
          stockCount: pStockCount,
          lastRestockCount: pStockCount,
          restockedBy: pUploader,
          frequency: 0,
          product: pName,
          restockedAt: Timestamp.now(),
          isManaging: pStockCount > 1?true:false,
        ));
      }
    }catch(_){

    }

    return bid != null ?bid.id:'';
  }



  Future<bool> saveCategory(String pCategory, String mid) async {
    try{
      await databaseReference
          .collection("productsCategory")
          .doc(pCategory)
          .set({
        'productCategory': pCategory,
        'updatedAt': DateTime.now(),
        'productMerchant': [mid],
      }, SetOptions(merge: true)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      return true;
    }
    catch(_){
      return false;
    }
  }

/*  Future<void> saveCategory(String pCategory, String mid) async {
    var cat= await databaseReference.collection("productsCategory")
     .doc(mid).get(GetOptions(source: Source.serverAndCache));
    if(cat.exists){
      var proCate = ProductCategory.fromSnap(cat);
      await databaseReference.collection("productsCategory").doc(mid).update(proCate.toMap(pCategory));
    }
    else{
      var proCate = ProductCategory(mid: mid,productCategory: []);
      await databaseReference.collection("productsCategory").doc(mid).set(proCate.toMap(pCategory));
    }
    return pCategory;
  }*/

  /*Future<String> saveProductStock(
    String pid,
    String pUploader,
    int pStockCount,
  ) async {
    try{
      String bid = "";
      await databaseReference.collection("productStock").add({
        'productID': databaseReference.doc('products/$pid'),
        'restockedBy': pUploader,
        'restockCount': pStockCount,
        'oldStockCount': 0,
        'StockCount': pStockCount,
        'isManaging': false,
        'restockedAt': DateTime.now(),
      }).then((value) => bid = value.id.toString())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      return bid;
    }
    catch(_){
      return '';
    }
  }*/

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
      await FirebaseFirestore.instance.collection('products').doc(pID).update(data)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
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
      await FirebaseFirestore.instance.collection('products').doc(pID).delete()
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }catch(_){return false;}
  }


  Future<Map<String, dynamic>> getOne(String pID) async {
    try{
      var document = await FirebaseFirestore.instance.collection('products')
          .doc(pID).get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      if(document != null)
        return document.data();
      else
        return {};
    }
    catch(_){
      return {};
    }
  }

  Stream<int> getCount(String mID) {
    var businessRef = databaseReference.doc('merchants/$mID');
    return FirebaseFirestore.instance
        .collection('products')
        .where('productMerchant', isEqualTo: businessRef)
        .snapshots()
        .map((element) {
      return element.docs.length;
    });
  }

  Future<List<String>> getCategory(String pCategory,{int source=0}) async {
    try{
      try{
        if(source == 1)
          throw Exception;
        List<String> suggestion = List();
        var document = await FirebaseFirestore.instance
            .collection('productsCategory')
            .where('productCategory', isGreaterThanOrEqualTo: pCategory)
            .where('productCategory', isLessThan: pCategory + 'z')
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
        if(document != null){
          document.docs.forEach((element) {
            suggestion.add(element.id);
          });
        }

        return suggestion;
      }
      catch(_){
        List<String> suggestion = List();
        var document = await FirebaseFirestore.instance
            .collection('productsCategory')
            .where('productCategory', isGreaterThanOrEqualTo: pCategory)
            .where('productCategory', isLessThan: pCategory + 'z')
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});

        if(document != null){
          document.docs.forEach((element) {
            suggestion.add(element.id);
          });
        }

        return suggestion;
      }
    }
    catch(_){return [];}
  }

  static Future<List<String>> runFetchCategory(String mid,{int source=0})async{
    List<String> category = [];
    try{

      try{
        if(source == 1) throw Exception;
        List<String> data = await CategoryBloc.instance.getLastCategories();
        if(data.isEmpty) throw Exception;
        else category = data;
      }
      catch(_){
        HttpsCallableResult data = await CloudFunctions.instance.getHttpsCallable(
          functionName: "FetchMerchantsProductCategory",
        ).call({'mID': mid}).timeout(Duration(seconds: TIMEOUT),onTimeout: (){
          Utility.noInternet();
          throw CloudFunctionsException;
        });
        category = List.castFrom(data.data());
        CategoryBloc.instance.addNewCategory(category);

      }

      return category;
    }
    catch(_){
      return [];
    }
  }

  static Future<List<Product>> fetchAllProduct(String mID, dynamic lastDoc,{int source=0}) async {
    source = await ProductRefreshBloc.instance.getLastRefresh();
    //print(await ProductRefreshBloc.instance.getLastRefresh());
  try{
    var mRef = FirebaseFirestore.instance.doc('merchants/$mID');
    List<Product> tmp = List();
    var document;

    if (lastDoc == null) {
      try{
        if(source == 1) throw Exception;
        document = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productCreatedAt', descending: true)
            .where('productMerchant', isEqualTo: mRef)
            .limit(10)
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
       // print('product cahce');
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productCreatedAt', descending: true)
            .where('productMerchant', isEqualTo: mRef)
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
        //print('product web');
      }
    } else {
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productCreatedAt', descending: true)
            .where('productMerchant', isEqualTo: mRef)
            .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.cache))
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
        //print('product cahce');
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('products')
            .orderBy('productCreatedAt', descending: true)
            .where('productMerchant', isEqualTo: mRef)
            .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache))
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
        //print('product web');
      }
    }

    if(document != null){
      document.docs.forEach((element) {
        tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
      });
    }

    return tmp;
  }
  catch(_){
    ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
    return [];}
  }

  static Future<List<Product>> fetchCategoryProduct(String mID, dynamic lastDoc,String category,{int source=0}) async {
    source = await ProductRefreshBloc.instance.getLastRefresh();
   try{
     var mRef = FirebaseFirestore.instance.doc('merchants/$mID');
     List<Product> tmp = List();
     var document;


     if (lastDoc == null) {
       try{
         if(source == 1)
           throw Exception;

         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory',isEqualTo: category)
             .limit(10)
             .get(GetOptions(source: Source.cache))
             .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){ throw Exception;});
         if(document.docs.isEmpty)
           throw Exception;
         //print('pos cahce');
       }
       catch(_){
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory',isEqualTo: category)
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ Utility.noInternet(); throw Exception;});
         ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
         //print('pos web');
       }
     } else {
       try{
         if(source == 1)
           throw Exception;

         //print('pos cahce');
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory',isEqualTo: category)
             .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.cache))
             .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){  throw Exception;});
         if(document.docs.isEmpty)
           throw Exception;
       }
       catch(_){
        // print('pos web');
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory',isEqualTo: category)
             .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ Utility.noInternet(); throw Exception;});
         ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
       }
     }

     if(document != null){
       document.docs.forEach((element) {
         tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
       });
     }

     return tmp;
   }
   catch(_){
     ProductRefreshBloc.instance.addNextRefresh(DateTime.now());
     return [];}
  }

  Future<List<Product>> fetchProduct(
      String mID, dynamic lastDoc, String category,{int source=0}) async {
    source = await GeofenceRefreshBloc.instance.getLastRefresh();
   try{
     var mRef = FirebaseFirestore.instance.doc('merchants/$mID');
     List<Product> tmp = List();
     var document;

     if (lastDoc == null) {

       try{
         if(source == 1)
           throw Exception;

         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory', isEqualTo: category)
             .limit(10)
             .get(GetOptions(source: Source.cache))
             .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){ throw Exception;});
         if(document.docs.isEmpty)
           throw Exception;
       }
       catch(_){
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory', isEqualTo: category)
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); throw Exception;});
         GeofenceRefreshBloc.instance.addNextRefresh(DateTime.now());
       }

     } else {
       //print(lastDoc !=null ?DateTime.parse(lastDoc.pCreatedAt.toDate().toString()):'');
       try{
         if(source == 1)
           throw Exception;
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory', isEqualTo: category)
             .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.cache))
             .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){return null;});
         if(document.docs.isEmpty)
           throw Exception;
       }
       catch(_){
         document = await FirebaseFirestore.instance
             .collection('products')
             .orderBy('productCreatedAt', descending: true)
             .where('productMerchant', isEqualTo: mRef)
             .where('productCategory', isEqualTo: category)
             .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
             .limit(10)
             .get(GetOptions(source: Source.serverAndCache))
             .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); return null;});
         GeofenceRefreshBloc.instance.addNextRefresh(DateTime.now());
       }
     }

     if(document != null){
       document.docs.forEach((element) {
         tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
       });
     }

     return tmp;
   }
   catch(_){
     GeofenceRefreshBloc.instance.addNextRefresh(DateTime.now());
     return [];
   }
  }

 static Future<List<Product>> searchProduct(
      String mID, dynamic lastDoc, String search,{int source=0}) async {
    try{
      var mRef = FirebaseFirestore.instance.doc('merchants/$mID');
      List<Product> tmp = List();
      QuerySnapshot document;

      if (lastDoc == null) {
        try{
          if(source == 1)
            throw Exception;
          document = await FirebaseFirestore.instance
              .collection('products')
              .where('productMerchant', isEqualTo: mRef)
              .where('index', arrayContains: search.toLowerCase())
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty)
            throw Exception;
          //print('search cahce');
        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('products')
              .where('productMerchant', isEqualTo: mRef)
              .where('index', arrayContains: search.toLowerCase())
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          //print('search web');
        }
      } else {
        /*print(lastDoc != null
            ? DateTime.parse(lastDoc.pCreatedAt.toDate().toString())
            : '');*/
        try{
          if(source == 1)
            throw Exception;
          document = await FirebaseFirestore.instance
              .collection('products')
              .where('productMerchant', isEqualTo: mRef)
              .where('index', arrayContains: search.toLowerCase())
              .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
              .limit(10)
              .get(GetOptions(source: Source.cache))
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.docs.isEmpty)
            throw Exception;
          //print('search cahce');
        }
        catch(_){
          document = await FirebaseFirestore.instance
              .collection('products')
              .where('productMerchant', isEqualTo: mRef)
              .where('index', arrayContains: search.toLowerCase())
              .startAfter([DateTime.parse(lastDoc.pCreatedAt.toDate().toString())])
              .limit(10)
              .get(GetOptions(source: Source.serverAndCache))
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
          //print('search web');
        }
      }

      if(document != null){
        document.docs.forEach((element) {
          tmp.add(Product.fromEntity(ProductEntity.fromSnapshot(element)));
        });
      }


      return tmp;
    }
    catch(_){return [];}
  }




}

