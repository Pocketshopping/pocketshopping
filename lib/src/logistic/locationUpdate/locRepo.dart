import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/currentPathLine.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/server/server.dart';
import 'package:pocketshopping/src/ui/constant/ui_constants.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

class LocRepo {
  static final databaseReference = FirebaseFirestore.instance;

  static Future<void> update(Map<String,dynamic> data) async {
    try{
      //print(data);
      Map<String,dynamic> server = await ServerRepo.get();
      var fav = await getLocUpdate(data['agentID']);
      Wallet wallet = await WalletRepo.getWallet(data['wallet'],key: server['key']);
      Agent agent = await LogisticRepo.getOneAgent(data['agentID']);
      var remitted = await LogisticRepo.remittance(data['wallet'],limit:agent.limit,key: server['key']);
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
        await Utility.localNotifier('PocketShopping','PocketUnit','PocketUnit','${'You are currently on hold because your PocketUnit is below the expected quota($CURRENCY 100), you will be unavaliable to run delivery until you Topup'}');
      }

      if(!remitted){
        data['remitted']=false;
        await Utility.localNotifier('PocketShopping','Collection','Collection','You are currently on hold because you have a pending clearance. Head to the office for clearance');
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
        await Utility.localNotifier('PocketShopping','PocketUnit','PocketUnit','${'You are currently on hold because your PocketUnit is below the expected quota($CURRENCY 100), you will be unavaliable to run delivery until you Topup'}');
      }

      if(!remitted){
        data['remitted']=false;
        await Utility.localNotifier('PocketShopping','Collection','Collection','You are currently on hold because you have a pending clearance. Head to the office for clearance');
      }

      data['startedAt']=Timestamp.now();
      data['autoAssigned']=agent.autoAssigned!=null?(agent.autoAssigned.isNotEmpty && agent.autoAssigned != 'Unassign'):false;


      await databaseReference.collection("agentLocationUpdate").doc(data['agentID']).set(data);
    }

    try{
      CurrentPathLine cpl = await OrderRepo.getCurrentPathLine(agent.agent);
      if(cpl != null){
        CurrentPathLine temp = await cpl.proximityCheck(Position(
          latitude: data['agentLocation']['geopoint'].latitude,
          longitude: data['agentLocation']['geopoint'].longitude
        ));
        await OrderRepo.setCurrentPathLine(temp);
      }
      int count = await OrderRepo.getUnclaimedDelivery(agent.agentID);
      if(count>0)
        await Utility.localNotifier("PocketShopping", "PocketShopping", "Delivery Request", 'There is a Delivery request in request bucket. check it out');
    }
    catch(_){}

    }
    catch(_){}
  }

  static Future<bool> getLocUpdate(String agentID) async {
    var doc = await databaseReference.collection("agentLocationUpdate").doc(agentID).get(GetOptions(source: Source.serverAndCache));
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

  static Future<bool> updateAgentCoord(String agentID, dynamic geoFlutterFire ) async {
    try {
      await LogisticRepo.updateAgentLoc(agentID, {'UpdatedAt': Timestamp.now(),'agentLocation':geoFlutterFire});
      return true;
    }
    catch(_){return false;}

  }

}
