

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/stockManager/repository/stockRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class OrderRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Order order) async {
    try{
      DocumentReference bid;
      bid = await databaseReference.collection("orders").add(await order.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});
      if(bid != null)
      {
        if(order.status == 1 && order.receipt.psStatus == 'success'){
          StatisticRepo.saveTransaction({
            'oid':bid.documentID,
            'mid':order.orderMerchant,
            'sid':order.agent,
            'insertedAt':Timestamp.now(),
            'day':DateTime.now().weekday,
            'items': OrderItem.toNames(order.orderItem),
            'amount':order.orderAmount
          });
          StockRepo.buyList(order.orderItem);
        }

        return bid.documentID;
      }
      else
        return '';
    }
    catch(_){
      return '';
    }
  }


  static Stream<Order> getOneSnapshot(String order)async* {

    yield* databaseReference.collection("orders").document(order).snapshots().map((event)  {
      return Order.fromEntity(OrderEntity.fromSnapshot(event));
    });
  }

  static Future<bool> removeOnePotential(String order, String collectionID,String cDevice, List<String>potentials)async {

    try{
      if(potentials.isEmpty)
     {
       await databaseReference.collection("orders").document(order).updateData({
         'potentials':potentials,'receipt.pRef':'Rider Currently unavailable.','isAssigned':true,'status':1,'receipt.psStatus':'fail'})
           .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
       await Utility.finalizePay(collectionID: collectionID,isSuccessful: false);
       await Utility.pushNotifier(body: 'Your order has been cancelled(Rider currently unavailable)', title: 'Delivey Cancelled',fcm: cDevice);

     }
      else{
        await databaseReference.collection("orders").document(order).updateData({
          'potentials':potentials,'receipt.pRef':'Rider Currently unavailable.'})
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
      return true;
    }
    catch(_){return false;}

  }


  static Future<bool> convertPotential({String orderId,
    String agentId,String logisticId,String agentName,
    List<String> index,String agentWallet,String collectionId,String logisticWallet})async {
    try{
      Order order = await getOne(orderId);
      Merchant merchant = await MerchantRepo.getMerchant(order.orderMerchant);
      if(!order.isAssigned) {
        await databaseReference.collection("orders")
            .document(orderId)
            .updateData({
          'agent': '$agentId',
          'orderLogistic': '$logisticId',
          'orderMode.deliveryMan': '$agentName',
          'index': index,
          'potentials': [],
          'isAssigned': true,
        }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        await LogisticRepo.makeAgentBusy(agentId, isBusy: true);
        await Utility.agentAccept(collectionID: collectionId,
            status: true,
            agent: agentWallet,
            to: logisticWallet);
        if(order.orderMode.mode == 'Errand'){
          await setCurrentPathLine(CurrentPathLine(
              id: agentId,
              hasVisitedDestination: false,
              hasVisitedSource: false,
              source: order.errand.source,
              destination: order.errand.destination
          ));
        }
        else{
          await setCurrentPathLine(CurrentPathLine(
              id: agentId,
              hasVisitedDestination: false,
              hasVisitedSource: false,
              source: GeoPoint(
                  merchant.bGeoPoint['geopoint']
                      .latitude,
                  merchant.bGeoPoint['geopoint']
                      .longitude
              ),
              destination: order.orderMode.coordinate
          ));
        }
        return true;
      }

      else return false;

    }
    catch(_){return false;}

  }


  static Stream<List<Order>> getExpiredRequestBucket(String agentId)async* {

    yield* databaseReference.collection("orders")
        .where('potentials',arrayContains: agentId)
        .where('isAssigned',isEqualTo: false)
        .where('status',isEqualTo: 0)
        .where('etc',isLessThan: Timestamp.now())
        .snapshots().map((event)  {
      return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));
    });
  }


  static Stream<List<Order>> getRequestBucket(String agentId)async* {

    yield* databaseReference.collection("orders")
        .where('potentials',arrayContains: agentId)
        .where('isAssigned',isEqualTo: false)
        .where('status',isEqualTo: 0)
        //.where('etc',isLessThan: Timestamp.now())
        .snapshots().map((event)  {
      return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));
    });
  }

  static Future<List<Order>> get(
      dynamic lastDoc, int openOrClose, String uid,{int source=0}) async {
    try{
      QuerySnapshot snap;
      if (lastDoc == null) {
        try{
          if(source == 1)throw Exception;
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: openOrClose)
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(snap.documents.isEmpty)throw Exception;
        }
        catch(_){
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: openOrClose)
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      } else {
        try{
          if(source == 1)throw Exception;
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: openOrClose)
              .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(snap.documents.isEmpty)throw Exception;
        }
        catch(_){
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: openOrClose)
              .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      }

      List<Order> orders = [];
      snap.documents.forEach((doc) {
        orders.add(Order.fromEntity(OrderEntity.fromSnapshot(doc)));
      });
      if (orders.length > 0)
        return orders;
      else
        return [];
    }
    catch(_){
      return [];
    }
  }

  static Future<List<Order>> getCompleted(
      dynamic lastDoc, String uid,{int source=0}) async {
    try{
      QuerySnapshot snap;
      if (lastDoc == null) {
        try{
          if(source == 1)throw Exception;
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: 1)
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(snap.documents.isEmpty)throw Exception;
        }
        catch(_){
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: 1)
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      } else {
        try{
          if(source == 1)throw Exception;
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: 1)
              .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(snap.documents.isEmpty)throw Exception;
        }
        catch(_){
          snap = await databaseReference
              .collection('orders')
              .orderBy('orderCreatedAt', descending: true)
              .where("customerID", isEqualTo: uid)
              .where("status", isEqualTo: 1)
              .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      }

      List<Order> orders = [];
      snap.documents.forEach((doc) {
        orders.add(Order.fromEntity(OrderEntity.fromSnapshot(doc)));
      });
      if (orders.length > 0)
        return orders;
      else
        return [];
    }
    catch(_){
      return [];
    }
  }

  static Future<void> confirm(Order oid, Confirmation confirmation,Receipt receipt,String agent,int fee,int distance,int unit) async {
    try{
      await databaseReference.collection("orders").document(oid.docID).updateData({'orderConfirmation': confirmation.toMap(), 'status': 1,'receipt':receipt.toMap()})
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await Utility.finalizePay(collectionID: receipt.collectionID,isSuccessful: true);
      await StatisticRepo.updateAgentStatistic(agent,totalOrderCount: 1,totalAmount: fee,totalDistance: distance,totalUnitUsed: unit);
      await LogisticRepo.makeAgentBusy(agent,isBusy: false);
      if(receipt.psStatus == 'success'){
        StatisticRepo.saveTransaction({
          'oid':oid.docID,
          'mid':oid.orderMerchant,
          'sid':oid.agent,
          'insertedAt':Timestamp.now(),
          'day':DateTime.now().weekday,
          'items': OrderItem.toNames(oid.orderItem),
          'amount':oid.orderAmount
        });
        StockRepo.buyList(oid.orderItem);
      }
    }
    catch(_){}

    //await LogisticRepo.checkRemittance(agent);
  }

  static Future<void> cancel(String oid,Receipt receipt,String agent) async {
    try{
      await databaseReference.collection("orders").document(oid).updateData({ 'status': 1,'receipt':receipt.toMap()});
      await Utility.finalizePay(collectionID: receipt.collectionID,isSuccessful: false);
      await StatisticRepo.updateAgentStatistic(agent,totalOrderCount: 1,totalCancelled: 1);
      await LogisticRepo.makeAgentBusy(agent,isBusy: false);
    }
    catch(_){}
    //await LogisticRepo.checkRemittance(agent);
  }

  static Future<Order> getOne(String oid,{int source=0}) async {
    try{
      try{
        if(source == 1)throw Exception;
        var doc = await databaseReference.collection("orders").document(oid).get(source: Source.cache)
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(!doc.exists)throw Exception;
        return Order.fromEntity(OrderEntity.fromSnapshot(doc));
      }
      catch(_){
        var doc = await databaseReference.collection("orders").document(oid).get(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        return Order.fromEntity(OrderEntity.fromSnapshot(doc));
      }
    }
    catch(_){
      return null;
    }
  }

  static Future<bool> review(String oid, Customer orderCustomer) async {
    try{
      await databaseReference.collection("orders").document(oid).updateData({
        'orderCustomer': orderCustomer.toMap(),
      }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<bool> resolution(String oid, String resolution) async {
    try{
      await databaseReference.collection("orders").document(oid).updateData({
        'resolution': resolution,
      }).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<void> isComplete(String oid, Confirmation confirmation) async {
    try{
      await databaseReference
          .collection("orders")
          .document(oid)
          .updateData({'status': 1})
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
    }
    catch(_){}
  }

  static Stream<List<Order>> agentOrder(String agentID, {int type=0,String whose= 'agent'}) async* {
     yield* databaseReference
        .collection("orders")
        .where('$whose',isEqualTo: agentID)
        .where('status',isEqualTo: type)
         .where('isAssigned',isEqualTo: true)
        .orderBy('orderCreatedAt',descending: true)
        .limit(50)
         .snapshots().map((event) {return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));

    });
  }

  static Stream<int> agentBucketCount(String agentID) async* {
    yield* databaseReference
        .collection("orders")
        .where('potentials',arrayContains: agentID)
        .where('status',isEqualTo: 0)
        .where('isAssigned',isEqualTo: false)
        .limit(50)
        .snapshots().map((event) {return event.documents.length;

    });
  }

  static Stream<List<Order>> searchAgentOrder(String agentID,String keyword, {int type=0,String whose= 'agent'}) async* {
    yield* databaseReference
        .collection("orders")
        .where('$whose',isEqualTo: agentID)
        .where('status',isEqualTo: type)
        .orderBy('orderCreatedAt',descending: true)
        .where('index',arrayContains: keyword)
        .limit(50)
        .snapshots().map((event) {return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));

    });
  }

  static Stream<int> agentTodayOrder(String agentID,{String whose= 'agent'}) async* {
    yield* databaseReference
        .collection("orders")
        .where('$whose',isEqualTo: agentID)
        .where('orderCreatedAt',isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .orderBy('orderCreatedAt',descending: true)
        .snapshots().map((event) => event.documents.length);
  }

  static Future<List<Order>> fetchCompletedOrder(String agentID, Order lastDoc,{String whose= 'agent',int source=0}) async {
  try{
    List<Order> tmp = List();
    //print(lastDoc);
    QuerySnapshot document;

    if (lastDoc == null) {
      try{
        if(source == 1)throw Exception;
        document = await Firestore.instance
            .collection('orders')
        //.orderBy('status',descending: true)
            .orderBy('orderCreatedAt',descending: true)
            .where('$whose',isEqualTo: agentID)
            .where('status',isEqualTo: 1)
            .limit(10)
            .getDocuments(source: Source.cache)
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.documents.isEmpty)throw Exception;
      }
      catch(_){
        document = await Firestore.instance
            .collection('orders')
        //.orderBy('status',descending: true)
            .orderBy('orderCreatedAt',descending: true)
            .where('$whose',isEqualTo: agentID)
            .where('status',isEqualTo: 1)
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    } else {
      try{
        if(source == 1)throw Exception;
        document = await Firestore.instance
            .collection('orders')
        //.orderBy('status',descending: true)
            .orderBy('orderCreatedAt',descending: true)
            .where('$whose',isEqualTo: agentID)
            .where('status',isEqualTo: 1)
            .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.documents.isEmpty)throw Exception;
      }
      catch(_){
        document = await Firestore.instance
            .collection('orders')
        //.orderBy('status',descending: true)
            .orderBy('orderCreatedAt',descending: true)
            .where('$whose',isEqualTo: agentID)
            .where('status',isEqualTo: 1)
            .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    }
    //tmp.clear();
    document.documents.forEach((element) {
      tmp.add(Order.fromEntity(OrderEntity.fromSnapshot(element)));
    });
    return tmp;
  }
  catch(_){
    return [];
  }
  }

  static Future<List<Order>> fetchStaffOrder(String id, String mid,Order lastDoc,{String whose= 'agent', int source=0}) async {
    try{
      List<Order> tmp = List();
      QuerySnapshot document;

      if (lastDoc == null) {
        try{
          if(source == 1)throw Exception;
          document = await Firestore.instance
              .collection('orders')
              .orderBy('orderCreatedAt',descending: true)
              .where('$whose',isEqualTo: id)
              .where('orderMerchant',isEqualTo: mid)
              .where('status',isEqualTo: 1)
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.documents.isEmpty)throw Exception;
        }
        catch(_){
          document = await Firestore.instance
              .collection('orders')
              .orderBy('orderCreatedAt',descending: true)
              .where('$whose',isEqualTo: id)
              .where('orderMerchant',isEqualTo: mid)
              .where('status',isEqualTo: 1)
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      } else {
        try{
          if(source == 1)throw Exception;
          document = await Firestore.instance
              .collection('orders')
              .orderBy('orderCreatedAt',descending: true)
              .where('$whose',isEqualTo: id)
              .where('orderMerchant',isEqualTo: mid)
              .where('status',isEqualTo: 1)
              .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.cache)
              .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
          if(document.documents.isEmpty)throw Exception;
        }
        catch(_){
          document = await Firestore.instance
              .collection('orders')
              .orderBy('orderCreatedAt',descending: true)
              .where('$whose',isEqualTo: id)
              .where('orderMerchant',isEqualTo: mid)
              .where('status',isEqualTo: 1)
              .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
              .limit(10)
              .getDocuments(source: Source.serverAndCache)
              .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        }
      }
      if(document != null){
        document.documents.forEach((element) {
          tmp.add(Order.fromEntity(OrderEntity.fromSnapshot(element)));
        });
      }
      return tmp;
    }
    catch(_){
      return [];
    }
  }

  static Future<List<Order>> fetchAllTransaction(String mid,Order lastDoc) async {
    try{
      List<Order> tmp = List();
      var document;

      if (lastDoc == null) {
        document = await Firestore.instance
            .collection('orders')
            .orderBy('orderCreatedAt',descending: true)
            .where('orderMerchant',isEqualTo: mid)
            .where('status',isEqualTo: 1)
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      } else {
        document = await Firestore.instance
            .collection('orders')
            .orderBy('orderCreatedAt',descending: true)
            .where('orderMerchant',isEqualTo: mid)
            .where('status',isEqualTo: 1)
            .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
            .limit(10)
            .getDocuments(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
      if(document != null){
        document.documents.forEach((element) {
          tmp.add(Order.fromEntity(OrderEntity.fromSnapshot(element)));
        });
      }
      return tmp;
    }
    catch(_){
      return [];
    }
  }




  static Future<int> getUnclaimedDelivery(String agentID)async{

    try{
      QuerySnapshot document;
      document = await Firestore.instance
          .collection('orders')
          .orderBy('orderCreatedAt',descending: true)
          .where('potentials',arrayContains: agentID)
          .where('status',isEqualTo: 0)
          .where('isAssigned',isEqualTo: false)
          .getDocuments(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return document.documents.length;
    }
    catch(_){
      return 0;
    }
    
  }

  static Future<bool> setCurrentPathLine(CurrentPathLine cpl)async{
    try{
      await Firestore.instance.collection('pathLine').document(cpl.id).setData(cpl.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<CurrentPathLine> getCurrentPathLine(String cpl)async{
    try{
     var doc = await Firestore.instance.collection('pathLine').document(cpl).get(source: Source.server)
         .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return doc.exists?CurrentPathLine.fromSnap(doc):null;
    }
    catch(_){
      return null;
    }
  }

  static Stream<CurrentPathLine> currentPathLineStream(String cpl)async*{
    try{
      yield* Firestore.instance.collection('pathLine').document(cpl).snapshots().map((event) => CurrentPathLine.fromSnap(event));
    }
    catch(_){}
  }





}
