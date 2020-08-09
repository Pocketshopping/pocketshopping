import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/customerCare/repository/customerCareObj.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';



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
      return event.exists?CustomerCareLine.fromMap(event.data):[];
    });
  }

  static Future<List<CustomerCareLine>> fetchCustomerCareLine(String company,{int source=0}) async {

    if(company == null)
      return null;
    if(company.isEmpty)
      return null;


    try{
      try{
        if(source == 1) throw Exception;
        List<CustomerCareLine> temp=[];
        var data =  await databaseReference
            .collection("customerCare")
            .document(company).get(source: Source.cache)
            .timeout(Duration(seconds: CACHE_TIME_OUT),onTimeout: (){throw Exception;});
        if(!data.exists){throw Exception;}
        temp.addAll(CustomerCareLine.fromMap(data.data));

        if(temp.length<4)
          return temp;
        else{
          temp.shuffle();
          return temp.sublist(0,3);
        }
      }
      catch(_){
        List<CustomerCareLine> temp=[];
        var data =  await databaseReference
            .collection("customerCare")
            .document(company).get(source: Source.serverAndCache)
            .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
        temp.addAll(CustomerCareLine.fromMap(data.data));

        if(temp.length<4)
          return temp;
        else{
          temp.shuffle();
          return temp.sublist(0,3);
        }
      }
    }
    catch(_){
      return [];
    }

  }

}