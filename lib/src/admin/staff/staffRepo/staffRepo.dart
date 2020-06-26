import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/category/repository/merchatCategoryObj.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';

class StaffRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Staff staff,Request request) async {
    DocumentReference bid;
    bid = await databaseReference.collection("staffs").add(staff.toMap());
    await RequestRepo.save(request);
    return bid.documentID;
  }

  static Future<List<Staff>> fetchMyStaffs(String company,Staff last)async{
    QuerySnapshot document;
    if (last == null) {
      document = await Firestore.instance
          .collection('staffs')
          .orderBy('startDate')
          .where('staffWorkPlace',isEqualTo: company)
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('staffs')
          .orderBy('startDate')
          .where('staffWorkPlace',isEqualTo: company)
          .startAfter([DateTime.parse(last.startDate.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return Staff.fromListSnap(document.documents);

  }

  static Future<List<Staff>> searchMyStaffs(
      String mID, Staff last, String search) async {
    QuerySnapshot document;

    if (last == null) {
      document = await Firestore.instance
          .collection('staffs')
          .where('staffWorkPlace', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    } else {
      document = await Firestore.instance
          .collection('staffs')
          .where('staffWorkPlace', isEqualTo: mID)
          .where('index', arrayContains: search.toLowerCase())
          .startAfter([DateTime.parse(last.startDate.toDate().toString())])
          .limit(10)
          .getDocuments(source: Source.serverAndCache);
    }

    return Staff.fromListSnap(document.documents);
  }
}

