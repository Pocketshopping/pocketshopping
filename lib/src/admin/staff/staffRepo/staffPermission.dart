import 'package:meta/meta.dart';

@immutable
class Permission {
  final bool finances;
  final bool managers;
  final bool messages;
  final bool orders;
  final bool products;
  final bool deliveryOp;
  final bool deliveryAgent;

  Permission(
      {this.finances,
      this.managers,
      this.messages,
      this.orders,
      this.products,
      this.deliveryOp,
      this.deliveryAgent});

  Permission copyWith({
    bool finances,
    bool managers,
    bool messages,
    bool orders,
    bool products,
    bool deliveryOp,
    bool deliveryAgent,
  }) {
    return Permission(
      finances: finances ?? this.finances,
      managers: managers ?? this.managers,
      messages: messages ?? this.messages,
      orders: orders ?? this.orders,
      products: products ?? this.products,
      deliveryOp: deliveryOp ?? this.deliveryOp,
      deliveryAgent: deliveryAgent ?? this.deliveryAgent,
    );
  }

  @override
  int get hashCode =>
      finances.hashCode ^
      managers.hashCode ^
      messages.hashCode ^
      orders.hashCode ^
      products.hashCode ^
      deliveryOp.hashCode ^
      deliveryAgent.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permission &&
          runtimeType == other.runtimeType &&
          finances == other.finances &&
          managers == other.managers &&
          messages == other.messages &&
          orders == other.orders &&
          products == other.products &&
          deliveryOp == other.deliveryOp &&
          deliveryAgent == other.deliveryAgent;

  Permission update({
    bool finances,
    bool managers,
    bool messages,
    bool orders,
    bool products,
    bool deliveryOp,
    bool deliveryAgent,
  }) {
    return copyWith(
        finances: finances,
        managers: managers,
        messages: messages,
        orders: orders,
        products: products,
        deliveryOp: deliveryOp,
        deliveryAgent: deliveryAgent);
  }

  @override
  String toString() {
    return '''Permission ${finances && managers && messages && orders && products && deliveryOp && deliveryAgent}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'finances': finances,
      'managers': managers,
      'messages': messages,
      'orders': orders,
      'products': products,
      'deliveryOp': deliveryOp,
      'deliveryAgent': deliveryAgent
    };
  }

  static Permission fromMap(Map<String, dynamic> snap) {
    return Permission(
        finances: (snap['finances']),
        managers: (snap['managers']),
        messages: (snap['messages']),
        orders: (snap['orders']),
        products: snap['products'],
        deliveryOp: snap['deliveryOp'],
        deliveryAgent: snap['deliveryAgent']);
  }
}
