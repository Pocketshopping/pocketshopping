import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';

class OrderRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Order order) async {
    DocumentReference bid;
    bid = await databaseReference.collection("orders").add(order.toMap());
    return bid.documentID;
  }

  static Future<dynamic> get(
      dynamic lastDoc, String OpenOrClose, String uid) async {
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
      return [SearchEmptyOrderIndicatorTitle];
  }

  static Future<void> confirm(String oid, Confirmation confirmation) async {
    await databaseReference.collection("orders").document(oid).updateData(
        {'orderConfirmation': confirmation.toMap(), 'status': 'COMPLETED'});
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
        .updateData({'status': 'COMPLETED'});
  }
}
