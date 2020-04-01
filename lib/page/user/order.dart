import 'package:flutter/material.dart';
import 'package:pocketshopping/util/data.dart';
import 'package:pocketshopping/page/user/orderTab.dart';
import 'package:badges/badges.dart';


class OrderWidget extends StatefulWidget {
  //static String tag = 'User-page';
  OrderWidget(this._session,this.themeColor);
  final session _session;
  final Color themeColor;
  @override
  _OrderWidgetState createState() => new _OrderWidgetState(_session,themeColor);
}
  class _OrderWidgetState  extends State<OrderWidget> {
    _OrderWidgetState(this._session,this.themeColor);
    final session _session;
    final Color themeColor;

    @override
    Widget build(BuildContext context) {
      return Scaffold(
          body: Container(
              child: CustomScrollView(
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: MyDynamicHeader(
                        session_: _session,
                        themeColor: themeColor,
                      maxHeight: MediaQuery.of(context).size.height*0.1,
                      minHeight: MediaQuery.of(context).size.height*0.1,

                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height,
                            child: TopTabBar(themeColor),
                          ),
                        ],
                      )
                  ),
                ],
              )
          )
      );
    }
  }

class MyDynamicHeader extends SliverPersistentHeaderDelegate {
  int index = 0;
  MyDynamicHeader({
    this.session_,
    this.themeColor,
    this.maxHeight=150,
    this.minHeight=100,
  });

  final session session_;
  final Color themeColor;
  final double maxHeight;
  final double minHeight;


  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return LayoutBuilder(
        builder: (context, constraints) {
          if (++index > Colors.primaries.length-1)
            index = 0;

          return Container(
            decoration: BoxDecoration(
              //boxShadow: [BoxShadow(blurRadius: 4.0, color: Colors.black45)],
              color: themeColor,
            ),
            height: constraints.maxHeight,
            child: SafeArea(
                child: Center(
                    child: Image.asset('assets/images/wlogo.png',
                      height: MediaQuery.of(context).size.height*0.08,
                      width: MediaQuery.of(context).size.width*0.5,
                      fit: BoxFit.contain,),
                )
            ),
          );
        }
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;
}
