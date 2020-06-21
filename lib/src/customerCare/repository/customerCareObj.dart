import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class CustomerCareLine {
  final String number;
  final String name;

  CustomerCareLine(
      {
        this.number,
        this.name

      });

  CustomerCareLine copyWith(
      {
        String number,
        String name
      }) {
    return CustomerCareLine(
        number: number??this.number,
        name: name ?? this.name
    );
  }

  @override
  int get hashCode =>
  
      number.hashCode ^
      name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CustomerCareLine &&
              runtimeType == other.runtimeType &&
              number == other.number; //&&
              //name == other.name;

  CustomerCareLine update(
      {
        String number,
        String name
      }) {
    return copyWith(

        number: number,
        name: name
    );
  }

  @override
  String toString() {
    return '''Instance of CustomerCareLine''';
  }

  Map<String, dynamic> toMap() {
    return {
      '$number':name,
    };
  }

  static List<CustomerCareLine> fromMap(Map<String,dynamic> snap) {
    List<CustomerCareLine> collection=[];
    snap.forEach((key, value) { collection.add(CustomerCareLine(name: value, number: key));});
    return collection;
  }

  static Map<String, dynamic> toBigMap(List<CustomerCareLine> customerCareLine) {
    Map<String, dynamic> collection={};
    customerCareLine.forEach((element) {collection[element.number]=element.name;});
    return collection;

  }

}
