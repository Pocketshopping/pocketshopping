import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/logistic/agent/repository/agentObj.dart';
import 'package:pocketshopping/src/logistic/locationUpdate/agentLocUp.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/order/tracker/delivery/rDeliveryTracker.dart';
import 'package:pocketshopping/src/order/tracker/errand/rErrandTracker.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'repository/order.dart';

class LogisticBucket extends StatefulWidget {
  LogisticBucket({this.user});
  final Session user;

  @override
  State<StatefulWidget> createState() => _LogisticBucketState();
}

class _LogisticBucketState extends State<LogisticBucket> {

  final search = ValueNotifier<String>("");
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
            Get.height *
                0.1),
        child: AppBar(
          title: Text('Request Bucket',style: TextStyle(color: PRIMARYCOLOR),),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          elevation: 0.0,
        ),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<List<Order>>(
        stream: OrderRepo.getLogisticRequestBucket(widget.user.merchant.mID),
        builder: (context,AsyncSnapshot<List<Order>>snapshots){
          if(snapshots.connectionState == ConnectionState.waiting){
            return Center(
                child: JumpingDotsProgressIndicator(
                  fontSize: Get.height * 0.12,
                  color: PRIMARYCOLOR,
                ));
          }
          else if(snapshots.hasError){
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text('Error communicating with server. Check your connection and try again',textAlign: TextAlign.center,),
              )
            );
          }
          else{
            if(snapshots.data.isNotEmpty){
              return ListView.separated(
                  itemBuilder: (context,index){
                    return FutureBuilder<Merchant>(
                      future: MerchantRepo.getMerchant(snapshots.data[index].orderMerchant),
                      builder: (context,AsyncSnapshot<Merchant>data){
                        if(data.connectionState == ConnectionState.waiting){
                          return Container(
                            height: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            child: ListSkeleton(
                              style: SkeletonStyle(
                                theme: SkeletonTheme.Light,
                                isShowAvatar: false,
                                barCount: 3,
                                colors: [
                                  Colors.grey.withOpacity(0.5),
                                  Colors.grey,
                                  Colors.grey.withOpacity(0.5)
                                ],
                                isAnimation: true,
                              ),
                            ),
                            alignment: Alignment.center,
                          );
                        }
                        else if(data.hasError){
                          return ListTile(
                            title: Text('Error communication to server.',style: TextStyle(fontSize: 20,color: Colors.black54),),
                          );
                        }
                        else{
                          return Column(
                            children: [
                              if(snapshots.data[index].orderMode.mode != 'Errand')
                                psHeadlessCard(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        //offset: Offset(1.0, 0), //(x,y)
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                    child:ListTile(
                                      title: Center(child: Text('Delivery from ${data.data.bName}',style: TextStyle(fontSize: 20,color: Colors.black54),),),
                                      subtitle: Column(
                                        children: [
                                          Column(
                                            children: [
                                              Center(child: Text('${data.data.bAddress}',style: TextStyle(color: Colors.black54),),),
                                              const SizedBox(height: 20,),
                                              Row(
                                                children: [
                                                  Expanded(child: Center(child: Text('Item'),),),
                                                  Expanded(child: Center(child: Text('Oty'),),),
                                                  Expanded(child: Center(child: Text('Price($CURRENCY)'),),),
                                                ],
                                              ),
                                              const SizedBox(height: 10,),
                                              Column(
                                                children: List.generate(snapshots.data[index].orderItem.length, (i) {
                                                  return Row(
                                                    children: [
                                                      Expanded(child: Center(child: Text('${snapshots.data[index].orderItem[i].ProductName}'),),),
                                                      Expanded(child: Center(child: Text('${snapshots.data[index].orderItem[i].count}'),),),
                                                      Expanded(child: Center(child: Text('$CURRENCY${snapshots.data[index].orderItem[i].totalAmount}'),),),
                                                    ],
                                                  );
                                                }).toList(),
                                              ),
                                              const SizedBox(height: 20,),
                                              Column(

                                                children: [
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Price: $CURRENCY${snapshots.data[index].orderAmount}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Delivery Fee: $CURRENCY${snapshots.data[index].orderMode.fee}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Total: $CURRENCY${(snapshots.data[index].orderMode.fee + snapshots.data[index].orderAmount)}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Payment Method: ${snapshots.data[index].receipt.type}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Automobile Type: ${snapshots.data[index].auto}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 20,),
                                                  (snapshots.data[index].receipt.type == 'CASH')?
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Payment On Delivery',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                                                  ):Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Customer already paid once delivery is done fund will be transferred to your company pocket',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                                                  ),

                                                  const SizedBox(height: 20,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Customer Address: ${snapshots.data[index].orderMode.address}'),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20,),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  child: FlatButton(
                                                    onPressed: ()async{
                                                     // snapshots.data[index].potentials.remove(widget.user.agent.agentID);
                                                      //print(snapshots.data[index].orderETA);
                                                      Utility.bottomProgressLoader(body: 'Declining please wait',title: 'Declining');
                                                      await OrderRepo.removeOnePotential(snapshots.data[index].docID,
                                                          snapshots.data[index].receipt.collectionID,
                                                          snapshots.data[index].customerDevice,
                                                          snapshots.data[index].potentials);
                                                      Get.back();
                                                      Utility.bottomProgressSuccess(body: 'Order Declined',title: 'Declined');

                                                    },
                                                    child: Text('Decline'),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: PRIMARYCOLOR,
                                                  child: FlatButton(
                                                    onPressed: ()async{
                                                      /*bool result;
                                                      var temp = snapshots.data[index].index;
                                                      temp.addAll(Utility.makeIndexList(widget.user.agent.name));
                                                      Utility.bottomProgressLoader(body: 'Accepting please wait',title: 'Accepting');
                                                      result = await OrderRepo.convertPotential(
                                                          orderId: snapshots.data[index].docID,
                                                          agentWallet: widget.user.user.walletId,
                                                          agentId: widget.user.user.uid,
                                                          agentName: widget.user.user.fname,
                                                          logisticId: widget.user.agent.agentWorkPlace,
                                                          collectionId: snapshots.data[index].receipt.collectionID,
                                                          index: temp,
                                                          logisticWallet: widget.user.agent.workPlaceWallet
                                                      );
                                                      Get.back();
                                                      if(result){
                                                        //if(snapshots.data[index].orderMode.mode != 'Errand')
                                                        Get.off(RiderDeliveryTracker(order: snapshots.data[index].docID,user: widget.user.user,isActive: true,));
                                                        //Get.off(RiderTracker(order: snapshots.data[index].docID,user: widget.user.user,));
                                                        Utility.bottomProgressSuccess(body: 'Order Accepted',title: 'Delivery');
                                                        Utility.pushNotifier(title: 'Delivery',
                                                            body: 'Your Order has been accepted and the rider(${widget.user.user.fname}) will deliver your package shortly'
                                                            ,fcm: snapshots.data[index].customerDevice);
                                                        WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                                      }
                                                      else{
                                                        Utility.bottomProgressFailure(title: '',body: 'Error processing request');
                                                      }
                                                        */
                                                      search.value="";
                                                      Get.dialog( GestureDetector(
                                                          onTap: (){
                                                            Get.back();
                                                          },
                                                          child: Scaffold(
                                                              backgroundColor: Colors.black.withOpacity(0.3),
                                                              body:Center(
                                                              child: SizedBox(
                                                                height: Get.height*0.8,
                                                                width: Get.width*0.85,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  mainAxisSize: MainAxisSize.max,
                                                                  children: [
                                                                    Expanded(flex:0,child: Align(
                                                                      alignment: Alignment.centerRight,
                                                                      child: IconButton(
                                                                        onPressed: (){Get.back();},
                                                                        icon: Icon(Icons.close, color: Colors.white,),
                                                                      ),
                                                                    )),
                                                                    Expanded(
                                                                        child: Container(
                                                                          color: Colors.white,
                                                                          child: Column(
                                                                            children: [
                                                                              Expanded(flex:0,child:
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                                                  child: Text('Assign Task To:', style: TextStyle(fontSize: 18),)
                                                                                ),
                                                                              )
                                                                              ),
                                                                              Expanded(flex:0,child:
                                                                              Padding(
                                                                                padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                                                                child: TextFormField(
                                                                                  controller: null,
                                                                                  decoration: InputDecoration(
                                                                                    prefixIcon: Icon(Icons.search),
                                                                                    labelText: 'Search For Rider',
                                                                                    filled: true,
                                                                                    fillColor: Colors.grey.withOpacity(0.2),
                                                                                    focusedBorder: OutlineInputBorder(
                                                                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                                                    ),
                                                                                    enabledBorder: UnderlineInputBorder(
                                                                                      borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                                                    ),
                                                                                  ),
                                                                                  autofocus: false,
                                                                                  enableSuggestions: true,
                                                                                  textInputAction: TextInputAction.done,
                                                                                  onChanged: (value){
                                                                                    search.value = value;
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              ),
                                                                            Expanded(flex:0,child:SizedBox(height: 20,)),
                                                                              Expanded(child:
                                                                              ValueListenableBuilder(
                                                                                valueListenable: search,
                                                                                builder: (_,String keyword,__){

                                                                                  return FutureBuilder(
                                                                                    future: LogisticRepo.agentUpForTask(widget.user.merchant.mID,null,count: 100,source: 1,keyword: keyword),
                                                                                    builder: (context,AsyncSnapshot<List<AgentLocUp>>snapshot){
                                                                                      if(snapshot.connectionState == ConnectionState.waiting){
                                                                                        return Center(
                                                                                            child: JumpingDotsProgressIndicator(
                                                                                              fontSize: Get.height * 0.12,
                                                                                              color: PRIMARYCOLOR,
                                                                                            ));
                                                                                      }
                                                                                      else if(snapshot.hasError){
                                                                                        return Center(
                                                                                          child: Padding(
                                                                                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                            child: Text('No rider to display'),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      else{
                                                                                        if(snapshot.hasData){
                                                                                          if(snapshot.data.isNotEmpty){
                                                                                            return  ListView.separated(
                                                                                                itemBuilder: (context,i){
                                                                                                  return Padding(padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                                      child: ListTile(
                                                                                                        onTap: ()async{
                                                                                                          Get.back();
                                                                                                          Utility.dialogLoader();
                                                                                                          Wallet logistic = await WalletRepo.getWallet(widget.user.merchant.bWallet);
                                                                                                          Agent agentUser = await LogisticRepo.getOneAgent(snapshot.data[i].agent);
                                                                                                          Get.back();
                                                                                                          if(logistic != null){
                                                                                                            if(logistic.pocketUnitBalance >= 100){
                                                                                                              bool result;
                                                                                                              var temp = snapshots.data[index].index;
                                                                                                              temp.addAll(Utility.makeIndexList(snapshot.data[i].agentName));
                                                                                                              Utility.bottomProgressLoader(body: 'Assigning to ${snapshot.data[i].agentName} please wait',title: 'Assigning');
                                                                                                              result = await OrderRepo.convertPotential(
                                                                                                                  orderId: snapshots.data[index].docID,
                                                                                                                  agentWallet: agentUser.agentWallet,//widget.user.merchant.bWallet,//snapshot.data[i].wallet,
                                                                                                                  agentId: agentUser.agent,
                                                                                                                  agentName: snapshot.data[i].agentName,
                                                                                                                  logisticId: widget.user.merchant.mID,
                                                                                                                  collectionId: snapshots.data[index].receipt.collectionID,
                                                                                                                  index: temp,
                                                                                                                  logisticWallet: widget.user.merchant.bWallet,
                                                                                                                  isAssignedbyLogistics: true
                                                                                                              );
                                                                                                              Get.back();
                                                                                                              if(result){
                                                                                                                //if(snapshots.data[index].orderMode.mode != 'Errand')
                                                                                                                //Get.off(RiderDeliveryTracker(order: snapshots.data[index].docID,user: widget.user.user,isActive: true,));
                                                                                                                //Get.off(RiderTracker(order: snapshots.data[index].docID,user: widget.user.user,));
                                                                                                                Get.back();
                                                                                                                Utility.bottomProgressSuccess(body: 'Order Assigned to ${snapshot.data[i].agentName}',title: 'Delivery');
                                                                                                                Utility.pushNotifier(title: 'Delivery',
                                                                                                                    body: 'Your Order has been accepted and the rider(${snapshot.data[i].agentName}) will deliver your package shortly'
                                                                                                                    ,fcm: snapshots.data[index].customerDevice);
                                                                                                                Utility.pushNotifier(title: 'Delivery Task',
                                                                                                                    body: 'You have been assigned a task. Click on *Current delivery* for details.(${widget.user.merchant.bName} office)'
                                                                                                                    ,fcm: snapshot.data[i].device);
                                                                                                                WalletRepo.getWallet(widget.user.merchant.bWallet).then((value) => WalletBloc.instance.newWallet(value));
                                                                                                              }
                                                                                                              else{
                                                                                                                Utility.bottomProgressFailure(title: 'Assigning Delivery',body: 'Error processing request');
                                                                                                              }
                                                                                                            }

                                                                                                            else{
                                                                                                              Utility.infoDialogMaker("Insufficient pocket unit.\nLoad pocket unit to accept request");
                                                                                                            }
                                                                                                          }
                                                                                                          else{
                                                                                                            Utility.infoDialogMaker("Error encountered while accepting request.\ncheck internet connection and try again");
                                                                                                          }

                                                                                                        },
                                                                                                        leading: CircleAvatar(
                                                                                                          radius: 20,
                                                                                                          child: Center(
                                                                                                            child: Text('${snapshot.data[i].agentName[0].toUpperCase()}'),
                                                                                                          ),
                                                                                                        ),
                                                                                                        title: Text(snapshot.data[i].agentName),
                                                                                                        subtitle: Column(
                                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                                          children: [
                                                                                                            Row(
                                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                              children: [
                                                                                                                snapshot.data[i].availability?
                                                                                                                Text('Available',style: TextStyle(color: Colors.green),)
                                                                                                                    :Text('Unavailable',style: TextStyle(color: Colors.red),)    ,
                                                                                                                snapshot.data[i].busy?
                                                                                                                Text('Busy',style: TextStyle(color: Colors.redAccent),)
                                                                                                                    :SizedBox.shrink()
                                                                                                              ],
                                                                                                            ),
                                                                                                            if(snapshot.data[i].agentLocation != null)
                                                                                                              Row(
                                                                                                                children: [
                                                                                                                  Expanded(child:
                                                                                                                  FutureBuilder(
                                                                                                                      future: Utility.computeDistance(snapshot.data[i].agentLocation,data.data.bGeoPoint['geopoint']),
                                                                                                                      initialData: 0.1,
                                                                                                                      builder: (context,AsyncSnapshot<double> distance){
                                                                                                                        print(snapshot.data[i].agentLocation.latitude);
                                                                                                                        if(distance.hasData){
                                                                                                                          return Text('${Utility.formatDistance(distance.data, data.data.bName)}');
                                                                                                                        }
                                                                                                                        else{
                                                                                                                          return const SizedBox.shrink();
                                                                                                                        }
                                                                                                                      })
                                                                                                                  )
                                                                                                                ],
                                                                                                              )
                                                                                                          ],
                                                                                                        ),
                                                                                                      )
                                                                                                  );
                                                                                                },
                                                                                                separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                                                                                                itemCount: snapshot.data.length);
                                                                                          }
                                                                                          else{
                                                                                            return Center(
                                                                                              child: Padding(
                                                                                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                                child: Text('No rider to display'),
                                                                                              ),
                                                                                            );
                                                                                          }
                                                                                        }
                                                                                        else{
                                                                                          return Center(
                                                                                            child: Padding(
                                                                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                              child: Text('No rider to display'),
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      }
                                                                                    },
                                                                                  );
                                                                                },
                                                                              )
                                                                              )
                                                                            ],
                                                                          )
                                                                        )
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                          )
                                                        )
                                                      ));
                                                    },
                                                    child: Text('Accept',style: TextStyle(color: Colors.white),),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )

                                        ],
                                      ),
                                    )
                                ),
                              if(snapshots.data[index].orderMode.mode == 'Errand')
                                psHeadlessCard(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey,
                                        //offset: Offset(1.0, 0), //(x,y)
                                        blurRadius: 4.0,
                                      ),
                                    ],
                                    child:ListTile(
                                      title: Center(child: Text('Errand Request',style: TextStyle(fontSize: 20,color: Colors.black54),),),
                                      subtitle: Column(
                                        children: [
                                          Column(
                                            children: [
                                              const SizedBox(height: 20,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text('Source: ',style: TextStyle(fontSize: 18),),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Icon(Icons.place,color: Colors.grey.withOpacity(0.5),),
                                                  ),
                                                  Expanded(
                                                    child: Text('${snapshots.data[index].errand.sourceAddress}',style: TextStyle(fontSize: 18),),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 0,
                                                    child: Text('Destination: ',style: TextStyle(fontSize: 18),),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Icon(Icons.place,color: Colors.grey.withOpacity(0.5),),
                                                  ),
                                                  Expanded(
                                                    child: Text('${snapshots.data[index].errand.destinationAddress}',style: TextStyle(fontSize: 18),),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 10,),
                                              Row(
                                                children: [
                                                  Text('Description: ${snapshots.data[index].errand.comment}')
                                                ],
                                              ),
                                              const SizedBox(height: 20,),
                                              Column(

                                                children: [
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Fee: $CURRENCY${snapshots.data[index].orderMode.fee}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Payment Method: ${snapshots.data[index].receipt.type}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 5,),
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Automobile Type: ${snapshots.data[index].auto}',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ),
                                                  const SizedBox(height: 10,),
                                                  (snapshots.data[index].receipt.type == 'CASH')?
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Payment On Delivery',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                                                  ):Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Customer already paid once delivery is done fund will be transferred to your company pocket',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                                                  ),
                                                  const SizedBox(height: 20,),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20,),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: Colors.grey.withOpacity(0.5),
                                                  child: FlatButton(
                                                    onPressed: ()async{
                                                      //snapshots.data[index].potentials.remove(widget.user.agent.agentID);
                                                      //print(snapshots.data[index].orderETA);
                                                      Utility.bottomProgressLoader(body: 'Declining please wait',title: 'Declining');
                                                      await OrderRepo.removeOnePotential(snapshots.data[index].docID,
                                                          snapshots.data[index].receipt.collectionID,
                                                          snapshots.data[index].customerDevice,
                                                          snapshots.data[index].potentials);
                                                      Get.back();
                                                      Utility.bottomProgressSuccess(body: 'Order Declined',title: 'Declined');

                                                    },
                                                    child: Text('Decline'),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  color: PRIMARYCOLOR,
                                                  child: FlatButton(
                                                    onPressed: ()async{
                                                      /*bool result;
                                                      var temp = snapshots.data[index].index;
                                                      temp.addAll(Utility.makeIndexList(widget.user.agent.name));
                                                      Utility.bottomProgressLoader(body: 'Accepting please wait',title: 'Accepting');
                                                      result = await OrderRepo.convertPotential(
                                                          orderId: snapshots.data[index].docID,
                                                          agentWallet: widget.user.user.walletId,
                                                          agentId: widget.user.user.uid,
                                                          agentName: widget.user.user.fname,
                                                          logisticId: widget.user.agent.agentWorkPlace,
                                                          collectionId: snapshots.data[index].receipt.collectionID,
                                                          index: temp,
                                                          logisticWallet: widget.user.agent.workPlaceWallet
                                                      );
                                                      Get.back();
                                                      if(result){
                                                        Get.off(RiderErrandTracker(order: snapshots.data[index].docID,user: widget.user.user,isActive: true,));
                                                        Utility.bottomProgressSuccess(body: 'Order Accepted',title: 'Delivery');
                                                        if(snapshots.data[index].orderMode.mode != 'Errand')
                                                        {
                                                          Utility.pushNotifier(title: 'Delivery',
                                                              body: 'Your Order has been accepted and the rider(${widget.user.user.fname}) will deliver your package shortly'
                                                              ,fcm: snapshots.data[index].customerDevice);
                                                        }
                                                        else{
                                                          Utility.pushNotifier(title: 'Request',
                                                              body: 'Your Errand request has been accepted and the rider(${widget.user.user.fname}) will be with you shortly'
                                                              ,fcm: snapshots.data[index].customerDevice);
                                                        }

                                                        WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                                      }
                                                      else{
                                                        Utility.bottomProgressFailure(title: '',body: 'Error processing request');
                                                      }*/

                                                      search.value="";
                                                      Get.dialog( GestureDetector(
                                                          onTap: (){
                                                            Get.back();
                                                          },
                                                          child: Scaffold(
                                                              backgroundColor: Colors.black.withOpacity(0.3),
                                                              body:Center(
                                                                  child: SizedBox(
                                                                    height: Get.height*0.8,
                                                                    width: Get.width*0.85,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      mainAxisSize: MainAxisSize.max,
                                                                      children: [
                                                                        Expanded(flex:0,child: Align(
                                                                          alignment: Alignment.centerRight,
                                                                          child: IconButton(
                                                                            onPressed: (){Get.back();},
                                                                            icon: Icon(Icons.close, color: Colors.white,),
                                                                          ),
                                                                        )),
                                                                        Expanded(
                                                                            child: Container(
                                                                                color: Colors.white,
                                                                                child: Column(
                                                                                  children: [
                                                                                    Expanded(flex:0,child:
                                                                                    Align(
                                                                                      alignment: Alignment.centerLeft,
                                                                                      child: Padding(
                                                                                          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                                                          child: Text('Assign Task To:', style: TextStyle(fontSize: 18),)
                                                                                      ),
                                                                                    )
                                                                                    ),
                                                                                    Expanded(flex:0,child:
                                                                                    Padding(
                                                                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 15),
                                                                                      child: TextFormField(
                                                                                        controller: null,
                                                                                        decoration: InputDecoration(
                                                                                          prefixIcon: Icon(Icons.search),
                                                                                          labelText: 'Search For Rider',
                                                                                          filled: true,
                                                                                          fillColor: Colors.grey.withOpacity(0.2),
                                                                                          focusedBorder: OutlineInputBorder(
                                                                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                                                          ),
                                                                                          enabledBorder: UnderlineInputBorder(
                                                                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                                                          ),
                                                                                        ),
                                                                                        autofocus: false,
                                                                                        enableSuggestions: true,
                                                                                        textInputAction: TextInputAction.done,
                                                                                        onChanged: (value){
                                                                                          search.value = value;
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                    ),
                                                                                    Expanded(flex:0,child:SizedBox(height: 20,)),
                                                                                    Expanded(child:
                                                                                    ValueListenableBuilder(
                                                                                      valueListenable: search,
                                                                                      builder: (_,String keyword,__){

                                                                                        return FutureBuilder(
                                                                                          future: LogisticRepo.agentUpForTask(widget.user.merchant.mID,null,count: 100,source: 1,keyword: keyword),
                                                                                          builder: (context,AsyncSnapshot<List<AgentLocUp>>snapshot){
                                                                                            if(snapshot.connectionState == ConnectionState.waiting){
                                                                                              return Center(
                                                                                                  child: JumpingDotsProgressIndicator(
                                                                                                    fontSize: Get.height * 0.12,
                                                                                                    color: PRIMARYCOLOR,
                                                                                                  ));
                                                                                            }
                                                                                            else if(snapshot.hasError){
                                                                                              return Center(
                                                                                                child: Padding(
                                                                                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                                  child: Text('No rider to display'),
                                                                                                ),
                                                                                              );
                                                                                            }
                                                                                            else{
                                                                                              if(snapshot.hasData){
                                                                                                if(snapshot.data.isNotEmpty){
                                                                                                  return  ListView.separated(
                                                                                                      itemBuilder: (context,i){
                                                                                                        return Padding(padding: EdgeInsets.symmetric(horizontal: 5),
                                                                                                            child: ListTile(
                                                                                                              onTap: ()async{
                                                                                                                Get.back();
                                                                                                                Utility.dialogLoader();
                                                                                                                Wallet logistic = await WalletRepo.getWallet(widget.user.merchant.bWallet);
                                                                                                                Agent agentUser = await LogisticRepo.getOneAgent(snapshot.data[i].agent);
                                                                                                                Get.back();
                                                                                                                if(logistic != null){
                                                                                                                  if(logistic.pocketUnitBalance >= 100){
                                                                                                                    bool result;
                                                                                                                    var temp = snapshots.data[index].index;
                                                                                                                    temp.addAll(Utility.makeIndexList(snapshot.data[i].agentName));
                                                                                                                    Utility.bottomProgressLoader(body: 'Assigning to ${snapshot.data[i].agentName} please wait',title: 'Assigning');
                                                                                                                    result = await OrderRepo.convertPotential(
                                                                                                                        orderId: snapshots.data[index].docID,
                                                                                                                        agentWallet: agentUser.agentWallet,//widget.user.merchant.bWallet,//snapshot.data[i].wallet,
                                                                                                                        agentId: agentUser.agent,
                                                                                                                        agentName: snapshot.data[i].agentName,
                                                                                                                        logisticId: widget.user.merchant.mID,
                                                                                                                        collectionId: snapshots.data[index].receipt.collectionID,
                                                                                                                        index: temp,
                                                                                                                        logisticWallet: widget.user.merchant.bWallet,
                                                                                                                      isAssignedbyLogistics: true
                                                                                                                    );
                                                                                                                    Get.back();
                                                                                                                    if(result){
                                                                                                                      //Get.off(RiderErrandTracker(order: snapshots.data[index].docID,user: widget.user.user,isActive: true,));
                                                                                                                      Utility.bottomProgressSuccess(body: 'Order Assigned to ${snapshot.data[i].agentName}',title: 'Task');
                                                                                                                      if(snapshots.data[index].orderMode.mode != 'Errand')
                                                                                                                      {
                                                                                                                        Utility.pushNotifier(title: 'Delivery',
                                                                                                                            body: 'Your Order has been accepted and the rider(${widget.user.user.fname}) will deliver your package shortly'
                                                                                                                            ,fcm: snapshots.data[index].customerDevice);
                                                                                                                      }
                                                                                                                      else{
                                                                                                                        Utility.pushNotifier(title: 'Request',
                                                                                                                            body: 'Your Errand request has been accepted and the rider(${widget.user.user.fname}) will be with you shortly'
                                                                                                                            ,fcm: snapshots.data[index].customerDevice);
                                                                                                                        Utility.pushNotifier(title: 'Delivery Task',
                                                                                                                            body: 'You have been assigned a task. Click on *Current delivery* for details.(${widget.user.merchant.bName} office)'
                                                                                                                            ,fcm: snapshot.data[i].device);
                                                                                                                      }

                                                                                                                      WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                                                                                                    }
                                                                                                                    else{
                                                                                                                      Utility.bottomProgressFailure(title: 'Request',body: 'Error processing request');
                                                                                                                    }

                                                                                                                  }

                                                                                                                  else{
                                                                                                                    Utility.infoDialogMaker("Insufficient pocket unit.\nLoad pocket unit to accept request");
                                                                                                                  }
                                                                                                                }
                                                                                                                else{
                                                                                                                  Utility.infoDialogMaker("Error encountered while accepting request.\ncheck internet connection and try again");
                                                                                                                }

                                                                                                              },
                                                                                                              leading: CircleAvatar(
                                                                                                                radius: 20,
                                                                                                                child: Center(
                                                                                                                  child: Text('${snapshot.data[i].agentName[0].toUpperCase()}'),
                                                                                                                ),
                                                                                                              ),
                                                                                                              title: Text(snapshot.data[i].agentName),
                                                                                                              subtitle: Column(
                                                                                                                mainAxisSize: MainAxisSize.min,
                                                                                                                children: [
                                                                                                                  Row(
                                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                                    children: [
                                                                                                                      snapshot.data[i].availability?
                                                                                                                      Text('Available',style: TextStyle(color: Colors.green),)
                                                                                                                          :Text('Unavailable',style: TextStyle(color: Colors.red),)    ,
                                                                                                                      snapshot.data[i].busy?
                                                                                                                      Text('Busy',style: TextStyle(color: Colors.redAccent),)
                                                                                                                          :SizedBox.shrink()
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                  if(snapshot.data[i].agentLocation != null)
                                                                                                                    Row(
                                                                                                                      children: [
                                                                                                                        Expanded(child:
                                                                                                                        FutureBuilder(
                                                                                                                            future: Utility.computeDistance(snapshot.data[i].agentLocation,snapshots.data[index].errand.source),
                                                                                                                            initialData: 0.1,
                                                                                                                            builder: (context,AsyncSnapshot<double> distance){
                                                                                                                              //print(snapshot.data[i].agentLocation.latitude);
                                                                                                                              if(distance.hasData){
                                                                                                                                return Text('${Utility.formatDistance(distance.data, "Customer")}');
                                                                                                                              }
                                                                                                                              else{
                                                                                                                                return const SizedBox.shrink();
                                                                                                                              }
                                                                                                                            })
                                                                                                                        )
                                                                                                                      ],
                                                                                                                    )
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
                                                                                                        );
                                                                                                      },
                                                                                                      separatorBuilder: (_,i){return const Divider(thickness: 1,);},
                                                                                                      itemCount: snapshot.data.length);
                                                                                                }
                                                                                                else{
                                                                                                  return Center(
                                                                                                    child: Padding(
                                                                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                                      child: Text('No rider to display'),
                                                                                                    ),
                                                                                                  );
                                                                                                }
                                                                                              }
                                                                                              else{
                                                                                                return Center(
                                                                                                  child: Padding(
                                                                                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                                                                    child: Text('No rider to display'),
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                            }
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    )
                                                                                    )
                                                                                  ],
                                                                                )
                                                                            )
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                              )
                                                          )
                                                      ));

                                                    },
                                                    child: Text('Accept',style: TextStyle(color: Colors.white),),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )

                                        ],
                                      ),
                                    )
                                )
                            ],
                          );
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) => Divider(),
                  itemCount: snapshots.data.length);
            }
            else{
              return ListTile(
                title: Image.asset('assets/images/empty.gif'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'All request has been claimed.',
                        style: TextStyle(
                            fontSize: Get.height * 0.04),textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            }

          }
        },
      ),
    );
  }

}