import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/Bank/BankSetter.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinChanger.dart';
import 'package:pocketshopping/src/profile/pinResetter.dart';
import 'package:pocketshopping/src/profile/pinSetter.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/server/bloc/serverBloc.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/validators.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:recase/recase.dart';

class Settings extends StatefulWidget {
  final User user;
  final UserRepository userRepository;
  Settings({this.user,this.userRepository});
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {

  final key = ValueNotifier<String>('');
  Stream<Map<String,dynamic>> _serverStream;
  bool isPinSet;
  final email = TextEditingController();
  final  _formKey = GlobalKey<FormState>();
  void initState() {
    _serverStream = ServerBloc.instance.serverStream;
    _serverStream.listen((event) {
      key.value = event['key'];
    });
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.1), // here the desired height
          child: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: PRIMARYCOLOR,
              ),
              onPressed: () {
                //print("your menu action here");
                Get.back();
              },
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              "Settings",
              style: TextStyle(color: Colors.black),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: ListView(
          children:
            ListTile.divideTiles(
                context: context,
                tiles: [
                  FutureBuilder<bool>(
                    future: PinRepo.isSet(widget.user.walletId),
                    builder: (context,AsyncSnapshot<bool> isSet){
                      if(isSet.hasError){return const SizedBox.shrink();}
                      if(isSet.hasData){
                        return ListTile(
                          onTap: (){
                            Get.bottomSheet(builder: (context){
                              return  Column(
                                mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(!isSet.data)
                                    Container(
                                      color: Colors.white,
                                      child: ListTile(

                                        title: Text('Set Pocket PIN'),
                                        subtitle: Text('Set new pocket PIN'),
                                        trailing: Icon(Icons.arrow_forward_ios),
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.grey[200],
                                          child: Center(
                                            child: Text('PIN',style: TextStyle(color: Colors.black54),),

                                          ),
                                          radius: 25,

                                        ),
                                        onTap: ()async{
                                          Get.back();
                                          Get.dialog(PinSetter(user: widget.user,));
                                        },
                                      ),
                                    ),
                                    if(!isSet.data)
                                      Container(
                                        color: Colors.white,
                                        child: const Divider(),
                                    ),
                                    if(isSet.data)
                                      Container(
                                        color: Colors.white,
                                        child:
                                    ListTile(
                                      onTap:(){
                                        Get.back();
                                        Get.dialog(PinChanger(user: widget.user,));
                                      },
                                      title: Text('Change Pocket PIN'),
                                      subtitle: Text('change pocket PIN'),
                                      trailing: Icon(Icons.arrow_forward_ios),
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.grey[200],
                                        child: Center(
                                          child: Text('PIN',style: TextStyle(color: Colors.black54),),

                                        ),
                                        radius: 25,
                                      ),
                                    ),
                                    ),
                                    if(isSet.data)
                                      Container(
                                        color: Colors.white,
                                        child:
                                        ListTile(
                                          onTap:(){
                                            Get.back();
                                            Get.dialog(PinResetter(user: widget.user,));
                                          },
                                          title: Text('Reset Pocket PIN'),
                                          subtitle: Text('Click to reset pocket PIN'),
                                          trailing: Icon(Icons.arrow_forward_ios),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: Center(
                                              child: Text('PIN',style: TextStyle(color: Colors.black54),),

                                            ),
                                            radius: 25,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                            }).then((value) => null);
                          },
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.grey[200],
                            child: Center(child: Icon(Icons.vpn_key),),
                          ),
                          title: Text("Pocket PIN",style: TextStyle(fontSize: 20),),
                          subtitle: Text(isSet.data?"change pocket pin":"set pocket pin"),
                          trailing: Icon(Icons.arrow_forward_ios),
                        );
                      }
                      else{
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  if(widget.user.role == 'admin')
                    FutureBuilder<Wallet>(
                      future: WalletRepo.getWallet(widget.user.walletId),
                      builder: (context,AsyncSnapshot<Wallet> wallet){
                        if(wallet.hasError){return const SizedBox.shrink();}
                        if(wallet.hasData){
                          return ListTile(
                            onTap: (){
                              Get.bottomSheet(builder: (context){
                                return  Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if(wallet.data.accountNumber.isEmpty)
                                      Container(
                                        color: Colors.white,
                                        child: ListTile(

                                          title: Text('Set Bank Account'),
                                          subtitle: Text('Set up Bank Account for withdrawal'),
                                          trailing: Icon(Icons.arrow_forward_ios),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: Center(
                                              child: Text('BANK',style: TextStyle(color: Colors.black54),),

                                            ),
                                            radius: 25,

                                          ),
                                          onTap: ()async{
                                            Get.back();
                                            Get.dialog(BankSetter(wallet: widget.user.walletId,)).then((value) {
                                              setState(() {

                                              });
                                            });
                                          },
                                        ),
                                      ),
                                    if(wallet.data.accountNumber.isEmpty)
                                      Container(
                                        color: Colors.white,
                                        child: const Divider(),
                                      ),
                                    if(wallet.data.accountNumber.isNotEmpty)
                                      Container(
                                        color: Colors.white,
                                        child:
                                        ListTile(
                                          onTap: ()async{
                                            Get.back();
                                            Get.dialog(BankSetter(wallet: widget.user.walletId,)).then((value) {
                                              setState(() {

                                              });
                                            });
                                          },
                                          title: Text('Change Bank Account'),
                                          subtitle: Text('change Bank Account'),
                                          trailing: Icon(Icons.arrow_forward_ios),
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.grey[200],
                                            child: Center(
                                              child: Text('BANK',style: TextStyle(color: Colors.black54),),

                                            ),
                                            radius: 25,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }).then((value) => null);
                            },
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.grey[200],
                              child: Center(child: Icon(AntIcons.bank_outline),),
                            ),
                            title: Text("Bank(${wallet.data.accountNumber})",style: TextStyle(fontSize: 20),),
                            subtitle: Text(wallet.data.accountNumber.isEmpty?"Set Bank account for withdrawal":"Change Bank account"),
                            trailing: Icon(Icons.arrow_forward_ios),
                          );
                        }
                        else{
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ListTile(
                    onTap: (){
                      email.text = widget.user.email;
                      Get.dialog(
                          Scaffold(
                              backgroundColor: Colors.black.withOpacity(0.2),
                              body: Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                    margin: EdgeInsets.symmetric(horizontal: 15),
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: Text('Password Reset',style: TextStyle(fontSize: 18),),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: IconButton(
                                                    onPressed: (){
                                                      Get.back();
                                                    },
                                                    icon: Icon(Icons.close),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Form(
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return 'Enter Email';
                                              }
                                              if(!Validators.isValidEmail(value)){
                                                return 'Invalid email address';
                                              }
                                              return null;
                                            },
                                            controller: email,
                                            decoration: InputDecoration(
                                              hintText: 'Email',
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
                                            autovalidate: true,
                                            autofocus: false,
                                            enabled: false,
                                            textInputAction: TextInputAction.done,
                                            keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {},
                                            style: TextStyle(fontSize: 18),

                                          ),
                                          key: _formKey,
                                        ),
                                        FlatButton(
                                            onPressed: ()async{
                                              if(_formKey.currentState.validate()){
                                                Get.back();
                                                if(email.text.isNotEmpty)
                                                {
                                                  if(Validators.isValidEmail(email.text))
                                                  {
                                                    Utility.bottomProgressLoader(title: 'Resetting Password',body: 'Please wait...'.sentenceCase);
                                                    var result =await  widget.userRepository.passwordReset(email.text);
                                                    if(result == 1)
                                                    {
                                                      Get.back();
                                                      Utility.bottomProgressSuccess(title: 'Password Reset',body: 'Check your mailbox for password reset link'.sentenceCase,duration: 5);
                                                    }
                                                    else if(result == 2)
                                                    {
                                                      Get.back();
                                                      Utility.bottomProgressFailure(title: 'User Not Found.', body: 'No User With this email'.sentenceCase,duration: 5);
                                                    }
                                                    else
                                                    {
                                                      Get.back();
                                                      Utility.bottomProgressFailure(title: 'Password Reset', body: 'Error resetting password, check your internet connection and try again'.sentenceCase,duration: 5);
                                                    }
                                                  }
                                                  else{
                                                    Utility.bottomProgressFailure(title: 'Email Address', body: 'Enter a Valid Email Address'.sentenceCase,duration: 3);
                                                  }
                                                }
                                                else
                                                {
                                                  Utility.bottomProgressFailure(title: 'Email Address', body: 'Enter Your Email Address'.sentenceCase,duration: 3);

                                                }
                                              }
                                            },
                                            color: PRIMARYCOLOR,
                                            child: Center(
                                              child: Text('Reset',style: TextStyle(color: Colors.white),),
                                            )
                                        ),
                                      ],
                                    ),
                                  )
                              )
                          )
                      );
                    },
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey[200],
                      child: Center(child: Icon(AntIcons.login),),
                    ),
                    title: Text("Change Password",style: TextStyle(fontSize: 20),),
                    subtitle: Text("click to change password"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  )
                ]
            ).toList(),

        )
    );
  }


}
