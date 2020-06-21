import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/vehicle/repository/vehicleObj.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/statistic/agentStatistic/agentStatistic.dart';
import 'package:pocketshopping/src/statistic/repository.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';



class CustomerCareRepo {
  static final databaseReference = Firestore.instance;


  static Future<bool> saveCustomerCare(String mid,List<CustomerCareLine> customerCareLine) async {
    try{
      await databaseReference
          .collection("customerCare")
          .document(mid)
          .setData(CustomerCareLine.toBigMap(customerCareLine));
      return true;
    }
    catch(_){return false;}

  }

  static Future<bool> updateCustomerCare(String mid,List<CustomerCareLine> customerCareLine) async {
    try{
      await databaseReference
          .collection("customerCare")
          .document(mid)
          .setData(CustomerCareLine.toBigMap(customerCareLine));
      return true;
    }
    catch(_){return false;}

  }

  static Future<bool> deleteCustomerCare(String mid, String number) async {
    try{
      await databaseReference
          .collection("customerCare")
          .document(mid)
          .updateData({'$number': FieldValue.delete()});
      return true;
    }
    catch(_){return false;}

  }


  static Stream<List<CustomerCareLine>> fetchMyCustomerCareLine(String company) async* {
    yield* databaseReference
        .collection("customerCare")
        .document(company)
        .snapshots().map((event) {
      return CustomerCareLine.fromMap(event.data);
    });
  }

  static Future<List<CustomerCareLine>> fetchCustomerCareLine(String company) async {
    List<CustomerCareLine> temp=[];
   var data =  await databaseReference
        .collection("customerCare")
        .document(company).get(source: Source.serverAndCache);
   temp.addAll(CustomerCareLine.fromMap(data.data));

   if(temp.length<4)
     return temp;
   else{
    temp.shuffle();
    return temp.sublist(0,3);
   }

  }

}