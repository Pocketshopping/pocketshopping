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
    bid = await databaseReference.collection("orders").add(order.toMap());
    await LogisticRepo.makeAgentBusy(order.agent);
    return bid.documentID;
  }

  static Future<List<Order>> get(
      dynamic lastDoc, int OpenOrClose, String uid) async {
    var snap;
    if (lastDoc == null) {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: OpenOrClose)
          .limit(10)
          .getDocuments();
    } else {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: OpenOrClose)
          .startAfter(
              [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
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
          .getDocuments();
    } else {
      snap = await databaseReference
          .collection('orders')
          .orderBy('orderCreatedAt', descending: true)
          .where("customerID", isEqualTo: uid)
          .where("status", isEqualTo: 1)
          .startAfter(
          [DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
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
    var doc = await databaseReference.collection("orders").document(oid).get();
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

  static Stream<List<Order>> agentOrder(String agentID, {int type=0}) async* {
     yield* databaseReference
        .collection("orders")
        .where('agent',isEqualTo: agentID)
        .where('status',isEqualTo: type)
        .orderBy('orderCreatedAt',descending: true)
         .snapshots().map((event) {return Order.fromListEntity(OrderEntity.fromListSnapshot(event.documents));

    });
  }

  static Stream<int> agentTodayOrder(String agentID) async* {
    yield* databaseReference
        .collection("orders")
        .where('agent',isEqualTo: agentID)
        .where('orderCreatedAt',isGreaterThanOrEqualTo: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .orderBy('orderCreatedAt',descending: true)
        .snapshots().map((event) => event.documents.length);
  }

  static Future<List<Order>> fetchCompletedOrder(String agentID, Order lastDoc) async {
    List<Order> tmp = List();
    print(lastDoc);
    var document;

    if (lastDoc == null) {
      document = await Firestore.instance
          .collection('orders')
          //.orderBy('status',descending: true)
          .orderBy('orderCreatedAt',descending: true)
          .where('agent',isEqualTo: agentID)
          .where('status',isEqualTo: 1)
          .limit(10)
          .getDocuments();
    } else {
      document = await Firestore.instance
          .collection('orders')
          //.orderBy('status',descending: true)
          .orderBy('orderCreatedAt',descending: true)
          .where('agent',isEqualTo: agentID)
          .where('status',isEqualTo: 1)
          .startAfter([DateTime.parse(lastDoc.orderCreatedAt.toDate().toString())])
          .limit(10)
          .getDocuments();
    }
    //tmp.clear();
    document.documents.forEach((element) {
      tmp.add(Order.fromEntity(OrderEntity.fromSnapshot(element)));
    });
    print('dgdg: ${tmp.length}');
    return tmp;
  }



}
