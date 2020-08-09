import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class PocketDebitHistory {
  final String paymentTypeDesc;
  final String channelType;
  final String createdDate;
  final String from;
  final String to;
  final double amount;
  final String status;
  final String collectionID;


  PocketDebitHistory(
      {this.paymentTypeDesc,
        this.channelType,
        this.createdDate,
        this.from,
        this.to,
        this.amount,
        this.status,
        this.collectionID
      });

  PocketDebitHistory copyWith({
    String paymentTypeDesc,
    String channelType,
    String createdDate,
    String from,
    String to,
    double amount,
    String status,
    String collectionID
  }) {
    return PocketDebitHistory(
      paymentTypeDesc: paymentTypeDesc ?? this.paymentTypeDesc,
      channelType: channelType ?? this.channelType,
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      collectionID: collectionID ?? this.collectionID
    );
  }

  @override
  int get hashCode =>
      paymentTypeDesc.hashCode ^
      channelType.hashCode ^
      createdDate.hashCode ^
      from.hashCode ^
      to.hashCode ^
      amount.hashCode ^
      status.hashCode ^
      collectionID.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PocketDebitHistory &&
              runtimeType == other.runtimeType &&
              paymentTypeDesc == other.paymentTypeDesc &&
              channelType == other.channelType &&
              createdDate == other.createdDate &&
              from == other.from &&
              to == other.to &&
              amount == other.amount &&
              status == other.status &&
              collectionID == other.collectionID;

  PocketDebitHistory update({
    String paymentTypeDesc,
    String channelType,
    String createdDate,
    String from,
    String to,
    double amount,
    String status,
    String collectionID
  }) {
    return copyWith(
      paymentTypeDesc: paymentTypeDesc,
      channelType: channelType,
      from: from,
      to: to,
      amount: amount,
      createdDate: createdDate,
      status: status,
      collectionID: collectionID
    );
  }

  @override
  String toString() {
    return '''Instance of PocketDebitHistory''';
  }


  static PocketDebitHistory fromMap(Map<String,dynamic> snap) {
    return PocketDebitHistory(
        paymentTypeDesc: snap['paymentType']['paymentTypeDesc'],
        channelType: snap['channel']['channelType'],
        from: snap['from'],
        to: snap['to'],
        createdDate: snap['createdDate'],
        status: snap['status']['type'],
        amount: snap['amount'],
        collectionID: snap['collectionID'],
    );
  }


  static List<PocketDebitHistory> fromListMap(List<Map<String,dynamic>> snap) {
    List<PocketDebitHistory> collection = List();
    snap.forEach((element) {
      collection.add(PocketDebitHistory.fromMap(element));
    });
    return collection;
  }
}
