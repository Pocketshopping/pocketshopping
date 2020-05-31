import 'package:meta/meta.dart';
import 'package:pocketshopping/src/order/repository/confirmation.dart';
import 'package:pocketshopping/src/order/repository/customer.dart';
import 'package:pocketshopping/src/order/repository/orderEntity.dart';
import 'package:pocketshopping/src/order/repository/orderItem.dart';
import 'package:pocketshopping/src/order/repository/orderMode.dart';
import 'package:pocketshopping/src/order/repository/receipt.dart';

@immutable
class Order {
  final List<OrderItem> orderItem;
  final double orderAmount;
  final Customer orderCustomer;
  final String orderMerchant;
  final dynamic orderCreatedAt;
  final OrderMode orderMode;
  final int orderETA;
  final Receipt receipt;
  final int status;
  final String orderID;
  final String docID;
  final Confirmation orderConfirmation;
  final String customerID;
  final String agent;

  Order({
      this.orderItem,
      this.orderAmount = 0.0,
      this.orderCustomer,
      this.orderMerchant,
      this.orderCreatedAt,
      this.orderMode,
      this.orderETA,
      this.receipt,
      this.status,
      this.orderID,
      this.docID,
      this.orderConfirmation,
      this.customerID,
      this.agent,
      });

  Order copyWith({

      List<OrderItem> orderItem,
      double orderAmount,
      Customer orderCustomer,
      String orderMerchant,
      dynamic orderCreatedAt,
      OrderMode orderMode,
      int orderETA,
      Receipt receipt,
      int status,
      String orderID,
      String docID,
      Confirmation orderConfirmation,
      String customerID,
      String agent

      }) {
    return Order(
        orderItem: orderItem ?? this.orderItem,
        orderAmount: orderAmount ?? this.orderAmount,
        orderCustomer: orderCustomer ?? this.orderCustomer,
        orderMerchant: orderMerchant ?? this.orderMerchant,
        orderCreatedAt: orderCreatedAt ?? this.orderCreatedAt,
        orderMode: orderMode ?? this.orderMode,
        orderETA: orderETA ?? this.orderETA,
        receipt: receipt ?? this.receipt,
        status: status ?? this.status,
        orderID: orderID ?? this.orderID,
        docID: docID ?? this.docID,
        orderConfirmation: orderConfirmation ?? this.orderConfirmation,
        customerID: customerID ?? this.customerID,
        agent: agent ?? this.agent
    );
  }

  @override
  int get hashCode =>
      orderItem.hashCode ^
      orderAmount.hashCode ^
      orderCustomer.hashCode ^
      orderMerchant.hashCode ^
      orderCreatedAt.hashCode ^
      orderMode.hashCode ^
      orderETA.hashCode ^
      receipt.hashCode ^
      status.hashCode ^
      orderID.hashCode ^
      docID.hashCode ^
      orderConfirmation.hashCode ^
      customerID.hashCode ^
      agent.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Order &&
          runtimeType == other.runtimeType &&
          orderItem == other.orderItem &&
          orderAmount == other.orderAmount &&
          orderCustomer == other.orderCustomer &&
          orderMerchant == other.orderMerchant &&
          orderCreatedAt == other.orderCreatedAt &&
          orderMode == other.orderMode &&
          orderETA == other.orderETA &&
          receipt == other.receipt &&
          status == other.status &&
          orderID == other.orderID &&
          docID == other.docID &&
          orderConfirmation == other.orderConfirmation &&
          customerID == other.customerID &&
          agent == other.agent;

  Order update(
      {List<OrderItem> orderItem,
      double orderAmount,
      Customer orderCustomer,
      String orderMerchant,
      dynamic orderCreatedAt,
      OrderMode orderMode,
      int orderETA,
      Receipt receipt,
      int status,
      String orderID,
      String docID,
      Confirmation orderConfirmation,
      String customerID,
      String agent}) {
    return copyWith(
      orderItem: orderItem,
      orderAmount: orderAmount,
      orderCustomer: orderCustomer,
      orderMerchant: orderMerchant,
      orderCreatedAt: orderCreatedAt,
      orderMode: orderMode,
      orderETA: orderETA,
      receipt: receipt,
      status: status,
      orderID: orderID,
      docID: docID,
      orderConfirmation: orderConfirmation,
      customerID: customerID,
      agent: agent
    );
  }

  @override
  String toString() {
    return '''Instance of Order''';
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItem': OrderItem.toListMap(orderItem),
      'orderAmount': orderAmount,
      'orderCustomer': orderCustomer.toMap(),
      'orderMerchant': orderMerchant,
      'orderCreatedAt': orderCreatedAt,
      'orderMode': orderMode.toMap(),
      'orderETA': orderETA,
      'receipt': receipt.toMap(),
      'status': status,
      'orderID': orderID,
      'docID': docID,
      'orderConfirmation': orderConfirmation.toMap(),
      'customerID': customerID,
      'agent':agent
    };
  }

  static Order fromEntity(OrderEntity orderEntity) {
    return Order(
        orderItem: orderEntity.orderItem,
        orderAmount: orderEntity.orderAmount,
        orderCustomer: orderEntity.orderCustomer,
        orderMerchant: orderEntity.orderMerchant,
        orderCreatedAt: orderEntity.orderCreatedAt,
        orderMode: orderEntity.orderMode,
        orderETA: orderEntity.orderETA,
        receipt: orderEntity.receipt,
        status: orderEntity.status,
        orderID: orderEntity.orderID,
        docID: orderEntity.docID,
        orderConfirmation: orderEntity.orderConfirmation,
        customerID: orderEntity.customerID,
        agent: orderEntity.agent,
        );
  }

  static List<Order> fromListEntity(List<OrderEntity> orderEntity) {
    List<Order> orders=[];
    orderEntity.forEach((element) { orders.add(Order.fromEntity(element));});
    return orders;
  }
}
