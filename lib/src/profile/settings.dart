import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/Bank/BankSetter.dart';
import 'package:pocketshopping/src/pin/repository/pinRepo.dart';
import 'package:pocketshopping/src/profile/pinChanger.dart';
import 'package:pocketshopping/src/profile/pinSetter.dart';
import 'package:pocketshopping/src/profile/pinTester.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';

class Settings extends StatefulWidget {
  final User user;
  Settings({this.user});
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {

  bool isPinSet;
  void initState() {

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
                                            Get.dialog(PinTester(wallet: widget.user.walletId,));
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
                ]
            ).toList(),

        )
    );
  }


}
