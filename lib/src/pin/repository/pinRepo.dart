import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/profile/repository/otpObj.dart';
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

  static Future<bool> saveOtp(Otp otp) async {

    try {
      await databaseReference.collection("otp").document(otp.id).setData(otp.toMap())
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      return true;
    }
    catch(_){//print(_);
      return false;}
  }

  static Future<Otp> getOtp(String wid) async {

    try {
      DocumentSnapshot doc;
      doc = await databaseReference.collection("otp").document(wid).get(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      Otp otp = Otp.fromMap(doc);
      return otp.isNew?otp:null;
    }
    catch(_){//print(_);
      return null;}
  }

  static Stream<Otp> getOtpStream(String wid) {
    return databaseReference.collection("otp").document(wid).snapshots().map((event) => event.exists?Otp.fromMap(event):null);
  }

  static Future<bool> fetchPin(String pin,String wid) async {

    try {
      var docs = await databaseReference.collection("wallet").document(wid).get(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});
      if(docs.exists){
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
