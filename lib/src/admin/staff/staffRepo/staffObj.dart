import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:pocketshopping/src/utility/utility.dart';

import 'staffPermission.dart';

@immutable
class Staff {
  final String staff;
  final String staffBehaviour;
  final Timestamp staffCreatedAt;
  final String staffJobTitle;
  final Permission staffPermissions;
  final int staffStatus;
  final String staffWorkPlace;
  final Timestamp startDate;
  final Timestamp endDate;
  final String staffID;
  final String staffName;
  final bool parentAllowed;

  Staff({
    this.staff,
    this.staffBehaviour,
    this.staffCreatedAt,
    this.staffJobTitle,
    this.staffPermissions,
    this.staffStatus,
    this.staffWorkPlace,
    this.startDate,
    this.endDate,
    this.staffID,
    this.staffName,
    this.parentAllowed,
  });

  Staff copyWith({
    String staff,
    String staffBehaviour,
    Timestamp staffCreatedAt,
    String staffJobTitle,
    Permission staffPermissions,
    int staffStatus,
    String staffWorkPlace,
    Timestamp startDate,
    Timestamp endDate,
    String staffID,
    String staffName,
    bool parentAllowed
  }) {
    return Staff(
      staff: staff ?? this.staff,
      staffBehaviour: staffBehaviour ?? this.staffBehaviour,
      staffCreatedAt: staffCreatedAt ?? this.staffCreatedAt,
      staffJobTitle: staffJobTitle ?? this.staffJobTitle,
      staffPermissions: staffPermissions ?? this.staffPermissions,
      staffStatus: staffStatus ?? this.staffStatus,
      staffWorkPlace: staffWorkPlace ?? this.staffWorkPlace,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      staffID: staffID ?? this.staffID,
      staffName: staffName ?? this.staffName,
      parentAllowed: parentAllowed??this.parentAllowed
    );
  }

  @override
  int get hashCode =>
      staff.hashCode ^
      staffBehaviour.hashCode ^
      staffCreatedAt.hashCode ^
      staffJobTitle.hashCode ^
      staffPermissions.hashCode ^
      staffStatus.hashCode ^
      staffWorkPlace.hashCode ^
      startDate.hashCode ^
      endDate.hashCode ^
      staffID.hashCode ^
      staffName.hashCode ^
      parentAllowed.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Staff &&
          runtimeType == other.runtimeType &&
          staff == other.staff &&
          staffBehaviour == other.staffBehaviour &&
          staffCreatedAt == other.staffCreatedAt &&
          staffJobTitle == other.staffJobTitle &&
          staffPermissions == other.staffPermissions &&
          staffStatus == other.staffStatus &&
          staffWorkPlace == other.staffWorkPlace &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          staffID == other.staffID &&
          staffName == other.staffName &&
          parentAllowed == other.parentAllowed;

  Staff update({
    String staff,
    String staffBehaviour,
    Timestamp staffCreatedAt,
    String staffJobTitle,
    Permission staffPermissions,
    int staffStatus,
    String staffWorkPlace,
    Timestamp startDate,
    Timestamp endDate,
    String staffID,
    String staffName,
    bool parentAllowed
  }) {
    return copyWith(
      staff: staff,
      staffBehaviour: staffBehaviour,
      staffCreatedAt: staffCreatedAt,
      staffJobTitle: staffJobTitle,
      staffPermissions: staffPermissions,
      staffStatus: staffStatus,
      staffWorkPlace: staffWorkPlace,
      startDate: startDate,
      endDate: endDate,
      staffID: staffID,
      staffName: staffName,
      parentAllowed: parentAllowed
    );
  }

  @override
  String toString() {
    return '''Instance of Staff''';
  }

  Map<String, dynamic> toMap() {
    return {
      'staff': staff,
      'staffBehaviour': staffBehaviour,
      'staffCreatedAt': Timestamp.now(),
      'staffJobTitle': staffJobTitle,
      'staffPermissions': staffPermissions.toMap(),
      'staffStatus': staffStatus,
      'staffWorkPlace': staffWorkPlace,
      'startDate': startDate,
      'endDate': endDate,
      'staffID': staffID,
      'staffName': staffName,
      'parentAllowed': parentAllowed,
      'index': Utility.makeIndexList(staffName)
    };
  }

  static Staff fromSnap(DocumentSnapshot snap) {
    return Staff(
      staff: snap.data['staff'],
      staffBehaviour: snap.data['staffBehaviour'],
      staffCreatedAt: snap.data['staffCreatedAt'],
      staffJobTitle: snap.data['staffJobTitle'],
      staffPermissions: Permission.fromMap(snap.data['staffPermissions'] as Map<String, dynamic>),
      staffStatus: snap.data['staffStatus'],
      staffWorkPlace: snap.data['staffWorkPlace'],
      startDate: snap.data['startDate'],
      endDate: snap.data['endDate'],
      staffName: snap.data['staffName'],
      parentAllowed: snap.data['parentAllowed'],
      staffID: snap.documentID,
    );
  }

  static List<Staff> fromListSnap(List<DocumentSnapshot> snap){
    return snap.map((e) => Staff.fromSnap(e)).toList();
  }
}
