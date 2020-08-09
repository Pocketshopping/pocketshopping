import 'package:meta/meta.dart';


@immutable
class PocketHistory {
  final String paymentTypeDesc;
  final String channelType;
  final int channelId;
  final DateTime createdDate;
  final String from;
  final String to;
  final double amount;
  final String status;
  final String collectionID;


  PocketHistory(
      {this.paymentTypeDesc,
        this.channelType,
        this.createdDate,
        this.from,
        this.to,
        this.amount,
        this.status,
        this.collectionID,
        this.channelId
      });

  PocketHistory copyWith({
    String paymentTypeDesc,
    String channelType,
    DateTime createdDate,
    String from,
    String to,
    double amount,
    String status,
    String collectionID,
    int channelId
  }) {
    return PocketHistory(
      paymentTypeDesc: paymentTypeDesc ?? this.paymentTypeDesc,
      channelType: channelType ?? this.channelType,
      from: from ?? this.from,
      to: to ?? this.to,
      amount: amount ?? this.amount,
      createdDate: createdDate ?? this.createdDate,
      status: status ?? this.status,
      collectionID: collectionID ?? this.collectionID,
      channelId: channelId ?? this.channelId
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
      collectionID.hashCode ^
      channelId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is PocketHistory &&
              runtimeType == other.runtimeType &&
              paymentTypeDesc == other.paymentTypeDesc &&
              channelType == other.channelType &&
              createdDate == other.createdDate &&
              from == other.from &&
              to == other.to &&
              amount == other.amount &&
              status == other.status &&
              collectionID == other.collectionID &&
              channelId == other.channelId;

  PocketHistory update({
    String paymentTypeDesc,
    String channelType,
    DateTime createdDate,
    String from,
    String to,
    double amount,
    String status,
    String collectionID,
    int channelId
  }) {
    return copyWith(
      paymentTypeDesc: paymentTypeDesc,
      channelType: channelType,
      from: from,
      to: to,
      amount: amount,
      createdDate: createdDate,
      status: status,
      collectionID: collectionID,
      channelId: channelId
    );
  }

  @override
  String toString() {
    return '''Instance of PocketHistory''';
  }


  static PocketHistory fromMap(Map<String,dynamic> snap) {
    return PocketHistory(
        paymentTypeDesc: snap['paymentType']['paymentTypeDesc'],
        channelType: snap['channel']['channelType'],
        channelId: snap['channel']['channelId'],
        from: snap['from'],
        to: snap['to'],
        createdDate: DateTime.parse(snap['createdDate']),
        status: snap['status']['type'],
        amount: snap['amount'],
        collectionID: snap['collectionID'],

    );
  }


  static List<PocketHistory> fromListMap(List<Map<String,dynamic>> snap) {
    List<PocketHistory> collection = List();
    snap.forEach((element) {
      collection.add(PocketHistory.fromMap(element));
    });
    return collection;
  }
}
