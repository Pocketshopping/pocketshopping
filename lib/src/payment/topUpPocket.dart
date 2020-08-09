import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class TopUpPocket extends StatefulWidget {
  final String topUp;
  final User user;
  final Wallet wallet;
  final int isPersonal;


  TopUpPocket({this.topUp,this.user,this.wallet,this.isPersonal});

  @override
  State<StatefulWidget> createState() => _TopUpPocketState();
}

class _TopUpPocketState extends State<TopUpPocket> {
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
      case "PAY":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context).size.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            ),
            Center(child: Text('Purchasing pocketUnit please wait...'),),
          ],
        );
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
      default:
        return const SizedBox.shrink();
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
            title: 'PocketUnit( Balance:$CURRENCY${widget.isPersonal==3?widget.wallet.walletBalance:widget.isPersonal==2?widget.wallet.deliveryBalance:widget.wallet.merchantBalance})',
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
                        if (widget.isPersonal==3 && (int.tryParse(value)??0 ) > (widget.wallet.walletBalance-2)) {
                          return 'Insufficient balance';
                        }
                        if (widget.isPersonal == 2 && (int.tryParse(value)??0 ) > (widget.wallet.deliveryBalance-2)) {
                          return 'Insufficient balance';
                        }
                        if (widget.isPersonal == 1 && (int.tryParse(value)??0 + 2 ) > (widget.wallet.merchantBalance-2)) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    child: FlatButton(
                        onPressed: (){
                          if(_formKey.currentState.validate())
                            setState(() {status="PAY";});
                          processPay(int.tryParse(_amount.text)??0);
                        },
                        color: PRIMARYCOLOR,
                        child: Center(child: Text('Buy',style: TextStyle(color: Colors.white),),)
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


  processPay(int amount) async {
        var result;
        if(widget.isPersonal == 3)
        {
            result = await Utility.unitTransfer(
                to:widget.topUp,
                from: widget.user.walletId,
                amount:amount,
                channelId: 3 );
        }

        else if(widget.isPersonal == 2)
        {
          result = await Utility.unitTransfer(
              to:widget.topUp,
              from: widget.user.walletId,
              amount:amount,
              channelId: 2 );
        }
        else{
          result = await Utility.unitTransfer(
              to:widget.topUp,
              from: widget.user.walletId,
              amount:amount,
              channelId: 1 );
        }



        if(result != null){
          WalletRepo.getWallet(widget.user.walletId).then((value) => WalletBloc.instance.newWallet(value));
          setState(() {
            paying = false;
            status = 'SUCCESS';
          });
          startTimer();
          if(widget.user.role == 'rider')
          LogisticRepo.revalidateAgentAllowance(widget.user.uid);
        }
        else{
          setState(() {
            paying = false;
            status = 'ERROR';
            payerror = "Error connecting to server. check your connection.";
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
                color: PRIMARYCOLOR,
                child: Text('Try Again',style: TextStyle(color: Colors.white),),
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
                    Text('Your pocket has been credited with ${_amount.text} Unit(s)',
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