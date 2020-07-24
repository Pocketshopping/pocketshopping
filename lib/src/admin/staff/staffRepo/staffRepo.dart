import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class StaffRepo {
  static final databaseReference = Firestore.instance;

  static Future<String> save(Staff staff,Request request) async {
    DocumentReference bid;
    bid = await databaseReference.collection("staffs").add(staff.toMap());
    await RequestRepo.save(request.copyWith(requestInitiatorID: bid.documentID));
    return bid.documentID;
  }

  static Future<List<Staff>> fetchAllMyStaffs(String company)async{
    try{
      QuerySnapshot document;

      document = await Firestore.instance
          .collection('staffs')
          .orderBy('startDate')
          .where('staffWorkPlace',isEqualTo: company)
          .getDocuments(source: Source.serverAndCache);


      return Staff.fromListSnap(document.documents);
    }
    catch(_){
      return [];
    }
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

  static Future<Staff> getOneStaff(String sid)async{
    DocumentSnapshot document;
    try{
      document = await Firestore.instance
          .collection('staffs')
          .document(sid)
          .get(source: Source.server).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return null;});

      if(document != null && document.exists)
        return Staff.fromSnap(document);
      else
        return null;
    }
    catch(_){return null;}

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

 static Future<bool> updateStaff(String sid,Map<String,dynamic>data)async{
    try{
      await Firestore.instance
          .collection('staffs').document(sid).updateData(data).timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});
      return true;
    }catch(_){return false;}
  }

  static Future<bool> delete(Staff staff,User user,Request request,{String merchant})async{
    try{
      if(staff.startDate != null){
        await Firestore.instance.collection('staffs').document(staff.staffID).delete().timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});
        await UserRepo().upDate(role: 'user', uid: user.uid, bid: 'null');
        var doc = await RequestRepo.save(request);
        await Utility.pushNotifier(
            fcm: user.notificationID,
            body: 'You are no longer a staff of $merchant. Contact $merchant for more information',
            title: '$merchant',
            notificationType: 'RemoveStaffResponse',
            data: {
              'requestId':doc,
            }
        );
      }
      else{
        bool deleted = await RequestRepo.deleteSpecific(staff.staff, staff.staffID);
        if(deleted)
        await Firestore.instance.collection('staffs').document(staff.staffID).delete().timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});

      }
      return true;
    }catch(_){
      return false;
    }
  }

  static Future<bool> staffAccept(String staffID, String requestID, String uid) async {
    try{
      Staff staff = await getOneStaff(staffID);
      User user = await UserRepo.getOneUsingUID(uid);
      if(staff != null && user != null ){
        await updateStaff(staffID, {'startDate': Timestamp.now()});
        await RequestRepo.clear(requestID);
        await UserRepo().upDate(role: 'staff', uid: uid, bid: staff.staffWorkPlace);
        await UserRepository().changeRole('staff');
        await Utility.updateWallet(uid: user.walletId,cid:staff.staffWorkPlaceWallet,type: 5 );
        return true;
      }
      else{
        return false;
      }

    }
    catch(_){return false;}
  }

  static Future<bool> staffDecline(String staffID, String requestID) async {
    try {
      await databaseReference.collection('staffs').document(staffID).delete();
      await RequestRepo.clear(requestID);
      return true;
    }
    catch (_) {
      return false;
    }
  }


  }

