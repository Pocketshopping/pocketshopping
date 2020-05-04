import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/order/repository/order.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';

class OrderRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Order order) async {
    DocumentReference bid;
    bid = await databaseReference.collection("orders").add(order.toMap());

    return bid.documentID;
  }

  static Future<List<Order>> get(
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
    print(orders.length);
    return orders;
  }
}
