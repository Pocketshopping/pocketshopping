import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/admin/staff/staffRepo/staffObj.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class StaffRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<bool> save(Staff staff,Request request) async {
    try{
      DocumentReference bid;
      bid = await databaseReference.collection("staffs").add(staff.toMap()).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      await RequestRepo.save(request.copyWith(requestInitiatorID: bid.id));
      return true;
    }
    catch(_){
      return false;
    }
  }

  static Future<List<Staff>> fetchAllMyStaffs(String company,{int source = 0})async{
    try{
      QuerySnapshot document;
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .get(GetOptions(source: Source.serverAndCache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
        return Staff.fromListSnap(document.docs);
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .get(GetOptions(source: Source.serverAndCache)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        return Staff.fromListSnap(document.docs);
      }
    }
    catch(_){
      return [];
    }
  }

  static Future<List<Staff>> fetchMyStaffs(String company,Staff last,{int source = 0})async{
    QuerySnapshot document;
    if (last == null) {
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .limit(10)
            .get(GetOptions(source: Source.cache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    } else {
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .startAfter([DateTime.parse(last.startDate.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.cache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .orderBy('startDate')
            .where('staffWorkPlace',isEqualTo: company)
            .startAfter([DateTime.parse(last.startDate.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    }

    return Staff.fromListSnap(document.docs);

  }

  static Future<Staff> getOneStaff(String sid)async{
    DocumentSnapshot document;
    try{
      document = await FirebaseFirestore.instance
          .collection('staffs')
          .doc(sid)
          .get(GetOptions(source: Source.server)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});

      if(document != null && document.exists)
        return Staff.fromSnap(document);
      else
        return null;
    }
    catch(_){return null;}

  }

  static Future<List<Staff>> searchMyStaffs(
      String mID, Staff last, String search,{int source=0}) async {
    QuerySnapshot document;

    if (last == null) {
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .where('staffWorkPlace', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .limit(10)
            .get(GetOptions(source: Source.cache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .where('staffWorkPlace', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache)).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      }
    } else {
      try{
        if(source == 1)
          throw Exception;
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .where('staffWorkPlace', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .startAfter([DateTime.parse(last.startDate.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.cache)).timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(document.docs.isEmpty)
          throw Exception;
      }
      catch(_){
        document = await FirebaseFirestore.instance
            .collection('staffs')
            .where('staffWorkPlace', isEqualTo: mID)
            .where('index', arrayContains: search.toLowerCase())
            .startAfter([DateTime.parse(last.startDate.toDate().toString())])
            .limit(10)
            .get(GetOptions(source: Source.serverAndCache));
      }
    }

    return Staff.fromListSnap(document.docs);
  }

 static Future<bool> updateStaff(String sid,Map<String,dynamic>data)async{
    try{
      await FirebaseFirestore.instance
          .collection('staffs').doc(sid).update(data).timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }catch(_){return false;}
  }

  static Future<bool> delete(Staff staff,User user,{String merchant})async{
    try{
      //,Request request
      if(staff.startDate != null){
        await FirebaseFirestore.instance.collection('staffs').doc(staff.staffID).delete().timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        await UserRepo().upDate(role: 'user', uid: user.uid, bid: 'null');
        await Utility.updateWallet(uid: user.walletId,cid:staff.staffWorkPlaceWallet,type: 2 );
        //var doc = await RequestRepo.save(request);
        await Utility.pushNotifier(
            fcm: user.notificationID,
            body: 'You are no longer a staff of $merchant. Contact $merchant for more information',
            title: '$merchant',
            notificationType: 'RemoveStaffResponse',
            data: {
              //'requestId':doc,
            }
        );
      }
      else{
        bool deleted = await RequestRepo.deleteSpecific(staff.staff, staff.staffID);
        if(deleted)
        await FirebaseFirestore.instance.collection('staffs').doc(staff.staffID).delete().timeout(Duration(seconds: TIMEOUT),onTimeout: (){return false;});

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
        await Utility.updateWallet(uid: user.walletId,cid:staff.staffWorkPlaceWallet,type: 6 );
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
      //await databaseReference.collection('staffs').doc(staffID).delete();
      await RequestRepo.clear(requestID);
      return true;
    }
    catch (_) {
      return false;
    }
  }


  }

