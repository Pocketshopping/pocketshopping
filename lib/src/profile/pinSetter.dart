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

  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54.withOpacity(0.3),
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                              style: TextStyle(fontSize: 30,letterSpacing: MediaQuery.of(context).size.width*0.2),
                              buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value != pin.text) {
                                  return 'PIN and Confirm PIN do not match';
                                }
                                return null;
                              },
                              controller: null,
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
                              style: TextStyle(fontSize: 30,letterSpacing: MediaQuery.of(context).size.width*0.2),
                              maxLength: 4,
                              maxLengthEnforced: true,
                              buildCounter: (BuildContext context, { int currentLength, int maxLength, bool isFocused }) => null,
                            ),
                          ],
                        ),
                      ),
                      Container(color:Colors.grey.withOpacity(0.2), height:20,),
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
