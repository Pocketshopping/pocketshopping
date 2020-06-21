import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/utility/utility.dart';

@immutable
class AutoMobile {
  final String autoPlateNumber;
  final String autoModelNumber;
  final String autoType;
  final String autoName;
  final String autoID;
  final String autoLogistic;
  final bool autoAssigned;
  final String assignedTo;
  final Timestamp autoAddedAt;

  AutoMobile(
      {this.autoPlateNumber,
      this.autoModelNumber,
      this.autoType,
      this.autoName,
      this.autoID,
      this.autoLogistic,
      this.autoAssigned,
      this.assignedTo,
      this.autoAddedAt
      });

  AutoMobile copyWith(
      {String autoPlateNumber,
      String autoModelNumber,
      String autoType,
      String autoName,
      String autoID,
      String autoLogistic,
      bool autoAssigned,
      String assignedTo,
      Timestamp autoAddedAt
      }) {
    return AutoMobile(
      autoPlateNumber: autoPlateNumber ?? this.autoPlateNumber,
      autoModelNumber: autoModelNumber ?? this.autoModelNumber,
      autoType: autoType ?? this.autoType,
      autoName: autoName ?? this.autoName,
      autoID: autoID ?? this.autoID,
      autoLogistic: autoLogistic ?? this.autoLogistic,
      autoAssigned: autoAssigned ?? this.autoAssigned,
      assignedTo: assignedTo?? this.assignedTo,
      autoAddedAt: autoAddedAt ??this.autoAddedAt
    );
  }

  @override
  int get hashCode =>
      autoType.hashCode ^
      autoName.hashCode ^
      autoModelNumber.hashCode ^
      autoPlateNumber.hashCode ^
      autoID.hashCode ^
      autoLogistic.hashCode ^
      autoAssigned.hashCode ^
      assignedTo.hashCode ^
      autoAddedAt.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AutoMobile &&
          runtimeType == other.runtimeType &&
          autoType == other.autoType &&
          autoName == other.autoName &&
          autoModelNumber == other.autoModelNumber &&
          autoPlateNumber == other.autoPlateNumber &&
          autoID == other.autoID &&
          autoLogistic == other.autoLogistic &&
          autoAssigned == other.autoAssigned &&
          assignedTo == other.assignedTo &&
          autoAddedAt == other.autoAddedAt;

  AutoMobile update(
      {String autoPlateNumber,
      String autoModelNumber,
      String autoType,
      String autoName,
      String autoID,
      String autoLogistic,
      bool autoAssigned,
      String assignedTo,
      Timestamp autoAddedAt
      }) {
    return copyWith(
        autoPlateNumber: autoPlateNumber,
        autoModelNumber: autoModelNumber,
        autoType: autoType,
        autoName: autoName,
        autoID: autoID,
        autoLogistic: autoLogistic,
        autoAssigned: autoAssigned,
        assignedTo: assignedTo,
      autoAddedAt: autoAddedAt

    );
  }

  @override
  String toString() {
    return '''Instance of AutoMobile''';
  }

  Map<String, dynamic> toMap() {
    return {
      'autoPlateNumber': autoPlateNumber,
      'autoModelNumber': autoModelNumber,
      'autoType': autoType,
      'autoName': autoName,
      'autoLogistic': autoLogistic,
      'autoAssigned': autoAssigned,
      'autoAddedAt': Timestamp.now(),
      'assignedTo':assignedTo,
      'index':makeAutomobileIndex()
    };
  }

  List<String> makeAutomobileIndex(){
    var temp = Utility.makeIndexList(autoPlateNumber);
    temp.addAll(Utility.makeIndexList(autoType));
    if(autoName.isNotEmpty)
      temp.addAll(Utility.makeIndexList(autoName));
    return temp;
  }

  static AutoMobile fromSnap(DocumentSnapshot snap) {
    return AutoMobile(
        autoPlateNumber: (snap.data['autoPlateNumber']),
        autoModelNumber: (snap.data['autoModelNumber']),
        autoType: (snap.data['autoType']),
        autoName: (snap.data['autoName']),
        autoLogistic: snap.data['autoLogistic'],
        autoID: snap.documentID,
        autoAssigned: snap.data['autoAssigned'],
        assignedTo: snap.data['assignedTo'],
        autoAddedAt: snap.data['autoAddedAt'],
    );

  }

  static Map<String, AutoMobile> fromListSnap(List<DocumentSnapshot> snap) {
    Map<String, AutoMobile> collection = Map();
    snap.forEach((element) {
      AutoMobile autoMobile = AutoMobile.fromSnap(element);
      collection[autoMobile.autoName.isNotEmpty
              ? autoMobile.autoName + '(${autoMobile.autoPlateNumber})'
              : autoMobile.autoType + ' ( ${autoMobile.autoPlateNumber} )'] =
          AutoMobile.fromSnap(element);
    });
    return collection;
  }
}
