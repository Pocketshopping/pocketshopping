import 'package:avatar_glow/avatar_glow.dart';
import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/src/promo/bloc/promoBloc.dart';
import 'package:pocketshopping/src/promo/repository/promoObj.dart';
import 'package:pocketshopping/src/promo/repository/promoRepo.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';

class BonusDrawerIcon extends StatelessWidget {
  BonusDrawerIcon({@required this.wallet,this.openDrawer});

  final String wallet;
  final Function openDrawer;
  


  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: PromoBloc.instance.promoStream,
      builder: (_,AsyncSnapshot<bool>reload){
        return FutureBuilder(
          future: PromoRepo.getBonus(wallet),
          builder: (c,AsyncSnapshot<List<Bonus>>snapshot){
            if(snapshot.connectionState == ConnectionState.waiting)
            {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: PRIMARYCOLOR,
                  size: marginLR * 0.08,
                ),
                onPressed: () {
                  openDrawer();
                },
              );
            }
            else if(snapshot.hasError){
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: PRIMARYCOLOR,
                  size: marginLR * 0.08,
                ),
                onPressed: () {
                  openDrawer();
                },
              );
            }
            else{
              if(snapshot.data.isNotEmpty){

                return AvatarGlow(
                  startDelay: Duration(
                      milliseconds: 1000),
                  glowColor: Colors.red,
                  endRadius: 40.0,
                  duration: Duration(
                      milliseconds: 2000),
                  repeat: true,
                  showTwoGlows: true,
                  repeatPauseDuration:
                  Duration(
                      milliseconds: 100),
                  child: Material(
                    elevation: 0.0,
                    shape: CircleBorder(),
                    child: Badge(
                      position: BadgePosition
                          .topRight(
                          top: 1,
                          right: 1),
                      child: IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: PRIMARYCOLOR,
                          size: marginLR * 0.08,
                        ),
                        onPressed: () {
                          openDrawer();

                        },
                      ),
                      showBadge: true,
                      animationDuration:
                      Duration(
                          seconds: 5),
                    ),
                  ),
                  shape: BoxShape.circle,
                  animate: true,
                  curve: Curves.fastOutSlowIn,
                );
              }
              else{
                //print('eew wq ${snapshot.data}');
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: PRIMARYCOLOR,
                    size: marginLR * 0.08,
                  ),
                  onPressed: () {
                    openDrawer();
                  },
                );
              }
            }
          },
        );
      },
    );
  }
}
