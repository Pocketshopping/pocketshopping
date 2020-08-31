import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/withdrawal/repository/WithdrawalRepo.dart';
import 'package:pocketshopping/src/withdrawal/repository/withdrawalObj.dart';
import 'package:progress_indicators/progress_indicators.dart';

class WithdrawalWidget extends StatefulWidget {
  final Session user;
  WithdrawalWidget({this.user,});
  @override
  _WithdrawalState createState() => new _WithdrawalState();
}

class _WithdrawalState extends State<WithdrawalWidget> {


  void initState() {
    super.initState();
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
          title: Text('Withdrawals',style: TextStyle(color: PRIMARYCOLOR),),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0.0,
      ),
      body: Column(
        children: [
          Expanded(flex: 0,child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
              child: Text('List of withdrawal(Last 30 days)',style: TextStyle(fontWeight: FontWeight.bold),)
            ),
          ),),
          Expanded(flex: 0,child: SizedBox(height: 10,),),
          Expanded(
                child: RefreshIndicator(
                  child: FutureBuilder<List<Withdrawal>>(
                    future: WithdrawalRepo.withdrawReport(wid: widget.user.merchant.bWallet),
                    builder: (context,AsyncSnapshot<List<Withdrawal>>snapshot)
                    {
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: JumpingDotsProgressIndicator(
                            fontSize: Get.height * 0.12,
                            color: PRIMARYCOLOR,
                          ),
                        );
                      }
                      else if(snapshot.hasError){
                        return Center(
                          child: Text('Error connecting to pocketshopping server.'),
                        );
                      }
                      else{
                        if(snapshot.data.isNotEmpty){
                          return ListView.separated(
                              itemBuilder: (context,index){
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                    child: snapshot.data[index].anSuccess == 'success'?
                                    Icon(Icons.check,color: Colors.green,)
                                        :
                                    snapshot.data[index].anSuccess == 'failed'?
                                    Icon(Icons.close,color: Colors.red,)
                                        :
                                    Icon(Icons.query_builder,color: Colors.orangeAccent,)
                                  ),
                                  title: Text('$CURRENCY${snapshot.data[index].amount}'),
                                  subtitle: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Expanded(
                                            flex:0,
                                            child: snapshot.data[index].anSuccess == 'success'?
                                            Text('Successful')
                                                :
                                            snapshot.data[index].anSuccess == 'failed'?
                                            Text('Failed')
                                                :
                                            Text('Pending')
                                          ),
                                          Expanded(
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text('${Utility.presentDate(DateTime.parse(snapshot.data[index].dateOfTransaction))}')
                                            ),
                                          )
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text('Ref: ${snapshot.data[index].reference}',style: TextStyle(fontWeight: FontWeight.bold),),
                                          )
                                        ],
                                      ),
                                      if(snapshot.data[index].anSuccess == 'failed')
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text('Error encountered processing withdrawal request. Pocketshopping is tracking the issue.'),
                                            )
                                          ],
                                        ),
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount: snapshot.data.length);
                        }
                        else{
                          return ListView(
                            children: [
                              ListTile(
                                title: Image.asset('assets/images/empty.gif'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        'Empty',
                                        style: TextStyle(
                                            fontSize: Get.height * 0.06),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text(
                                              "No withdrawals.",
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          );
                        }
                      }
                    }
                  ),
                  onRefresh: _refresh,
                ),


          ),
        ],
      ),

    );
  }



  Future<void> _refresh() async {
    setState(() {

    });
  }










}
