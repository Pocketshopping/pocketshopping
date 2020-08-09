import 'package:meta/meta.dart';


@immutable
class Ticket {
  final String id;
  final String category;
  final DateTime dateTime;
  final String customerDetail;
  final String customerID;
  final bool isResolved;
  final String status;
  final String complain;


  Ticket(
      {this.id,
        this.category,
        this.dateTime,
        this.customerDetail,
        this.customerID,
        this.isResolved,
        this.status,
        this.complain
      });

  Ticket copyWith({
    String id,
    String category,
    DateTime dateTime,
    String customerDetail,
    String customerID,
    bool isResolved,
    String status,
    String complain
  }) {
    return Ticket(
        id: id ?? this.id,
        category: category ?? this.category,
        customerDetail: customerDetail ?? this.customerDetail,
        customerID: customerID ?? this.customerID,
        isResolved: isResolved ?? this.isResolved,
        dateTime: dateTime ?? this.dateTime,
        status: status ?? this.status,
        complain: complain ?? this.complain
    );
  }

  @override
  int get hashCode =>
      id.hashCode ^
      category.hashCode ^
      dateTime.hashCode ^
      customerDetail.hashCode ^
      customerID.hashCode ^
      isResolved.hashCode ^
      status.hashCode ^
      complain.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Ticket &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              category == other.category &&
              dateTime == other.dateTime &&
              customerDetail == other.customerDetail &&
              customerID == other.customerID &&
              isResolved == other.isResolved &&
              status == other.status &&
              complain == other.complain;

  Ticket update({
    String id,
    String category,
    DateTime dateTime,
    String customerDetail,
    String customerID,
    bool isResolved,
    String status,
    String complain
  }) {
    return copyWith(
        id: id,
        category: category,
        customerDetail: customerDetail,
        customerID: customerID,
        isResolved: isResolved,
        dateTime: dateTime,
        status: status,
        complain: complain
    );
  }

  @override
  String toString() {
    return '''Instance of Ticket''';
  }


  static Ticket fromMap(Map<String,dynamic> snap) {
    return Ticket(
      id: snap['id'],
      category: snap['category'],
      customerDetail: snap['customerDetail'],
      customerID: snap['customerID'],
      dateTime: DateTime.parse(snap['dateTime']),
      status: snap['status'],
      isResolved: snap['isResolved'],
      complain: snap['complain'],

    );
  }


  static List<Ticket> fromListMap(List<Map<String,dynamic>> snap) {
    List<Ticket> collection = List();
    snap.forEach((element) {
      collection.add(Ticket.fromMap(element));
    });
    return collection;
  }
}
