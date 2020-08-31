import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class PinSetter extends StatefulWidget {
  final User user;
  final Function callBackAction;
  PinSetter({this.user,this.callBackAction});
  @override
  _PinSetterState createState() => new _PinSetterState();
}

class _PinSetterState extends State<PinSetter> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pin = TextEditingController();
  final cPin = TextEditingController();

  final first = FocusNode();
  final second = FocusNode();
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

                                child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('Setup 4 Digit Pocket PIN'),))
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Enter 4 Digit PIN';
                                }
                                return null;
                              },
                              showCursor: true,
                              readOnly: true,
                              focusNode: first,
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
                                if (value != pin.text) {
                                  return 'PIN and Confirm PIN do not match';
                                }
                                return null;
                              },
                              showCursor: true,
                              readOnly: true,
                              focusNode: second,
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
                                stage.value = 1;
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
                                    Utility.bottomProgressLoader(title: '',body: 'SettingUp Pocket PIN...please wait');
                                    bool result = await PinRepo.save(Pin(pin: pin.text), widget.user.walletId);
                                    Get.back();
                                    if(result){
                                      if(widget.callBackAction != null)widget.callBackAction();
                                      Utility.bottomProgressSuccess(title: '',body: 'Pocket PIN Setup complete');
                                    }
                                    else
                                      Utility.bottomProgressFailure(title: '',body: 'Error Setting PIN...Try again');
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
                                        else{
                                          FocusScope.of(context).requestFocus(FocusNode());
                                          if(_formKey.currentState.validate()){
                                            Get.back();
                                            Utility.bottomProgressLoader(title: 'Pocket PIN',body: 'SettingUp 4-Digit Pocket PIN...please wait');
                                            bool result = await PinRepo.save(Pin(pin: pin.text), widget.user.walletId);
                                            Get.back();
                                            if(result){
                                              if(widget.callBackAction != null)widget.callBackAction();
                                              Utility.bottomProgressSuccess(title: 'Pocket PIN',body: '4-Digit Pocket PIN Setup complete',goBack: true);
                                            }
                                            else
                                              Utility.bottomProgressFailure(title: 'Pocket PIN',body: 'Error Setting 4-Digit PIN...Try again');
                                          }
                                        }

                                      },
                                      child: Center(
                                        child: Text(_stage == 1?'Ok':'Next',style: TextStyle(color: Colors.white,fontSize: 40),),
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
          )

        )
    );
  }


}
