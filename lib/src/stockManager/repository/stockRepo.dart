import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/stockManager/repository/stock.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class StockRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<bool> save(Stock stock) async {
    try{
      await databaseReference.collection("productStock").doc(stock.productID).set(stock.toMap()).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await databaseReference.collection('products').doc(stock.productID).update({'productStockCount':stock.stockCount,'isManaging':stock.isManaging});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Stream<List<Stock>> getOneStream(String company) async* {
    try{
      yield* databaseReference.collection("productStock")
          .orderBy('stockCount')
          .where('company',isEqualTo: company)
          .where('stockCount',isLessThan: 10)
          .where('isManaging',isEqualTo: true)
          .snapshots().map((event) => event.docs.isNotEmpty?Stock.fromListSnap(event.docs):[]);
    }
    catch(_){
      yield* null;
    }
  }

  static Future<Stock> getOne(String sid) async {
    try{
      var docs = await databaseReference
          .collection("productStock").doc(sid)
          .get(GetOptions(source: Source.serverAndCache))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return Stock.fromSnap(docs);
    }
    catch(_){
      return null;
    }
  }

  static Future<bool> reStock(Stock old, int newCount,String stockedBy) async {
    try{
      await databaseReference
          .collection("productStock").doc(old.productID).update({
        'restockedBy':stockedBy,
        'restockedAt':Timestamp.now(),
        'stockCount':(old.stockCount + newCount),
        'lastRestockCount':newCount
      }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await databaseReference.collection('products')
          .doc(old.productID).update({'productStockCount':(old.stockCount + newCount)});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> changeStatus(String sid,{bool isManaging=true}) async {
    try{
      await databaseReference
          .collection("productStock").doc(sid).update({
        'isManaging':isManaging,
      }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await databaseReference.collection('products')
          .doc(sid).update({'isManaging':isManaging});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> changeName(String sid,String product) async {
    try{
      await databaseReference
          .collection("productStock").doc(sid).update({
        'product':product,
        'index': Utility.makeIndexList(product)
      }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> buy(String sid,int count) async {
    try{
      Stock stock = await getOne(sid);
      if(stock.isManaging && stock.stockCount > 0){
        await databaseReference
            .collection("productStock").doc(sid).update({
          'stockCount':(stock.stockCount-count),
          'frequency':(stock.frequency +count),
        }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        await databaseReference.collection('products')
            .doc(sid).update({'productStockCount':(stock.stockCount-count)});
      }

      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> buyList(List<OrderItem> sid) async {
    try{
      sid.forEach((element) async{
        await buy(element.ProductId,element.count);
      });
      return true;
    }
    catch(_){
      return false;
    }
    /*try{
      WriteBatch batch  =  databaseReference.batch();
      sid.forEach((request) async{
        batch.update(databaseReference.collection("productStock").doc(request), {
          'stockCount':FieldValue.increment(-1),
          'frequency':FieldValue.increment(1),
        });
      });
      await batch.commit();
      return true;
    }
    catch(_){
      return false;
    }*/
  }





}
