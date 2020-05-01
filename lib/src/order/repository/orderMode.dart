import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class OrderMode {

  final String mode;
  final String tableNumber;
  final GeoPoint coordinate;
  final String address;
  final String deliveryMan;
  final String acceptedBy;
  final int fee;

  OrderMode({
    this.mode,
    this.tableNumber,
    this.coordinate,
    this.address,
    this.deliveryMan,
    this.acceptedBy,
    this.fee,
  });

  OrderMode copyWith({
    String mode,
    String tableNumber,
    GeoPoint coordinate,
    String address,
    String deliveryMan,
    String acceptedBy,
    int fee,

  }) {
    return OrderMode(
        mode: mode??this.mode,
        tableNumber: tableNumber??this.tableNumber,
        coordinate: coordinate??this.coordinate,
        address: address??this.address,
        deliveryMan:deliveryMan??this.deliveryMan,
        acceptedBy:acceptedBy??this.acceptedBy,
        fee: fee??this.fee
    );
  }


  @override
  int get hashCode =>
      mode.hashCode ^ tableNumber.hashCode ^ coordinate.hashCode ^ address.hashCode ^
      deliveryMan.hashCode ^ acceptedBy.hashCode ^ fee.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is OrderMode &&
              runtimeType == other.runtimeType &&
              mode == other.mode &&
              tableNumber == other.tableNumber &&
              coordinate == other.coordinate &&
              address == other.address &&
              deliveryMan == other.deliveryMan &&
              acceptedBy == other.acceptedBy &&
              fee == other.fee;



  @override
  String toString() {
    return '''OrderMode {mode: $mode,}''';
  }

  Map<String,dynamic>  toMap(){
    return {
      'mode': mode,
      'tableNumber': tableNumber,
      'coordinate': coordinate,
      'address': address,
      'deliveryMan': deliveryMan,
      'acceptedBy': acceptedBy,
      'fee': fee,
    };
  }

  static OrderMode fromMap(Map<String,dynamic> ordermode){
    return OrderMode(
      mode: ordermode['mode'],
      tableNumber: ordermode['tableNumber'],
      coordinate: ordermode['coordinate'],
      address: ordermode['address'],
      deliveryMan: ordermode['deliveryMan'],
      acceptedBy: ordermode['acceptedBy'],
      fee: ordermode['fee'],
    );
  }

}