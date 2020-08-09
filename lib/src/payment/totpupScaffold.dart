
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/wallet/repository/walletObj.dart';

class TopUpScaffold extends StatelessWidget{

  final User user;
  final Function atm;
  final Function personal;
  final Function business;
  final Function delivery;
  final Wallet wallet;
  TopUpScaffold({this.user,this.atm,this.personal,this.business,this.wallet,this.delivery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text('TopUp with',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),),
                ),
                Container(
                  child: ListTile(
                    onTap: (){atm();},
                    leading: CircleAvatar(
                      child:  Image.asset('assets/images/atm.png'),
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                    title:  Text(
                      'ATM Card',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.025),
                    ),
                    subtitle: Column(
                      children: <Widget>[

                        Text(
                            'Choose this if you want to Topup with an ATM Card.')

                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  child: ListTile(
                    enabled: wallet.walletBalance>0,
                    onTap: (){personal();},
                    leading: CircleAvatar(
                      child:  Image.asset('assets/images/blogo.png'),
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                    title:  Text(
                      'Personal Pocket',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.025),
                    ),
                    subtitle: Column(
                      children: <Widget>[

                        Text('Choose this if you want to Topup from your personal pocket.'),
                        Row(
                          children: [
                            Expanded(
                              child: wallet.walletBalance>0?
                              Text('Balance: $CURRENCY${wallet.walletBalance}',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),)
                                  :
                              Text('Insufficient Balance.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                            )
                          ],
                        )

                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                if(user.role == 'admin')
                Container(
                  child: ListTile(
                    enabled: wallet.merchantBalance>0,
                    onTap: (){business();},
                    leading: CircleAvatar(
                      child:  Image.asset('assets/images/blogo.png'),
                      radius: 30,
                      backgroundColor: Colors.white,
                    ),
                    title:  Text(
                      'Business Pocket',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.025),
                    ),
                    subtitle: Column(
                      children: <Widget>[

                        Text('Choose this if you want to Topup from your business account.'),
                        Row(
                          children: [
                            Expanded(
                              child: wallet.merchantBalance >0?
                              Text('Balance: $CURRENCY${wallet.merchantBalance}',
                                style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),)
                                  :
                              Text('Insufficient Balance.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                            )
                          ],
                        )

                      ],
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),

                if(user.role == 'admin')
                  Container(
                    child: ListTile(
                      enabled: wallet.deliveryBalance>0,
                      onTap: (){delivery();},
                      leading: CircleAvatar(
                        child:  Image.asset('assets/images/blogo.png'),
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      title:  Text(
                        'Delivery Pocket',
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.025),
                      ),
                      subtitle: Column(
                        children: <Widget>[

                          Text('Choose this if you want to Topup from your delivery account.'),
                          Row(
                            children: [
                              Expanded(
                                child: wallet.deliveryBalance>0?
                                Text('Balance: $CURRENCY${wallet.deliveryBalance}',
                                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.green),)
                                    :
                                Text('Insufficient Balance.',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                              )
                            ],
                          )

                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.arrow_forward_ios),
                      ),
                    ),
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),

                Center(
                    child: FlatButton(
                      onPressed: (){
                        Get.back();
                      },
                      child: Text('Close',style: TextStyle(color: Colors.white),),
                    )
                )
              ],
            )
        )
    );
  }
}