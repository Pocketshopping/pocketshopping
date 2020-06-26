import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';

class PinRepo {
  static final databaseReference = Firestore.instance;

  static Future<bool> save(Pin pin,String wid) async {

    try {
      await databaseReference.collection("wallet").document(wid).setData(pin.toMap());
      return true;
    }
    catch(_){print(_);return false;}


  }

  static Future<bool> fetchPin(String pin,String wid) async {

    try {
      var docs = await databaseReference.collection("wallet").document(wid).get(source: Source.server);
      if(docs.exists){
        return Pin.fromSnap(docs).pin == Pin.hash(pin);
      }
      else
        return false;
    }
    catch(_){return false;}
  }

  static Future<bool> isSet(String wid) async {
    var docs = await databaseReference.collection("wallet").document(wid).get(source: Source.server);
    return docs.exists;
  }
}
