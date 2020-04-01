
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/model/DataModel/Data.dart';

class StaffDataModel extends Data {
  final databaseReference = Firestore.instance;

  String sJobTitle;
  List<String> sPermessions;
  String mRef;
  String sRef;
  String sStatus;
  String sBehaviour;


@override
Future<String> save()async {
  var sid = await databaseReference.collection("staffsss")
      .add({
    'staffWorkPlace': databaseReference.document('merchants/$mRef'),
    'staffJobTitle': sJobTitle,
    'staffStatus': sStatus,
    'staff': databaseReference.document('users/$sRef'),
    'staffBehaviour': databaseReference.document('staffBehaviour/$sBehaviour'),
    'staffCreatedAt': DateTime.now(),

  });

  return sid.documentID;
}

  Future<Map<String,dynamic>> getNewStaff(String email)async {
    Map<String,dynamic> collection={};
    var documents = await Firestore.instance.collection('users').where('email',isEqualTo:email ).getDocuments();
    if(documents.documents.length>0){
      collection.addAll(documents.documents[0].data);
    }
    return collection;
  }

  Future<Map<String,dynamic>> getBusiness(String userID)async{

    Map<String,dynamic> collection={};
    var userRef = databaseReference.document('users/$userID');
    var documents = await Firestore.instance.collection('merchants').where('businessCreator',isEqualTo:userRef ).getDocuments();
    if(documents.documents.length>0){
      collection.addAll(documents.documents[0].data);
    }
    return collection;

  }

}