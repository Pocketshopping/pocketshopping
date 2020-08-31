import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/repository/otpObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:random_string/random_string.dart';

class PinResetter extends StatefulWidget {
  final User user;
  PinResetter({this.user});
  @override
  _PinResetterState createState() => new _PinResetterState();
}

class _PinResetterState extends State<PinResetter> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pin = TextEditingController();
  final oldPin = TextEditingController();
  final cPin = TextEditingController();
  final first = FocusNode();
  final second = FocusNode();
  final third = FocusNode();
  final stage = ValueNotifier<int>(0);

  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54.withOpacity(0.3),
        body: Container(
            height: Get.height,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: FutureBuilder(
              future: PinRepo.getOtp(widget.user.walletId),
              builder: (contx,AsyncSnapshot<Otp>snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return Center(
                      child: JumpingDotsProgressIndicator(
                        fontSize: Get.height * 0.12,
                        color: Colors.white,
                      ));
                }
                else if(snapshot.hasError){
                  print(snapshot.error);
                  return Center(
                      child: Text('Error communicating with server check internet '
                          'connection and try again.',style: TextStyle(color: Colors.white),textAlign: TextAlign.center,));
                }
                else{
                  String otp = randomNumeric(4);
                  if(snapshot.data == null){
                    PinRepo.saveOtp(Otp(
                      otp: otp,
                      id: widget.user.walletId,
                      isNew: true,
                      insertedAt: Timestamp.now(),
                    ));
                   Utility.resetPasswordOtp(email: widget.user.email,otp: otp);
                  }
                  else{
                    if(!snapshot.data.isNew){
                      PinRepo.saveOtp(Otp(
                        otp: otp,
                        id: widget.user.walletId,
                        isNew: true,
                        insertedAt: Timestamp.now(),
                      ));
                      Utility.resetPasswordOtp(email: widget.user.email,otp: otp);
                    }
                  }

                    return ListView(
                      children: [
                        const SizedBox(height: 20,),
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

                                            child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('Reset 4-Digit Pocket PIN'),))
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
                                  Container(
                                    color:Colors.grey.withOpacity(0.2),
                                    child: Row(
                                      children: [
                                        Expanded(

                                            child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('An OTP has been sent to your email (${widget.user.email})'),))
                                        ),
                                      ],
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter OTP';
                                            }
                                            return null;
                                          },
                                          focusNode: first,
                                          showCursor: true,
                                          readOnly: true,
                                          controller: oldPin,
                                          decoration: InputDecoration(
                                            hintText: 'OTP',
                                            hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                            filled: true,
                                            fillColor: Colors.grey.withOpacity(0.2),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            errorBorder: InputBorder.none,
                                          ),
                                          autofocus: true,
                                          textInputAction: TextInputAction.done,
                                          obscureText:true,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                          onChanged: (value) {},
                                          obscuringCharacter: '*',
                                          maxLength: 4,
                                          maxLengthEnforced: true,
                                          style: TextStyle(fontSize: 30,letterSpacing: Get.width*0.2),
                                          buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                          onTap: (){
                                            stage.value = 0;
                                          },
                                        ),
                                        TextFormField(
                                          validator: (value) {
                                            if (value.isEmpty) {
                                              return 'Enter 4 Digit PIN';
                                            }
                                            return null;
                                          },
                                          focusNode: second,
                                          showCursor: true,
                                          readOnly: true,
                                          controller: pin,
                                          decoration: InputDecoration(
                                            hintText: 'New PIN',
                                            hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                            filled: true,
                                            fillColor: Colors.grey.withOpacity(0.2),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            errorBorder: InputBorder.none,
                                          ),
                                          autofocus: false,
                                          textInputAction: TextInputAction.done,
                                          obscureText:true,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                          onChanged: (value) {},
                                          obscuringCharacter: '*',
                                          maxLength: 4,
                                          maxLengthEnforced: true,
                                          style: TextStyle(fontSize: 30,letterSpacing: Get.width*0.2),
                                          buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                          onTap: (){
                                            stage.value = 1;
                                          },
                                        ),
                                        TextFormField(
                                          validator: (value) {
                                            if (value != pin.text) {
                                              return 'PIN and Confirm PIN do not match';
                                            }
                                            return null;
                                          },
                                          focusNode: third,
                                          showCursor: true,
                                          readOnly: true,
                                          controller: cPin,
                                          decoration: InputDecoration(
                                            hintText: 'Confirm PIN',
                                            hintStyle: TextStyle(fontSize: 18,letterSpacing: 1),
                                            filled: true,
                                            fillColor: Colors.grey.withOpacity(0.2),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                            ),
                                            errorBorder: InputBorder.none,
                                          ),
                                          autofocus: false,
                                          textInputAction: TextInputAction.done,
                                          obscureText:true,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                                          onChanged: (value) {},
                                          obscuringCharacter: '*',
                                          style: TextStyle(fontSize: 30,letterSpacing: Get.width*0.2),
                                          maxLength: 4,
                                          maxLengthEnforced: true,
                                          buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                                          onTap: (){
                                            stage.value = 2;
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  /*Container(color:Colors.grey.withOpacity(0.2), height:20,),
                          Container(
                            color:PRIMARYCOLOR,
                            child: Row(
                              children: [
                                Expanded(

                                    child: FlatButton(
                                      color: PRIMARYCOLOR,
                                      child: Center(child: Text('Set',style: TextStyle(color: Colors.white),),),
                                      onPressed: ()async{
                                        if(_formKey.currentState.validate()){
                                          Get.back();
                                          Utility.bottomProgressLoader(title: '',body: 'Changing Pocket PIN...please wait');
                                          bool pinTest = await PinRepo.fetchPin(oldPin.text, widget.user.walletId);
                                          if(pinTest){
                                            bool result = await PinRepo.save(Pin(pin: pin.text), widget.user.walletId);
                                            Get.back();
                                            if(result)
                                              Utility.bottomProgressSuccess(title: '',body: 'Pocket PIN Changed');
                                            else
                                              Utility.bottomProgressFailure(title: '',body: 'Error Changing PIN...Try again');
                                          }
                                          else{
                                            Get.back();
                                            Utility.infoDialogMaker('Incorrect old PIN. Enter correct PIN and try again',title: '');
                                          }
                                        }
                                      },
                                    )
                                ),
                              ],
                            ),
                          ),*/

                                ],
                              )
                          ),
                        ),
                        Container(height:20,),
                        ValueListenableBuilder(
                          valueListenable: stage,
                          builder: (_,int _stage,__){
                            return Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '1';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '1';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '1';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('1',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '2';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '2';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '2';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('2',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '3';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '3';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '3';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('3',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '4';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '4';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '4';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('4',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '5';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '5';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '5';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('5',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '6';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '6';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '6';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('6',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '7';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '7';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '7';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('7',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '8';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '8';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '8';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('8',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '9';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '9';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '9';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('9',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Expanded(
                                            child:GestureDetector(
                                                onTap: (){
                                                  if(_stage == 0)
                                                  {
                                                    oldPin.text = oldPin.text + '0';
                                                  }
                                                  else if(_stage == 1)
                                                  {
                                                    pin.text = pin.text + '0';
                                                  }
                                                  else{
                                                    cPin.text = cPin.text + '0';
                                                  }
                                                },
                                                child:  Center(
                                                  child: Text('0',style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.bold),),
                                                )
                                            )
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20,),
                                    Row(
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: (){

                                                if(_stage == 0)
                                                {
                                                  if(oldPin.text.length>0)
                                                    oldPin.text = oldPin.text.substring(0,(oldPin.text.length-1));
                                                }
                                                else if(_stage == 1)
                                                {
                                                  if(pin.text.length>0)
                                                    pin.text = pin.text.substring(0,(pin.text.length-1));
                                                }
                                                else{
                                                  if(cPin.text.length>0)
                                                    cPin.text = cPin.text.substring(0,(cPin.text.length-1));
                                                }
                                              },
                                              child: Center(
                                                child: Text('Del',style: TextStyle(color: Colors.white,fontSize: 40),),
                                              ),
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                              onTap: (){
                                                if(_stage == 0)
                                                {
                                                  oldPin.text = '';
                                                }
                                                else if(_stage == 1){
                                                  pin.text = '';
                                                }
                                                else
                                                {
                                                  cPin.text = '';
                                                }

                                              },
                                              child: Center(
                                                child: Text('Clear',style: TextStyle(color: Colors.white,fontSize: 40),),
                                              ),
                                            )
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: ()async{

                                                  if(_stage == 0){
                                                    stage.value = 1;
                                                    FocusScope.of(context).requestFocus(second);
                                                  }
                                                  else if(_stage == 1){
                                                    stage.value = 2;
                                                    FocusScope.of(context).requestFocus(third);
                                                  }
                                                  else{
                                                    FocusScope.of(context).requestFocus(FocusNode());
                                                    if(_formKey.currentState.validate()){
                                                      Get.back();
                                                      Utility.bottomProgressLoader(title: 'Pocket Pin',body: 'Changing Pocket PIN...please wait');
                                                      Otp otp = await PinRepo.getOtp(widget.user.walletId);
                                                      Get.back();
                                                      if(otp.insertedAt.toDate().difference(DateTime.now()).inMinutes<15){
                                                        if(otp.otp == oldPin.text){
                                                          bool result = await PinRepo.save(Pin(pin: pin.text), widget.user.walletId);
                                                          Get.back();
                                                          if(result)
                                                            {
                                                              Utility.bottomProgressSuccess(title: 'Pocket Pin',body: '4-Digit Pocket PIN Changed');
                                                              PinRepo.saveOtp(otp.copyWith(isNew: false));
                                                            }
                                                          else
                                                            Utility.bottomProgressFailure(title: 'Pocket Pin',body: 'Error Changing 4-Digit PIN...Try again');
                                                        }
                                                        else{
                                                          Utility.bottomProgressFailure(title: 'Pocket Pin',body: 'Incorrect OTP.',duration: 5);
                                                        }
                                                      }
                                                      else{
                                                        Utility.bottomProgressFailure(title: 'Pocket Pin',body: 'OTP has expired a new OTP has been sent to your email.',duration: 5);
                                                      }
                                                    }
                                                  }

                                                },
                                                child: Center(
                                                  child: Text(_stage > 1?'Ok':'Next',style: TextStyle(color: Colors.white,fontSize: 40),),
                                                )
                                            )
                                        ),
                                      ],
                                    )
                                  ],
                                )
                            );
                          },
                        )
                      ],
                    );

                }
              },
            )

        )
    );
  }


}
