import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/bank/repository/bankRepo.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/withdrawal/repository/WithdrawalRepo.dart';



class BankWithdraw extends StatefulWidget {
  final Wallet wallet;
  final Function callBackAction;
  final String walletID;
  BankWithdraw({this.wallet,this.callBackAction,this.walletID});
  @override
  _BankWithdrawState createState() => new _BankWithdrawState();
}

class _BankWithdrawState extends State<BankWithdraw> {


  int status;



  void initState() {
    status = 0;
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54.withOpacity(0.3),
        body: Container(
            height: Get.height,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  child: Center(
                      child: status == 0 ?Column(
                        children: [
                          Container(
                            color:Colors.grey.withOpacity(0.2),
                            child: Row(
                              children: [
                                Expanded(

                                    child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('Fund Withdraw'),))
                                ),
                                Expanded(
                                  flex: 0,
                                  child: IconButton(
                                    onPressed: (){Get.back(result: 'closed');},
                                    icon: Icon(Icons.close,color: PRIMARYCOLOR),
                                    color: PRIMARYCOLOR,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                          Container(color: Colors.grey.withOpacity(0.2),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              child: Text('You are about to perform a withdrawal transaction with the following details.',
                                style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                            )
                          ),


                          ),
                          Container(color: Colors.grey.withOpacity(0.2),
                            child: Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                  child: Text(' ${(widget.wallet.merchantBalance+widget.wallet.deliveryBalance)<=5000?'Note. for a withdrawal below $CURRENCY 5000 a '
                                      ' service charge of $CURRENCY 10 will be debited.':''}',
                                    style: TextStyle(color: Colors.red),textAlign: TextAlign.center,),
                                )
                            ),


                          ),
                          Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                          Container(color: Colors.grey.withOpacity(0.2),
                            child: Align(
                              alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: Text('Amount: $CURRENCY${(widget.wallet.merchantBalance+widget.wallet.deliveryBalance)}',
                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                )
                            ),
                          ),
                          Container(color: Colors.grey.withOpacity(0.2),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: Text('Bank: ${widget.wallet.bankName}',
                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                )
                            ),
                          ),

                          Container(color: Colors.grey.withOpacity(0.2),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                  child: Text('Account Number: ${widget.wallet.accountNumber}',
                                    style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                )
                            ),
                          ),

                          FutureBuilder<String>(
                            future: BankRepo.verifyBankAccount(widget.wallet.accountNumber, widget.wallet.bankCode),
                            builder: (context,AsyncSnapshot<String>name){
                              if(name.connectionState == ConnectionState.waiting){
                                return const SizedBox.shrink();
                              }else if(name.hasError)
                                return const SizedBox.shrink();
                              else{
                                return Container(color: Colors.grey.withOpacity(0.2),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                                        child: Text('Account Name: ${name.data}',
                                          style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                                      )
                                  ),
                                );
                              }
                            },
                          ),
                          Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),height: 10,),

                          Container(
                              color: Colors.grey.withOpacity(0.2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FlatButton(
                                    onPressed: (){Get.back();},
                                    child: Center(
                                      child: Text('No',style: TextStyle(color: Colors.grey[600]),),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                    onPressed: (){
                                      setState(() {
                                        status=1;
                                      });
                                    Get.dialog(PinTester(wallet: widget.walletID,callBackAction: ()async{

                                      bool result = await WithdrawalRepo.withdrawFunds(wid: widget.walletID);

                                      if(result != null){
                                        if(result){
                                          setState(() {
                                            status =2;
                                          });
                                        }
                                        else{
                                          setState(() {
                                            status =3;
                                          });
                                        }
                                      }
                                      else{
                                        setState(() {
                                          status=3;
                                        });
                                      }

                                    })).then((value){
                                      if(value == 'closed')
                                        Get.back();
                                    });
                                    },
                                    child: Center(
                                      child: Text('Yes Proceed',style: TextStyle(color: PRIMARYCOLOR),),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )



                        ],
                      ):status==1?
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                Text('Processing')
                              ],
                            ),
                          ):status == 2?
                      Container(color: Colors.grey.withOpacity(0.2),
                        child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Your Withdrawal has been completed successfully.',
                                      style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                                  ),
                                  FlatButton(
                                    onPressed: (){Get.back();},
                                      color: PRIMARYCOLOR,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                      child: Text('Ok',style: TextStyle(color: Colors.white),),
                                    )
                                  )
                                ],
                              )
                            )
                        ),
                      ):status==3?
                      Container(color: Colors.grey.withOpacity(0.2),
                        child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('Error processing transaction. Check your network connection and try again',
                                      style: TextStyle(fontSize: 20,color: Colors.red),textAlign: TextAlign.center,),
                                  ),
                                  FlatButton(
                                      onPressed: (){Get.back();},
                                      color: PRIMARYCOLOR,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 5,horizontal: 20),
                                        child: Text('Ok',style: TextStyle(color: Colors.white),),
                                      )
                                  )
                                ],
                              )
                            )
                        ),
                      ):Container(),
                  ),
                )
              ],
            )

        )
    );
  }


}
