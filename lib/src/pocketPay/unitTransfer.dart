import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/validators.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

class PocketUnitTransfer extends StatefulWidget {
  final String wallet;
  final Function callBackAction;
  final User user;
  final String sender;
  PocketUnitTransfer({this.wallet,this.callBackAction,this.user,this.sender});
  @override
  _PocketUnitTransferState createState() => new _PocketUnitTransferState();
}

class _PocketUnitTransferState extends State<PocketUnitTransfer> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final amount = TextEditingController();
  final pocketID = TextEditingController();

  final recipient = ValueNotifier<User>(null);
  final isDone = ValueNotifier<bool>(false);
  bool autoValidate;
  int status;



  void initState() {
    autoValidate=false;
    status = 0;
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54.withOpacity(0.3),
        body: FutureBuilder<Wallet>(
          future: WalletRepo.getWallet(widget.wallet),
          builder: (context,AsyncSnapshot<Wallet>wallet){
            if(wallet.connectionState == ConnectionState.waiting){
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Loading pocket..please wait',textAlign: TextAlign.center,),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            else if(wallet.hasError){
              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Error Fetching pocket..check internet and try again',textAlign: TextAlign.center,),
                          ),
                          Center(
                            child: FlatButton(
                              onPressed: (){Get.back();},
                              child: Text('Ok',style: TextStyle(color: Colors.white),),
                              color: PRIMARYCOLOR,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            else{
              return wallet.data != null ? Container(
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

                                          child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('PocketUnit Transfer'),))
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
                                Container(
                                  color:Colors.grey.withOpacity(0.2),
                                  child: Row(
                                    children: [
                                      Expanded(

                                          child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('Balance: ${wallet.data.pocketUnitBalance} Unit(s)',
                                              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),))
                                      ),
                                    ],
                                  ),
                                ),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        padding: EdgeInsets.symmetric(horizontal: 15),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (!Validators.isValidAmount(value)) {
                                              return 'Enter valid unit';
                                            }
                                            if(int.tryParse(value) == 0){
                                              return 'Enter unit';
                                            }
                                            if(value.isEmpty){
                                              return 'Enter unit';
                                            }
                                            if(int.tryParse(value) < 100){
                                              return 'Must be greater than or equal to 100';
                                            }
                                            if((int.tryParse(value)+2) > wallet.data.pocketUnitBalance){
                                              return 'Insufficient unit for transfer (Convenience unit(2 unit) included)';
                                            }

                                            return null;
                                          },
                                          controller: amount,
                                          decoration: InputDecoration(
                                              labelText: 'Unit',
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
                                          enabled: true,
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
                                      Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        padding: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if(value.length < 10){
                                              return 'Invalid AccountID';
                                            }
                                            if(value.isEmpty){
                                              return 'Invalid AccountID';
                                            }
                                            if(value == widget.wallet){
                                              return "Can't transfer to thesame pocket";
                                            }
                                            if(recipient.value == null){
                                              return "Can't transfer to unknown user. check the accountID";
                                            }

                                            return null;
                                          },
                                          controller: pocketID,
                                          decoration: InputDecoration(
                                              labelText: 'Account ID',
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
                                          enabled: true,
                                          autovalidate: autoValidate,
                                          textInputAction: TextInputAction.done,
                                          maxLength: 10,
                                          onChanged: (value)async {
                                            if(value.length == 10){
                                              isDone.value =false;
                                              recipient.value = await UserRepo.getUserUsingWallet(pocketID.text.trim());
                                              isDone.value =true;


                                            }
                                          },
                                          style: TextStyle(fontSize: 18,),
                                        ),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: recipient,
                                        builder: (_,User user,__){
                                          return ValueListenableBuilder(
                                            valueListenable: isDone,
                                            builder: (_,bool isDone,__){
                                              if(user == null && pocketID.text.isEmpty && isDone){return const SizedBox.shrink();}
                                              else if(user == null && pocketID.text.isNotEmpty && !isDone){
                                                return Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        CircularProgressIndicator(),
                                                        Text('Fetching recipient..please wait'),
                                                      ],
                                                    ),
                                                  ),
                                                );}
                                              else if(user != null && pocketID.text.isNotEmpty && isDone){
                                                return Container(
                                                  color:Colors.grey.withOpacity(0.2),
                                                  child: Row(
                                                    children: [
                                                      Expanded(

                                                          child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                                            child: Text('Recipient: ${user.fname}', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),))
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                              else{
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          );
                                        },
                                      ),
                                      Container(
                                        color: Colors.grey.withOpacity(0.2),
                                        child:
                                        FlatButton(

                                          color: PRIMARYCOLOR,
                                          child: Center(child: Text('Send',style: TextStyle(color: Colors.white),),),
                                          onPressed: ()async{
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            if(_formKey.currentState.validate()){
                                              Get.back();
                                              Get.defaultDialog(
                                                title: 'Confirm',
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Align(alignment: Alignment.centerLeft,child: Text('You are about to transfer'),),
                                                    Align(alignment: Alignment.centerLeft,child: Text('Units: ${amount.text}'),),
                                                    Align(alignment: Alignment.centerLeft,child: Text('Recipient: ${recipient.value.fname}'),),
                                                    Align(alignment: Alignment.centerLeft,child: Text('Convenience Fee: 2.0 units'),),
                                                    Align(alignment: Alignment.centerLeft,child: Text('Total: ${(int.tryParse(amount.text)??0)+2} units',style: TextStyle(fontWeight: FontWeight.bold),),),
                                                  ],
                                                ),
                                                cancel: FlatButton(
                                                  onPressed: (){Get.back();},
                                                  child: Text('No'),
                                                ),
                                                confirm: FlatButton(
                                                  child: Text('Yes'),
                                                  onPressed: ()async{
                                                    bool set = await PinRepo.isSet(widget.wallet);
                                                    if(set){
                                                      Get.back();
                                                      Get.dialog(PinTester(wallet: widget.sender,callBackAction: ()async{
                                                        Utility.bottomProgressLoader(title: 'Pocketunit Transfer',body: 'Transferring ${amount.text} Unit...please wait');
                                                        bool result = await Utility.unitTransfer(
                                                            to:recipient.value.walletId,
                                                            from: widget.wallet,
                                                            amount:int.tryParse(amount.text)??0,
                                                            channelId: 4 );
                                                        Get.back();
                                                        if(result != null){
                                                          if(result){
                                                            Utility.bottomProgressSuccess(title: 'Pocketunit Transfer',body: 'Transfer complete',wallet: widget.wallet);
                                                            Utility.pushNotifier(fcm:recipient.value.notificationID,
                                                                body:"${amount.text} unit(s) was transferred to you by ${widget.user.fname}",
                                                                title:'Unit Transfer',
                                                                notificationType:"PocketTransferResponse",
                                                                data: {'wallet':recipient.value.walletId});
                                                          }
                                                          else{
                                                            Utility.bottomProgressFailure(title: 'Pocketunit Transfer',body: 'Error transferring unit...check connection and Try again');
                                                          }
                                                        }
                                                        else{
                                                          Utility.bottomProgressFailure(title: 'Pocketunit Transfer',body: 'Error transferring unit...check connection and Try again');
                                                        }
                                                      },
                                                      )
                                                      );
                                                    }
                                                    else{
                                                      Get.back();
                                                      Get.defaultDialog(
                                                        title: 'Pocket PIN',
                                                        content: Text(
                                                            'You need to setup pocket PIN before you can proceed with transfer. Goto Menu > Settings > Set PocketPin '),
                                                        cancel: FlatButton(
                                                          onPressed: () {Get.back();},
                                                          child: Text('ok'),
                                                        ),

                                                      );
                                                    }
                                                  },

                                                ),
                                              );
                                            }
                                            else{

                                            }
                                            /*bool set = await PinRepo.isSet(widget.wallet);
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
                                        }*/
                                          },
                                        ),
                                      )


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
                  :
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 15),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Error Fetching pocket..check internet and try again',textAlign: TextAlign.center,),
                          ),
                          Center(
                            child: FlatButton(
                              onPressed: (){Get.back();},
                              child: Text('Ok',style: TextStyle(color: Colors.white),),
                              color: PRIMARYCOLOR,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        )
    );
  }


}
