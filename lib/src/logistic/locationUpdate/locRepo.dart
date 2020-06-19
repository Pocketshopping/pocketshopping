import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

class LocRepo {
  static final databaseReference = Firestore.instance;

  static Future<void> update(Map<String,dynamic> data) async {
    var fav = await getLocUpdate(data['agentID']);
    Wallet wallet = await WalletRepo.getWallet(data['wallet']);
    Agent agent = await LogisticRepo.getOneAgent(data['agentID']);
    var remitted = await LogisticRepo.remittance(data['wallet'],limit:agent.limit);
    Merchant company = await MerchantRepo.getMerchant(data['agentParent']);
    if(fav)
    {

      if(agent.agentStatus == 1 && company.bActive && company.bStatus == 1 && Utility.isOperational(company.bOpen, company.bClose)){data['parent']=true;}
      else{data['parent']=false;}

      if(wallet.pocketUnitBalance >= 100) {
        data['pocket'] = true;
      }
      else {
        data['pocket'] = false;
        Utility.localNotifier('PocketShopping','PocketUnit','PocketUnit','${'You are currently on hold because your PocketUnit is below the expected quota($CURRENCY 100), you will be unavaliable to run delivery until you Topup'}');
      }

      if(!remitted){
        data['remitted']=false;
        Utility.localNotifier('PocketShopping','Collection','Collection','You are currently on hold because you have a pending clearance. Head to the office for clearance');
      }else{data['remitted']=true;}

      if(!Utility.isOperational(company.bOpen, company.bClose))
        {
         data.remove('agentLocation');
         data.remove('UpdatedAt');

        }


      data.remove('availability');
      data.remove('busy');
      data['limit'] = agent.limit??10000;
      data['autoAssigned']=agent.autoAssigned.isNotEmpty && agent.autoAssigned != 'Unassign';
      await LogisticRepo.updateAgentLoc(data['agentID'], data);

    }
    else
    {


      if(agent.agentStatus == 1 && company.bActive && company.bStatus == 1 && Utility.isOperational(company.bOpen, company.bClose)){
        data['parent']=true;}
      else{
        data['parent']=false;}

      if(wallet.pocketUnitBalance >= 100) {
        data['pocket'] = true;
      }
      else {
        data['pocket'] = false;
        Utility.localNotifier('PocketShopping','PocketUnit','PocketUnit','${'You are currently on hold because your PocketUnit is below the expected quota($CURRENCY 100), you will be unavaliable to run delivery until you Topup'}');
      }

      if(!remitted){
        data['remitted']=false;
        Utility.localNotifier('PocketShopping','Collection','Collection','You are currently on hold because you have a pending clearance. Head to the office for clearance');
      }

      if(!data['autoAssigned'])
      {
        data.remove('agentLocation');
      }

      data['startedAt']=Timestamp.now();
      data['autoAssigned']=agent.autoAssigned.isNotEmpty && agent.autoAssigned != 'Unassign';
      await LogisticRepo.updateAgentLoc(data['agentID'], data);


    }
  }

  static Future<bool> getLocUpdate(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").document(agentID).get();
    if(doc.exists) return true;
    else return false;
  }

  static Future<bool> updateAvailability(String agentID, bool change) async {
    try {
      await LogisticRepo.updateAgentLoc(agentID, {'availability': change});
      return change;
    }
    catch(_){return !change;}

  }

}
