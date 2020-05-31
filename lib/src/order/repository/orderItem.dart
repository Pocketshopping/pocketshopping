import 'package:meta/meta.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';

@immutable
class OrderItem {
  final String ProductName;
  final String ProductId;
  final double ProductPrice;
  final int count;
  final double totalAmount;

  OrderItem({
    this.ProductName,
    this.ProductId,
    this.ProductPrice,
    this.count,
    this.totalAmount = 0.0,
  });

  OrderItem copyWith(
      {String ProductName,
      String ProductId,
      double ProductPrice,
      int count,
      double totalAmount}) {
    return OrderItem(
        ProductName: ProductName ?? this.ProductName,
        ProductId: ProductId ?? this.ProductId,
        ProductPrice: ProductPrice ?? this.ProductPrice,
        totalAmount: totalAmount ?? this.totalAmount,
        count: count ?? this.count);
  }

  @override
  int get hashCode =>
      ProductId.hashCode ^
      ProductPrice.hashCode ^
      totalAmount.hashCode ^
      count.hashCode ^
      ProductName.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItem &&
          runtimeType == other.runtimeType &&
          ProductId == other.ProductId &&
          ProductPrice == other.ProductPrice &&
          totalAmount == other.totalAmount &&
          count == other.count &&
          ProductName == other.ProductName;

  @override
  String toString() {
    return '''Instance of OrderItem''';
  }

  static OrderItem fromCart(CartItem cartItem) {
    return OrderItem(
      ProductName: cartItem.item.pName,
      ProductId: cartItem.item.pID,
      ProductPrice: cartItem.item.pPrice,
      count: cartItem.count,
      totalAmount: cartItem.count * cartItem.item.pPrice,
    );
  }

  static OrderItem fromMap(Map<String, dynamic> orderItem) {
    return OrderItem(
      ProductName: orderItem['ProductName'],
      ProductId: orderItem['ProductId'],
      ProductPrice: orderItem['ProductPrice'],
      count: orderItem['count'],
      totalAmount: orderItem['totalAmount'],
    );
  }

  static Map<String, dynamic> toMap(OrderItem orderItem) {
    return {
      'ProductName': orderItem.ProductName,
      'ProductId': orderItem.ProductId,
      'ProductPrice': orderItem.ProductPrice,
      'count': orderItem.count,
      'totalAmount': orderItem.totalAmount,
    };
  }

  static List<Map<String, dynamic>> toListMap(List<OrderItem> orderItems) {
    List<Map<String, dynamic>> collection = List();
    orderItems.forEach((element) {
      collection.add(OrderItem.toMap(element));
    });
    return collection;
  }

  static List<OrderItem> fromListMap(List<dynamic> orderItem) {
    List<OrderItem> collection = List();
    orderItem.forEach((element) {
      collection.add(OrderItem.fromMap(element as Map<String, dynamic>));
    });
    return collection;
  }

  static List<OrderItem> fromCartList(List<CartItem> cart) {
    List<OrderItem> collection = List();
    cart.forEach((element) {
      collection.add(OrderItem.fromCart(element));
    });
    return collection;
  }
}
