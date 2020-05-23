import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/review/repository/ReviewEntity.dart';
import 'package:pocketshopping/src/review/repository/reviewObj.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class LocRepo {
  static final databaseReference = Firestore.instance;

  static Future<void> update(Map<String,dynamic> data) async {
    var fav = await getLocUpdate(data['agentID']);
    Wallet wallet = await WalletRepo.getWallet(data['wallet']);
    Agent agent = await LogisticRepo.getOneAgent(data['agentID']);
    if(fav)
    {
      if(agent.agentStatus == 'ACTIVE')
        data['parent']=true;
      else
        data['pocket']=false;

      if(wallet.pocketUnitBalance > 100) {
        data['pocket'] = true;

      }
      else {
        data['pocket'] = false;
        Utility.localNotifier();
      }

      data.remove('availability');
      await databaseReference.collection("agentLocationUpdate")
          .document(data['agentID']).updateData(data);
    }
    else
    {
      if(agent.agentStatus == 'ACTIVE')
        data['parent']=true;
      else
        data['pocket']=false;

      if(wallet.pocketUnitBalance > 100)
        data['pocket']=true;
      else
        data['pocket']=false;
      await databaseReference.collection("agentLocationUpdate")
          .document(data['agentID'])
          .setData(data);
    }
  }

  static Future<bool> getLocUpdate(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").document(agentID).get();
    if(doc.exists) return true;
    else return false;
  }

}
