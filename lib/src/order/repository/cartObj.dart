import 'package:pocketshopping/src/admin/product/repository/productObj.dart';

class CartItem {
  Product item;
  int count;
  double total;

  CartItem({
    this.item,
    this.count = 1,
    this.total = 0.0,
  });

  CartItem copyWith({
    Product item,
    int count,
    double total,
  }) {
    return CartItem(
        item: item ?? this.item,
        count: count ?? this.count,
        total: total ?? this.total);
  }

  @override
  int get hashCode => item.hashCode ^ count.hashCode ^ total.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          item == other.item;

  @override
  String toString() {
    return '''CartItem {
        item: $item,
    count: $count,
    total: $total,
    }''';
  }

  static Map<String, dynamic> toMap(CartItem cartItem) {
    return {
      'productName': cartItem.item.pName,
      'productCount': cartItem.count,
    };
  }

  static List<Map<String, dynamic>> toListMap(List<CartItem> cartItem) {
    List<Map<String, dynamic>> collection = List();
    cartItem.forEach((element) {
      collection.add(CartItem.toMap(element));
    });
    return collection;
  }
}
