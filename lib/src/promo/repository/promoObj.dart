import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';


@immutable
class Bonus {
  final String bonus;
  final String recipient;
  final Timestamp createdDate;
  final int amount;
  final bool status;
  final String id;


  Bonus({
        this.bonus,
        this.recipient,
        this.createdDate,
        this.amount,
        this.status,
        this.id
      });

  Bonus copyWith({
    String bonus,
    String recipient,
    Timestamp createdDate,
    int amount,
    bool status,
    String id
  }) {
    return Bonus(
        bonus: bonus ?? this.bonus,
        recipient: recipient ?? this.recipient,
        amount: amount ?? this.amount,
        createdDate: createdDate ?? this.createdDate,
        status: status ?? this.status,
        id: id ?? this.id
    );
  }

  @override
  int get hashCode =>
      bonus.hashCode ^
      recipient.hashCode ^
      createdDate.hashCode ^
      amount.hashCode ^
      status.hashCode ^
      id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Bonus &&
              runtimeType == other.runtimeType &&
              bonus == other.bonus &&
              recipient == other.recipient &&
              createdDate == other.createdDate &&
              amount == other.amount &&
              status == other.status &&
              id == other.id;

  Bonus update({
    String bonus,
    String recipient,
    Timestamp createdDate,
    int amount,
    bool status,
    String id
  }) {
    return copyWith(
        bonus: bonus,
        recipient: recipient,
        amount: amount,
        createdDate: createdDate,
        status: status,
        id: id
    );
  }

  @override
  String toString() {
    return '''Instance of Bonus''';
  }


  static Bonus fromMap(DocumentSnapshot snap) {
    return Bonus(
      bonus: snap.data['bonus'],
      recipient: snap.data['recipient'],
      createdDate: snap['createdDate'],
      status: snap.data['status'],
      amount: snap.data['amount'],
      id: snap.documentID,

    );
  }


  static List<Bonus> fromListMap(List<DocumentSnapshot> snap) {
    print(snap.first.data);
    List<Bonus> collection = List();
    snap.forEach((element) {
      collection.add(Bonus.fromMap(element));
    });
    return collection;
  }
}
