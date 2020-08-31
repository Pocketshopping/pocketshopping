import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:meta/meta.dart';

@immutable
class Pin {
  final dynamic pin;


  Pin({this.pin});

  Pin copyWith({
    dynamic pin
  }) {
    return Pin(
      pin: pin??this.pin
    );
  }

  @override
  int get hashCode => pin.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Pin &&
              runtimeType == other.runtimeType &&
              pin == other.pin;

  Pin update({
    dynamic pin
  }) {
    return copyWith(
     pin: pin
    );
  }

  static hash(String pin){
    var bytes1 = utf8.encode(pin);         // data being hashed
    var hashedPin = sha256.convert(bytes1);
    //print(hashedPin);
    return hashedPin.toString();

  }

  @override
  String toString() {
    return '''Instance of Pin''';
  }

  Map<String, dynamic> toMap() {
    return {
      'pin': hash(pin),
    };
  }

  static Pin fromSnap(DocumentSnapshot snap) {
    return Pin(
        pin: (snap.data()['pin']));

  }


}
