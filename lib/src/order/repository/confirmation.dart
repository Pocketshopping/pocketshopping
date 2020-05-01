import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class Confirmation {

  final dynamic confirmedAt;
  final String confirmOTP;
  final bool isConfirmed;

  Confirmation({
    this.confirmedAt,
    this.confirmOTP,
    this.isConfirmed=false,
  });

  Confirmation copyWith({
    dynamic confirmedAt,
    String confirmOTP,
    bool isConfirmed,
  }) {
    return Confirmation(
        confirmedAt: confirmedAt??this.confirmedAt,
        confirmOTP: confirmOTP??this.confirmOTP,
        isConfirmed: isConfirmed??this.isConfirmed,
    );
  }


  @override
  int get hashCode =>
      confirmedAt.hashCode ^ confirmOTP.hashCode ^ isConfirmed.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Confirmation &&
              runtimeType == other.runtimeType &&
              confirmedAt == other.confirmedAt &&
              confirmOTP == other.confirmOTP &&
              isConfirmed == other.isConfirmed;



  @override
  String toString() {
    return '''Confirmation {confirmedAt: $confirmedAt,}''';
  }

  Map<String,dynamic> toMap(){

    return {
      'confirmedAt': this.confirmedAt,
      'confirmOTP': this.confirmOTP,
      'isConfirmed': this.isConfirmed,
    };
  }

  static Confirmation fromMap(Map<String,dynamic> confirmation){

    return Confirmation(
      confirmedAt: confirmation['confirmedAt'],
      confirmOTP: confirmation['confirmOTP'],
      isConfirmed: confirmation['isConfirmed'],
    );
  }

}