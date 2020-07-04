import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class PinTester extends StatefulWidget {
  final String wallet;
  final Function callBackAction;
  PinTester({this.wallet,this.callBackAction});
  @override
  _PinTesterState createState() => new _PinTesterState();
}

class _PinTesterState extends State<PinTester> {

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final pin = TextEditingController();
  bool isChecking;
  bool isWrong;

  void initState() {
    isChecking=false;
    isWrong=false;
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
                      child: !isChecking?Column(
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
                          if(isWrong)
                          Container(
                            color:Colors.grey.withOpacity(0.2),
                            child: Row(
                              children: [
                                Expanded(

                                    child: Container(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text('Incorrect PIN',style: TextStyle(color: Colors.red),),))
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
                                    hintText: 'Enter PIN to Proceed',
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
                                    //errorStyle: TextStyle(color: PRIMARYCOLOR,),
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
                                )
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
                                      child: Center(child: Text('Submit',style: TextStyle(color: Colors.white),),),
                                      onPressed: ()async{
                                        if(_formKey.currentState.validate()){
                                          setState(() {isChecking = true;});
                                          bool pinTest = await PinRepo.fetchPin(pin.text, widget.wallet);
                                          if(!pinTest){
                                            setState(() {isChecking = false;isWrong=true;});
                                          }
                                          else{
                                            if(widget.callBackAction != null)
                                                {
                                                  setState(() {isChecking = false;isWrong=true;});
                                                  Get.back();
                                                  widget.callBackAction();
                                                }
                                            else
                                              Get.back();
                                          }
                                        }
                                      },
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ):Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            Center(child: Text('Verifying PIN.. Please wait'),)
                          ],
                        )
                      )
                  ),
                )
              ],
            )

        )
    );
  }


}
