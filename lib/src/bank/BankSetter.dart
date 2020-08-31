import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/bank/repository/bankCode.dart';
import 'package:pocketshopping/src/bank/repository/bankRepo.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class BankSetter extends StatefulWidget {
  final String wallet;
  final Function callBackAction;
  BankSetter({this.wallet,this.callBackAction});
  @override
  _BankSetterState createState() => new _BankSetterState();
}

class _BankSetterState extends State<BankSetter> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final accountNumber = TextEditingController();
  TextEditingController  accountName = TextEditingController();
  BankCode bank;
  bool autoValidate;
  int status;
  bool hasFailed;
  bool isAcctEnabled;
  bool isBankEnabled;


  void initState() {
    autoValidate=false;
    bank = BankCode(name: 'Select Bank',code: '00');
    status = 0;
    hasFailed = false;
    isAcctEnabled=true;
    isBankEnabled=true;

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
                      child: Column(
                        children: [
                          Container(
                            color:Colors.grey.withOpacity(0.2),
                            child: Row(
                              children: [
                                Expanded(

                                    child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('SetUp Bank Account for withdrawal'),))
                                ),
                                Expanded(
                                  flex: 0,
                                  child: IconButton(
                                    onPressed: (){Get.back();},
                                    icon: Icon(Icons.close,color: PRIMARYCOLOR),
                                    color: PRIMARYCOLOR,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.grey.withOpacity(0.2),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return 'Enter Bank Account Number';
                                      }
                                      return null;
                                    },
                                    controller: accountNumber,
                                    decoration: InputDecoration(
                                      hintText: 'Bank Account Number',
                                      hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                      //filled: true,
                                      //fillColor: Colors.grey.withOpacity(0.2),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none
                                    ),
                                    autofocus: false,
                                    enabled: isAcctEnabled,
                                    autovalidate: autoValidate,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                    onChanged: (value) {},
                                    maxLength: 10,
                                    maxLengthEnforced: true,
                                    style: TextStyle(fontSize: 18,),
                                    buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                  ),
                                ),
                                Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                                FutureBuilder<List<BankCode>>(
                                  future: BankRepo.getBankCode(),
                                  builder: (context,AsyncSnapshot<List<BankCode>>banks){
                                    if(banks.hasError)return Text('Error fetching banks.');
                                    if(banks.hasData){
                                      List<BankCode> temp = [BankCode(name: 'Select Bank',code: '00')];
                                      temp.addAll(banks.data);
                                      return Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        padding: EdgeInsets.symmetric(horizontal: 15),
                                        child: DropdownButtonFormField<BankCode>(
                                          validator: (value) {
                                            if (value.name == 'Select Bank') {
                                              return 'Select a Bank';
                                            }
                                            return null;
                                          },

                                          autovalidate: autoValidate,
                                          value: bank,
                                          items: temp
                                              .map((label) => DropdownMenuItem(
                                            child: Text(
                                              label.name,
                                              style: TextStyle(
                                                  color:
                                                  Colors.black54),
                                            ),
                                            value: label,
                                          ))
                                              .toList(),
                                          isExpanded: true,

                                          style: TextStyle(fontSize: 18,),
                                          hint: Text('Bank'),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                            enabled: isBankEnabled
                                            //filled: true,
                                            //fillColor: Colors.grey.withOpacity(0.2),
                                          ),
                                          onChanged: isBankEnabled?(value) {
                                            setState(() {
                                              bank=value;
                                            });
                                          }:null,
                                          disabledHint: Text(bank.name),
                                        )
                                      );
                                    }
                                    else{
                                      return Container(
                                          color: Colors.grey.withOpacity(0.2),
                                        child: Center(child: CircularProgressIndicator(),)
                                      );
                                    }
                                  },
                                ),
                                if(hasFailed && status ==0)
                                Container(
                                    color: Colors.grey.withOpacity(0.2),
                                    child: Center(child: Text(
                                      'Error verifying bank account. Ensure you are entering the correct bank details.',
                                      style: TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),)
                                ),
                                Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                                if(status == 1)
                                  Container(
                                      color: Colors.grey.withOpacity(0.2),
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                      child: Column(
                                        children: [
                                          Center(child: CircularProgressIndicator(),),
                                          Center(child: Text('Verifying Bank Account..please wait'),)
                                        ],
                                      )
                                  ),
                                if(status == 2)
                                  Column(
                                    children: [
                                      Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                        child: TextFormField(
                                          controller: accountName,
                                          decoration: InputDecoration(
                                            hintText: 'Bank Account Name',
                                            hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none
                                          ),
                                          autofocus: false,
                                          enabled: isAcctEnabled,
                                          textInputAction: TextInputAction.done,
                                          onChanged: (value) {},
                                          style: TextStyle(fontSize: 18,),
                                        ),
                                      ),
                                      Container(child: const Divider(thickness: 0.5,),color: Colors.grey.withOpacity(0.2),),
                                      Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        child: Row(
                                          children: [
                                            Expanded(

                                                child: FlatButton(
                                                  child: Center(child: Text('Cancel',style: TextStyle(color: Colors.black54),),),
                                                  onPressed: ()async{
                                                    setState(() {
                                                      autoValidate=false;
                                                      bank = BankCode(name: 'Select Bank',code: '00');
                                                      status = 0;
                                                      hasFailed = false;
                                                      isAcctEnabled=true;
                                                      isBankEnabled=true;
                                                      accountName.clear();
                                                      accountNumber.clear();
                                                    });
                                                    Get.back();
                                                  },
                                                )
                                            ),
                                            Expanded(

                                                child: FlatButton(
                                                  color: PRIMARYCOLOR,
                                                  child: Center(child: Text('Set',style: TextStyle(color: Colors.white),),),
                                                  onPressed: ()async{
                                                    bool set = await PinRepo.isSet(widget.wallet);
                                                    if(set)
                                                      {
                                                        Get.back();
                                                        Get.dialog(PinTester(wallet: widget.wallet,callBackAction: ()async{
                                                          Utility.bottomProgressLoader(title: '',body: 'Setting Up Bank account...please wait');
                                                          bool result = await Utility.updateWalletAccount(
                                                            wid: widget.wallet, accountNumber: accountNumber.text,
                                                            sortCode: bank.code,
                                                            bankName: bank.name,
                                                          );
                                                          Get.back();
                                                          if(result != null){
                                                            if(result){
                                                              Utility.bottomProgressSuccess(title: '',body: 'Bank Account Setup complete');
                                                            }
                                                            else{
                                                              Utility.bottomProgressFailure(title: '',body: 'Error Setting Bank account...check connection and Try again');
                                                            }
                                                          }
                                                          else{
                                                            Utility.bottomProgressFailure(title: '',body: 'Error Setting Bank account...check connection and Try again');
                                                          }
                                                        },));
                                                      }
                                                    else
                                                      {
                                                        Get.back();
                                                        Get.defaultDialog(
                                                            title: 'Pocket PIN',
                                                            content: Text(
                                                                'You need to setup pocket PIN before you can proceed with setting up bank account.'),
                                                            cancel: FlatButton(
                                                              onPressed: () {

                                                                Get.back();


                                                              },
                                                              child: Text('ok'),
                                                            ),

                                                        );
                                                      }
                                                  },
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )

                              ],
                            ),
                          ),
                          Container(color:Colors.grey.withOpacity(0.2), height:20,),
                          if(status == 0)
                          Container(
                            color:PRIMARYCOLOR,
                            child: Row(
                              children: [
                                Expanded(

                                    child: FlatButton(
                                      focusNode: FocusNode(),
                                      color: PRIMARYCOLOR,
                                      child: Center(child: Text(hasFailed?'Reverify':'Verify',style: TextStyle(color: Colors.white),),),
                                      onPressed: ()async{
                                        if(_formKey.currentState.validate()){
                                         setState(() {
                                           status = 1;
                                           isAcctEnabled=false;
                                           isBankEnabled=false;
                                         });
                                         try{
                                           String bName  = await BankRepo.verifyBankAccount(accountNumber.text, bank.code);

                                           setState(() {
                                             status=2;
                                             hasFailed = true;
                                             isAcctEnabled=false;
                                             isBankEnabled=false;
                                             //accountName.text=v;
                                             accountName.text=bName;
                                           });
                                         }
                                         catch(_){
                                           setState(() {
                                             status=0;
                                             hasFailed = true;
                                             isAcctEnabled=true;
                                             isBankEnabled=true;
                                           });
                                         }
                                        }
                                        else{
                                          setState(() {
                                            autoValidate =true;
                                          });
                                        }
                                      },
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                )
              ],
            )

        )
    );
  }


}
