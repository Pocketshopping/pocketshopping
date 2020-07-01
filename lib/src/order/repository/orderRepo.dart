import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class OrderRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Order order) async {
    DocumentReference bid;
    bid = await databaseReference.collection("orders").add(await order.toMap());
    //await LogisticRepo.makeAgentBusy(order.agent);
    return bid.documentID;
  }


  static Stream<Order> getOneSnapshot(String order)async* {

    yield* databaseReference.collection("orders").document(order).snapshots().map((event)  {
      return Order.fromEntity(OrderEntity.fromSnapshot(event));
    });
  }

  static Future<bool> removeOnePotential(String order, List<String>potentials)async {

    try{
      if(potentials.isEmpty)
     {
       await databaseReference.collection("orders").document(order).updateData({
         'potentials':potentials,'receipt.pRef':'Rider Currently unavailable.','isAssigned':true,'status':1});
     }
      else{
        await databaseReference.collection("orders").document(order).updateData({
          'potentials':potentials,'receipt.pRef':'Rider Currently unavailable.'});
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
        });
        await LogisticRepo.makeAgentBusy(agentId, isBusy: true);
        await Utility.agentAccept(collectionID: collectionId,
            status: true,
            agent: agentWallet,
            to: logisticWallet);
        return true;
      }

      else return false;

    }
    catch(_){return false;}

  }

  static Stream<List<Order>> getRequestBucket(String agentId)async* {

    yield* databaseReference.collection("orders")
        .where('potentials',arrayContains: agentId)
        .where('isAssigned',isEqualTo: false)
        .where('status',isEqualTo: 0)
        .snapshots().map((event)  {
      return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));
    });
  }

  static Future<List<Order>> get(
      dynamic lastDoc, int openOrClose, String uid) async {
    var snap;
    if (lastDoc == null) {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: openOrClose)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: openOrClose)
          .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
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

  static Future<List<Order>> getCompleted(
      dynamic lastDoc, String uid) async {
    var snap;
    if (lastDoc == null) {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: 1)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: 1)
          .startAfter(
          [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
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

  static Future<void> confirm(String oid, Confirmation confirmation,Receipt receipt,String agent,int fee,int distance,int unit) async {
    await databaseReference.collection("orders").document(oid).updateData({'orderConfirmation': confirmation.toMap(), 'status': 1,'receipt':receipt.toMap()});
    await Utility.finalizePay(collectionID: receipt.collectionID,isSuccessful: true);
    await StatisticRepo.updateAgentStatistic(agent,totalOrderCount: 1,totalAmount: fee,totalDistance: distance,totalUnitUsed: unit);
    await LogisticRepo.makeAgentBusy(agent,isBusy: false);
    //await LogisticRepo.checkRemittance(agent);
  }

  static Future<void> cancel(String oid,Receipt receipt,String agent) async {
    await databaseReference.collection("orders").document(oid).updateData({ 'status': 1,'receipt':receipt.toMap()});
    await Utility.finalizePay(collectionID: receipt.collectionID,isSuccessful: false);
    await StatisticRepo.updateAgentStatistic(agent,totalOrderCount: 1,totalCancelled: 1);
    await LogisticRepo.makeAgentBusy(agent,isBusy: false);
    //await LogisticRepo.checkRemittance(agent);
  }

  static Future<Order> getOne(String oid) async {
    var doc = await databaseReference.collection("orders").document(oid).get(source: Source.serverAndCache);
    return Order.fromEntity(OrderEntity.fromSnapshot(doc));
  }

  static Future<void> review(String oid, Customer orderCustomer) async {
    await databaseReference.collection("orders").document(oid).updateData({
      'orderCustomer': orderCustomer.toMap(),
    });
  }

  static Future<void> isComplete(String oid, Confirmation confirmation) async {
    await databaseReference
        .collection("orders")
        .document(oid)
        .updateData({'status': 1});
  }

  static Stream<List<Order>> agentOrder(String agentID, {int type=0,String whose= 'agent'}) async* {
     yield* databaseReference
        .collection("orders")
        .where('$whose',isEqualTo: agentID)
        .where('status',isEqualTo: type)
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

  static Future<List<Order>> fetchCompletedOrder(String agentID, Order lastDoc,{String whose= 'agent'}) async {
    List<Order> tmp = List();
    print(lastDoc);
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('orders')
          //.orderBy('status',descending: true)
          .orderBy('orderCreatedAt',descending: true)
          .where('$whose',isEqualTo: agentID)
          .where('status',isEqualTo: 1)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('orders')
          //.orderBy('status',descending: true)
          .orderBy('orderCreatedAt',descending: true)
          .where('$whose',isEqualTo: agentID)
          .where('status',isEqualTo: 1)
          .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }
    //tmp.clear();
    document.documents.forEach((element) {
      tmp.add(Order.fromEntity(OrderEntity.fromSnapshot(element)));
    });
    return tmp;
  }


  static Future<int> getUnclaimedDelivery(String agentID)async{
    QuerySnapshot document;
    try{
      document = await Firestore.instance
          .collection('orders')
          .orderBy('orderCreatedAt',descending: true)
          .where('potentials',arrayContains: agentID)
          .where('status',isEqualTo: 0)
          .where('isAssigned',isEqualTo: false)
          .getDocuments(source: Source.server);
      return document.documents.length;
    }
    catch(_){
      return 0;
    }
    
  }






}
