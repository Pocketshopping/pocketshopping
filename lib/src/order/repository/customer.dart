import 'package:meta/meta.dart';

@immutable
class Customer {
  final String customerName;
  final String customerTelephone;
  final String customerReview;

  Customer({
    this.customerName,
    this.customerTelephone,
    this.customerReview,
  });

  Customer copyWith({
    String customerName,
    String customerTelephone,
    String customerReview,
  }) {
    return Customer(
      customerName: customerName ?? this.customerName,
      customerTelephone: customerTelephone ?? this.customerTelephone,
      customerReview: customerReview ?? this.customerReview,
    );
  }

  @override
  int get hashCode =>
      customerName.hashCode ^
      customerTelephone.hashCode ^
      customerReview.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer &&
          runtimeType == other.runtimeType &&
          customerName == other.customerName &&
          customerTelephone == other.customerTelephone &&
          customerReview == other.customerReview;

  @override
  String toString() {
    return '''Customer {customerName: $customerName,}''';
  }

  Map<String, dynamic> toMap() {
    return {
      'customerTelephone': customerTelephone,
      'customerReview': customerReview,
      'customerName': customerName
    };
  }

  static Customer fromMap(Map<String, dynamic> customer) {
    return Customer(
        customerTelephone: customer['customerTelephone'],
        customerReview: customer['customerReview'],
        customerName: customer['customerName']);
  }
}
