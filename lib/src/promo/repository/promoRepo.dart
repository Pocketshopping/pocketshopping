import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/promo/repository/promoObj.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';

//cleared
class PromoRepo {
  static final databaseReference = Firestore.instance;


  static Future<List<Bonus>> getBonus(String recipient) async {
    try{
      QuerySnapshot promos;
      promos = await databaseReference.collection("promo")
          .where('recipient',isEqualTo: recipient)
          .where('status',isEqualTo: false)
          .getDocuments(source: Source.server)
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){Utility.noInternet(); throw Exception;});
      return Bonus.fromListMap(promos.documents);
    }
    catch(_){
      return [];
    }
  }

  static Future<bool> claimBonus(String id) async {
    try{
       await databaseReference.collection("promo").document(id)
           .updateData({'status':true})
          .timeout(Duration(seconds: TIMEOUT),onTimeout: (){throw Exception;});

      return true;
    }
    catch(_){
      return false;
    }
  }

}
