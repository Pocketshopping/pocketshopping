import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pin/repository/pinObj.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class PinChanger extends StatefulWidget {
  final User user;
  PinChanger({this.user});
  @override
  _PinChangerState createState() => new _PinChangerState();
}

class _PinChangerState extends State<PinChanger> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pin = TextEditingController();
  final oldPin = TextEditingController();

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

                                    child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Text('Pocket PIN'),))
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
                                  controller: oldPin,
                                  decoration: InputDecoration(
                                    hintText: 'Old PIN',
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
