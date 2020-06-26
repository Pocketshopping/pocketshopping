import 'package:meta/meta.dart';

@immutable
class Permission {
  final bool finances;
  final bool managers;
  final bool sales;
  final bool products;
  final bool logistic;


  Permission(
      {this.finances,
      this.managers,
      this.sales,
      this.products,
      this.logistic,
      });

  Permission copyWith({
    bool finances,
    bool managers,
    bool sales,
    bool products,
    bool logistic,
  }) {
    return Permission(
      finances: finances ?? this.finances,
      managers: managers ?? this.managers,
      sales: sales ?? this.sales,
      products: products ?? this.products,
      logistic: logistic ?? this.logistic,
    );
  }

  @override
  int get hashCode =>
      finances.hashCode ^
      managers.hashCode ^
      sales.hashCode ^
      products.hashCode ^
      logistic.hashCode ;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Permission &&
          runtimeType == other.runtimeType &&
          finances == other.finances &&
          managers == other.managers &&
          sales == other.sales &&
          products == other.products &&
          logistic == other.logistic;

  Permission update({
    bool finances,
    bool managers,
    bool sales,
    bool products,
    bool logistic,
  }) {
    return copyWith(
        finances: finances,
        managers: managers,
        sales: sales,
        products: products,
        logistic: logistic,);
  }

  @override
  String toString() {
    return '''Instance of Permission''';
  }

  Map<String, dynamic> toMap() {
    return {
      'finances': finances,
      'managers': managers,
      'sales': sales,
      'products': products,
      'logistic': logistic,
    };
  }

  static Permission fromMap(Map<String, dynamic> snap) {
    return Permission(
        finances: (snap['finances']),
        managers: (snap['managers']),
        sales: (snap['sales']),
        products: snap['products'],
        logistic: snap['logistic'],
        );
  }
}
