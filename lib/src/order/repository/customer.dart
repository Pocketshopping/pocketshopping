import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;


@immutable
class Customer {


  final String customerName;
  final String customerTelephone;
  final String customerReview;
  final String customerID;


  Customer({
    this.customerName,
    this.customerTelephone,
    this.customerReview,
    this.customerID
  });

  Customer copyWith({
    String customerName,
    String customerTelephone,
    String customerReview,
    String customerID,
  }) {
    return Customer(
      customerName: customerName??this.customerName,
      customerTelephone: customerTelephone??this.customerTelephone,
      customerReview: customerReview??this.customerReview,
      customerID: customerID??this.customerID,
    );
  }


  @override
  int get hashCode =>
      customerName.hashCode ^ customerTelephone.hashCode ^ customerReview.hashCode ^
      customerID.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Customer &&
              runtimeType == other.runtimeType &&
              customerName == other.customerName &&
              customerTelephone == other.customerTelephone &&
              customerReview == other.customerReview &&
              customerID == other.customerID;



  @override
  String toString() {
    return '''Customer {customerName: $customerName,}''';
  }

  Map<String,dynamic>  toMap(){
    return {
      'customerID': customerID,
      'customerTelephone': customerTelephone,
      'customerReview': customerReview,
      'customerName': customerName
    };
  }

  static Customer fromMap(Map<String,dynamic> customer){
    return Customer(
      customerID: customer['customerID'],
      customerTelephone: customer['customerTelephone'],
      customerReview: customer['customerReview'],
      customerName: customer['customerName']
    );
  }

}