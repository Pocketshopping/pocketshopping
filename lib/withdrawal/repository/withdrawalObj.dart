import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

@immutable
class Withdrawal {
  final String wid;
  final String status;
  final double amount;
  final String dateOfTransaction;
  final String owner;
  final String reference;
  final String message;
  final String anSuccess;
  final String transferCode;

  Withdrawal(
      {this.wid,
        this.status,
        this.amount,
        this.dateOfTransaction,
        this.owner,
        this.reference,
        this.message,
        this.anSuccess,
        this.transferCode});

  Withdrawal copyWith({
    String wid,
    String status,
    double amount,
    String dateOfTransaction,
    String owner,
    String reference,
    String message,
    String anSuccess,
    String transferCode,
  }) {
    return Withdrawal(
      wid: wid ?? this.wid,
      status: status ?? this.status,
      dateOfTransaction: dateOfTransaction ?? this.dateOfTransaction,
      owner: owner ?? this.owner,
      reference: reference ?? this.reference,
      message: message ?? this.message,
      amount: amount ?? this.amount,
      anSuccess: anSuccess ?? this.anSuccess,
      transferCode: transferCode ?? this.transferCode,
    );
  }

  @override
  int get hashCode =>
      wid.hashCode ^
      status.hashCode ^
      amount.hashCode ^
      dateOfTransaction.hashCode ^
      owner.hashCode ^
      reference.hashCode ^
      message.hashCode ^
      anSuccess.hashCode ^
      transferCode.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Withdrawal &&
              runtimeType == other.runtimeType &&
              wid == other.wid &&
              status == other.status &&
              amount == other.amount &&
              dateOfTransaction == other.dateOfTransaction &&
              owner == other.owner &&
              reference == other.reference &&
              message == other.message &&
              anSuccess == other.anSuccess &&
              transferCode == other.transferCode;

  Withdrawal update({
    String wid,
    String status,
    double amount,
    String dateOfTransaction,
    String owner,
    String reference,
    String message,
    String anSuccess,
    String transferCode,
  }) {
    return copyWith(
      wid: wid,
      status: status,
      dateOfTransaction: dateOfTransaction,
      owner: owner,
      reference: reference,
      message: message,
      amount: amount,
      anSuccess: anSuccess,
      transferCode: transferCode,
    );
  }

  @override
  String toString() {
    return '''Instance of Withdrawal''';
  }


  static Withdrawal fromMap(Map<String,dynamic> data) {
    return Withdrawal(
        wid: (data['wid']),
        status: (data['status']),
        dateOfTransaction: (data['dateofTansaction']),
        owner: data['owner'],
        message: data['message'],
        reference: data['reference'],
        amount: data['amount'],
        anSuccess: data['anSuccess'],
        transferCode: data['transferCode']);
  }

  static List<Withdrawal> fromListMap(List<Map<String,dynamic>> snap) {
    List<Withdrawal> collection = List();
    snap.forEach((element) {
      collection.add(Withdrawal.fromMap(element));
    });
    return collection;
  }
}
