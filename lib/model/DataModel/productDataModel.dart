import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';

class ProductDataModel extends Data {
  final databaseReference = Firestore.instance;

  String pID;
  String mID;
  String pName;
  double pPrice;
  String pCategory;
  String pDesc;
  List<String> pPhoto;
  String pGroup;
  String pManufacturer;
  int pStockCount;
  String pQRCode;
  String pMDate;
  String pEDate;
  String pUploader;
  String pReview;
  String pUnit;
  List<File> pFilePhoto;

  ProductDataModel(
      {this.pID,
      this.mID,
      this.pName,
      this.pPrice,
      this.pCategory,
      this.pDesc,
      this.pPhoto,
      this.pGroup,
      this.pManufacturer,
      this.pStockCount,
      this.pQRCode,
      this.pMDate,
      this.pEDate,
      this.pUploader,
      this.pReview,
      this.pUnit,
      this.pFilePhoto});

  @override
  Future<String> save() async {
    var bid = await databaseReference.collection("products").add({
      'productMerchant': databaseReference.document('merchants/$mID'),
      'productName': pName,
      'productPrice': pPrice,
      'productCategory': pCategory,
      'productDesc': pDesc,
      'productPhoto': pPhoto,
      'productGroup': pGroup,
      'productManufacturer': pManufacturer,
      'productStockCount': pStockCount,
      'productQRCode': pQRCode,
      'productMDate': pMDate,
      'productEDate': pEDate,
      'productUploader': databaseReference.document('users/$pUploader'),
      'productReview': databaseReference.document('reviews/$pReview'),
      'productCreatedAt': DateTime.now(),
    });

    await saveCategory();
    await saveProductStock(bid.documentID);

    return bid.documentID;
  }

  @override
  Future<String> saveCategory() async {
    String bid = "";
    await databaseReference
        .collection("productsCategory")
        .document(pCategory)
        .setData({
      'productCategory': pCategory,
      'updatedAt': DateTime.now(),
    });

    return bid;
  }

  
  Future<String> saveProductStock(String pid) async {
    String bid = "";
    await databaseReference.collection("productStock").add({
      'productID': databaseReference.document('products/$pid'),
      'restockedBy': databaseReference.document('users/$pUploader'),
      'restockCount': pStockCount,
      'oldStockCount': 0,
      'StockCount': pStockCount,
      'restockedAt': DateTime.now(),
    }).then((value) => bid = value.documentID.toString());

    return bid;
  }

  @override
  Future<Map<String, dynamic>> getOne() async {
    var document =
        await Firestore.instance.collection('products').document(pID).get(source: Source.server);

    return document.data;
  }

  Future<int> getCount() async {
    var businessRef = databaseReference.document('merchants/$mID');
    var document = await Firestore.instance
        .collection('products')
        .where('productMerchant', isEqualTo: businessRef)
        .getDocuments(source: Source.server);

    return document.documents.length;
  }

  Future<List<String>> getCategory(String pCategory) async {
    List<String> suggestion = List();
    var document = await Firestore.instance
        .collection('productsCategory')
        .where('productCategory', isGreaterThanOrEqualTo: pCategory)
        .where('productCategory', isLessThan: pCategory + 'z')
        .getDocuments(source: Source.server);
    document.documents.forEach((element) {
      suggestion.add(element.documentID);
    });
    // print(suggestion);
    return suggestion;
  }
}
