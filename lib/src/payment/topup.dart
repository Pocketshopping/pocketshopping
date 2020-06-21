import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/payment/atmCard.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class TopUp extends StatefulWidget {
  final String payType;
  final User user;


  TopUp({this.payType="TOPUP",this.user});

  @override
  State<StatefulWidget> createState() => _TopUpState();
}

class _TopUpState extends State<TopUp> {
  static const platform = const MethodChannel('fleepage.pocketshopping');
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amount = TextEditingController();
  bool paying;
  bool autoVal;
  bool isNumer;
  String status;
  String payerror;
  int _start = 5;
  Timer _timer;


  @override
  void initState() {
    isNumer =true;
    paying =false;
    autoVal = false;
    status = "INIT";
    payerror="";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: _willPopScope,child:
    Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: paying?Center(
          child: JumpingDotsProgressIndicator(
            fontSize: MediaQuery.of(context).size.height * 0.12,
            color: PRIMARYCOLOR,
          ),
        ):manager()
      ),
    )
      ,);
  }

  Widget manager(){
    switch(status){
      case "INIT":
        return init();
      break;

      case "CARD":
        return ListView(
            children: [
              ATMCard(
            onPressed:(Map<String,dynamic> details) {
              setState(() {paying=true;});
              ProcessPay(details);
            }
        )]);
      break;
      case "ERROR":
        return ListView(
            children: [
              payError()
            ]);
        break;
      case "SUCCESS":
        return ListView(
            children: [
              paySuccess()
            ]);
        break;
    }
  }

  Widget init(){
    return ListView(
      children: [
        Center(child:
        Image.asset('assets/images/topup.gif',
          height: MediaQuery.of(context).size.height*0.4,
        )
        ),
        Center(child:
        psCard(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            title: widget.payType=='TOPUP'?'Wallet TopUp':'PocketUnit',
            color: PRIMARYCOLOR,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            //                   <--- left side
                            color: Colors.black12,
                            width: 1.0,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                      child:Center(child: Text('Enter the amount you want to TopUp'),)),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          //                   <--- left side
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.02),
                    child: TextFormField(
                      controller: _amount,
                      decoration: InputDecoration(
                          hintText: 'Amount',
                          border: InputBorder.none),
                      keyboardType: TextInputType.numberWithOptions(),
                      autocorrect: false,
                      autovalidate: autoVal,
                      onChanged: (value){setState(() {
                        autoVal=true;
                        try{
                          int.parse(value);
                          isNumer=true;
                        }catch(_){isNumer=false;}
                      });},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'invalid Amount';
                        }
                        else if (!isNumer) {
                          return 'invalid Amount';
                        }
                        if (int.tryParse(value) == 0) {
                          return 'invalid Amount';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    child: FlatButton(
                        onPressed: (){
                          if(_formKey.currentState.validate())setState(() {status="CARD";});
                        },
                        color: PRIMARYCOLOR,
                        child: Center(child: Text(widget.payType=='TOPUP'?'TopUp':'Buy',style: TextStyle(color: Colors.white),),)
                    ),
                  ),
                ],
              ),

            )
        )
          ,)
      ],
    );
  }


  ProcessPay(Map<String,dynamic> details ) async {
    Map<String,String> reference;
    details['email']=widget.user.email;
    var temp = details['expiry'].toString().split('/');
        reference =Map.from(
            await platform.invokeMethod('CardPay',
                Map.from({
                  "card":(details['card'] as String),
                  "cvv":(details['cvv'] as String),
                  "month":int.parse(temp[0]),
                  "year":int.parse(temp[1]),
                  "amount":int.tryParse(_amount.text),
                  "email":(details['email'] as String),

                }))
        );
        if (reference.isNotEmpty) {
          var details = await Utility.fetchPaymentDetail(reference['reference']);
          //print(json.decode(details.body));
          //await Future.delayed(Duration(seconds: 5),(){
          if (details != null) {
            var result;
            if(widget.payType == "TOPUP")
              {
                var status = jsonDecode(details.body)['data']['status'];
                if(status != "abandoned")
                result = await Utility.topUpWallet(reference['reference'],
                    widget.user.walletId, status, status == 'success'?1:2, jsonDecode(details.body)['data']['amount'], 1);
              }

            else if(widget.payType == "TOPUPUNIT")
              {var status = jsonDecode(details.body)['data']['status'];
              if(status != "abandoned")
                result = await Utility.topUpUnit(reference['reference'],
                    widget.user.walletId, status, status == 'success'?1:2, jsonDecode(details.body)['data']['amount'], 1);
              LogisticRepo.revalidateAgentAllowance(widget.user.uid);
              }



            if(result != null){
              WalletRepo.getWallet(widget.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
              setState(() {
                paying = false;
                status = 'SUCCESS';
              });
              startTimer();

            }
            else{
              setState(() {
                paying = false;
                status = 'ERROR';
                payerror = "Error connecting to server. check your connection and try again";
              });
            }

          } else {
            if (reference['error'].toString().isNotEmpty) {
              setState(() {
                paying = false;
                status = 'ERROR';
                payerror = reference['error'].toString();
              });
            }
          }
        } else {
          setState(() {
            paying = false;
            status = 'ERROR';
            payerror = "Something went wrong try again";
          });
        }



    //});
  }

  Widget payError() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              height: MediaQuery.of(context).size.height * 0.18,
              child: Icon(
                Icons.close,
                color: Colors.red,
                size: MediaQuery.of(context).size.height * 0.18,
              ),
            ),
            Center(
              child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                      child: Text(
                        '$payerror',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.025),
                        textAlign: TextAlign.center,
                      )
                  )
              ),
            ),
            Center(
              child: FlatButton(
                onPressed: () {
                  setState(() {
                    status = 'INIT';
                  });
                },
                child: Text('Try Again'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget paySuccess(){
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              child: Image.asset('assets/images/success.gif'),
            ),
          ),
          Expanded(
              flex: 1,
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      widget.payType=='TOPUP'?'Your pocket has been credited':'Your pocket has been credit with ${_amount.text} Unit(s)',
                      style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.height * 0.04),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${_start}s',
                      style: TextStyle(
                          fontSize:
                          MediaQuery.of(context).size.height * 0.05),
                    ),
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
            Get.back();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }


  Future<bool> _willPopScope() async {
    if(paying)
    return false;
    else
      return true;
  }

}