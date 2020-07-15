import 'package:flutter/material.dart';
import 'package:flutter_skeleton/flutter_skeleton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/deliveryTracker.dart';
import 'package:pocketshopping/src/order/rTracker.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

import 'repository/order.dart';

class RequestBucket extends StatefulWidget {
  RequestBucket({this.user});
  final Session user;

  @override
  State<StatefulWidget> createState() => _RequestBucketState();
}

class _RequestBucketState extends State<RequestBucket> {

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
            MediaQuery.of(context).size.height *
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
        stream: OrderRepo.getRequestBucket(widget.user.agent.agentID),
        builder: (context,AsyncSnapshot<List<Order>>snapshots){
          if(snapshots.connectionState == ConnectionState.waiting){
            return Center(
                child: JumpingDotsProgressIndicator(
                  fontSize: MediaQuery.of(context).size.height * 0.12,
                  color: PRIMARYCOLOR,
                ));
          }
          else if(snapshots.hasError){
            return Center(
              child: Text('Error communicating with server. Check your connection and try again',textAlign: TextAlign.center,),
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
                                                  const SizedBox(height: 20,),
                                                  (snapshots.data[index].receipt.type == 'CASH')?
                                                  Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Payment On Delivery',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
                                                  ):Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text('Customer already paid once delivery is done fund will be transferred to your company',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),),
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
                                                      snapshots.data[index].potentials.remove(widget.user.agent.agentID);
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
                                                      bool result;
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
                                                        Get.off(RiderTracker(order: snapshots.data[index].docID,user: widget.user.user,));
                                                        Utility.bottomProgressSuccess(body: 'Order Accepted',title: 'Delivery');
                                                        Utility.pushNotifier(title: 'Delivery',
                                                            body: 'Your Order has been accepted and the rider(${widget.user.user.fname}) will deliver your package shortly'
                                                            ,fcm: snapshots.data[index].customerDevice);
                                                        WalletRepo.getWallet(widget.user.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
                                                      }
                                                      else{
                                                        Utility.bottomProgressFailure(title: '',body: 'Error processing request');
                                                      }

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
                                                      snapshots.data[index].potentials.remove(widget.user.agent.agentID);
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
                                                      bool result;
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
                                                        Get.off(RiderTracker(order: snapshots.data[index].docID,user: widget.user.user,));
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
                                                      }

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
                            fontSize: MediaQuery.of(context).size.height * 0.04),textAlign: TextAlign.center,
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