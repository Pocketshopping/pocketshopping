import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:pocketshopping/model/DataModel/notificationDataModel.dart';

class StaffDataModel extends Data {
  final databaseReference = Firestore.instance;

  String sJobTitle;
  Map<String, dynamic> sPermissions;
  String mRef;
  String sRef;
  String sStatus;
  String sBehaviour;
  String sid;
  DateTime sEnd;
  DateTime sStart;

  StaffDataModel(
      {this.sJobTitle,
      this.sPermissions,
      this.mRef,
      this.sRef,
      this.sBehaviour,
      this.sStatus,
      this.sid,
      this.sEnd,
      this.sStart});

  @override
  Future<String> save() async {
    var doc = await MerchantDataModel().getAnyOneUsingID(mRef);
    var sid = await databaseReference.collection("staff").add({
      'staffWorkPlace': databaseReference.document('merchants/$mRef'),
      'staffJobTitle': sJobTitle,
      'staffPermissions': sPermissions,
      'staffStatus': sStatus,
      'staff': databaseReference.document('users/$sRef'),
      'staffBehaviour':
          databaseReference.document('staffBehaviour/$sBehaviour'),
      'staffCreatedAt': DateTime.now(),
      'startDate': null,
      'endDate': null,
    });

    var nid = await NotificationDataModel(
            nTitle: 'Work Request',
            nBody: 'You are requested to work at'
                ' ${doc.data['businessName']} do you want to accept it.',
            nAction: 'STAFFREQUEST',
            nCleared: false,
            nInitiator: databaseReference.document('staff/${sid.documentID}'),
            nReceiver: sRef)
        .save();

    return sid.documentID;
  }

  Future<Map<String, dynamic>> getNewStaff(String email) async {
    Map<String, dynamic> collection = {};
    var documents = await Firestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .getDocuments();
    if (documents.documents.length > 0) {
      collection.addAll(documents.documents[0].data);
      collection.putIfAbsent(
          'staffID', () => documents.documents[0].documentID);
    }
    return collection;
  }

  Future<Map<String, dynamic>> getBusiness(String userID) async {
    Map<String, dynamic> collection = {};
    var userRef = databaseReference.document('users/$userID');
    var documents = await Firestore.instance
        .collection('merchants')
        .where('businessCreator', isEqualTo: userRef)
        .getDocuments();
    if (documents.documents.length > 0) {
      collection.addAll(documents.documents[0].data);
    }
    return collection;
  }

  @override
  Future<void> upDate() async {
    await Firestore.instance
        .collection('staff')
        .document(sid)
        .updateData(makeData());
  }

  Map<String, dynamic> makeData() {
    Map<String, dynamic> data = {};

    if (sJobTitle != null && sJobTitle.isNotEmpty)
      data['staffJobTitle'] = sJobTitle;
    if (sPermissions != null && sPermissions.isNotEmpty)
      data['staffPermissions'] = sPermissions;
    if (sEnd != null) data['endDate'] = DateTime.now();
    if (sStart != null) data['startDate'] = DateTime.now();
    if (sStatus != null && sStatus.isNotEmpty) data['staffStatus'] = sStatus;

    //print(data.toString());
    return data;
  }
}
