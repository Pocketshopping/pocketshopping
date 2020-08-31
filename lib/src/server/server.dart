

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

class ServerRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<Map<String,dynamic>> get() async {


    try{
      var doc = await databaseReference.collection("server").doc('wallet').get(GetOptions(source: Source.server))
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){ throw Exception;});
      return doc.data();
    }
    catch(_){
      return {'key':''};
    }
  }
}

