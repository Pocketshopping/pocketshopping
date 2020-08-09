import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';

class PinRepo {
  static final databaseReference = Firestore.instance;

  static Future<bool> save(Pin pin,String wid) async {

    try {
      await databaseReference.collection("wallet").document(wid).setData(pin.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){//print(_);
      return false;}


  }

  static Future<bool> fetchPin(String pin,String wid) async {

    try {
      var docs = await databaseReference.collection("wallet").document(wid).get(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      if(docs.exists){
        //print('entered Pin: ${Pin.hash(pin)} fetched pin: ${Pin.fromSnap(docs).pin} wallet:$wid');
        return Pin.fromSnap(docs).pin == Pin.hash(pin);
      }
      else
        return false;
    }
    catch(_){return false;}
  }

  static Future<bool> isSet(String wid) async {
    var docs = await databaseReference.collection("wallet").document(wid).get(source: Source.server)
        .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
    return docs.exists;
  }
}
