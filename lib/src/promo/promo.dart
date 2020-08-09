import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/promo/bloc/promoBloc.dart';
import 'package:pocketshopping/src/promo/repository/promoObj.dart';
import 'package:pocketshopping/src/promo/repository/promoRepo.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/shared/shared.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class Promo extends StatelessWidget {
  Promo({@required this.wallet,});

  final String wallet;
  final loading = ValueNotifier<bool>(false);




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            'Gift',
            style: TextStyle(color: PRIMARYCOLOR),
          ),
          automaticallyImplyLeading: false,
        ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(height: 50,),
          ValueListenableBuilder(
            valueListenable: loading,
            builder: (_,bool load,__){
              return FutureBuilder(
                future: PromoRepo.getBonus(wallet),
                builder: (c,AsyncSnapshot<List<Bonus>>snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting)
                  {
                    return Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: MediaQuery.of(context).size.height * 0.12,
                          color: PRIMARYCOLOR,
                        ));
                  }
                  else if(snapshot.hasError){
                    return Center(
                        child: Text('Error communicating with server check internet connection and try again.'));
                  }
                  else{
                    if(snapshot.data.isNotEmpty){

                      return Column(
                        children: List<Widget>.generate(snapshot.data.length, (index) {
                          return psHeadlessCard(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  //offset: Offset(1.0, 0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              child:Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        child: Image.asset('assets/images/gift.jpg',),
                                      ),
                                      Container(
                                        color: Colors.white.withOpacity(0.8),
                                        height: MediaQuery.of(context).size.height * 0.3,
                                        width: MediaQuery.of(context).size.width * 0.8,
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('${snapshot.data[index].bonus}',style: TextStyle(color: Colors.black,fontSize: 20),),
                                          )
                                        ),
                                      ),
                                    ],
                                  ),
                                  if(!load)
                                  Container(
                                      color: Color.fromRGBO(255, 26, 33, 1),
                                      child: Center(
                                        child: FlatButton(
                                          onPressed: ()async{
                                            loading.value = true;
                                            bool result=false;
                                            Utility.bottomProgressLoader(title: 'Claim',body: 'Claiming gift....please wait');
                                            bool claimed = await Utility.claimGift(snapshot.data[index].recipient, snapshot.data[index].amount);
                                            if(claimed)result = await PromoRepo.claimBonus(snapshot.data[index].id);
                                            Get.back();
                                            if(result){
                                              Get.back();
                                              await Future.delayed(Duration(seconds: 1));
                                              Utility.bottomProgressSuccess(title: 'Gift',body: 'Your pocket has been credited with the gifted amount. Thank you',duration: 5);
                                              WalletRepo.getWallet(snapshot.data[index].recipient).then((value) => WalletBloc.instance.newWallet(value));
                                              PromoBloc.instance.reload(true);
                                            }
                                            else{
                                              Get.back();
                                              Utility.bottomProgressFailure(title: 'Gift',body: 'Error claiming gift check Internet and try again');
                                              //await Future.delayed(Duration(seconds: 1));

                                            }

                                          },
                                          color: Color.fromRGBO(255, 26, 33, 1),
                                          child: Text('Claim($CURRENCY${snapshot.data[index].amount})',style: TextStyle(color: Colors.white),),
                                        ),
                                      )
                                  )
                                ],
                              ));
                        }),
                      );
                    }
                    else{
                      return Center(
                        child: ListTile(
                          title: Image.asset('assets/images/empty.gif'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  'Empty',
                                  style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.height * 0.06),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        "No Free Gift",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                      );
                    }
                  }
                },
              );
            },
          )
        ],
      )
    );
  }
}
