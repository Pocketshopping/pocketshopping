import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/pocketPay/repository/pocketHistory.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:recase/recase.dart';


class UnitHistory extends StatefulWidget {
  final Session user;
  UnitHistory({this.user});
  @override
  _UnitHistoryState createState() => new _UnitHistoryState();
}

class _UnitHistoryState extends State<UnitHistory> {
  int get count => list.length;

  List<PocketHistory> list = [];
  bool _finish;
  bool loading;
  bool empty;
  String from;
  String to;
  DateTime thirtyDays;
  int page;

  void initState() {
    page = 1;
    thirtyDays = DateTime.now().subtract(Duration(days: 30));
    from = "${thirtyDays.month}-${thirtyDays.day}-${thirtyDays.year} 00:00:00";
    to = "${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().year} 23:59:59";
    _finish = true;
    loading =true;
    empty = false;
    Utility.unitHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString()).then((value){
      list=value;
      loading =false;
      _finish=value.length == 20?false:true;
      empty = value.isEmpty;
      if(mounted)
        setState((){ });
    });
    super.initState();
  }

  void load() {
    page += 1;
    Utility.unitHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString()).then((value){
      list.addAll(value);
      loading =false;
      _finish=value.length == 20?false:true;
      empty = value.isEmpty;
      if(mounted)
        setState((){ });
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          elevation: 0.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text('Unit Purchase History',style: TextStyle(color: PRIMARYCOLOR),),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
                flex:3,
                child: !loading?
                !empty?
                Container(
                  child: RefreshIndicator(
                    child: LoadMore(
                      isFinish: _finish,
                      onLoadMore: _loadMore,
                      child: ListView.builder(
                        itemBuilder: (BuildContext context, int index) {
                          return SingleHistory(history: list[index],user: widget.user,);
                        },
                        itemCount: count,
                      ),
                      whenEmptyLoad: false,
                      delegate: DefaultLoadMoreDelegate(),
                      textBuilder: (l){
                        switch(l){
                          case LoadMoreStatus.nomore:
                            return '';
                            break;
                          case LoadMoreStatus.loading:
                            return 'Loading.. please wait';
                            break;
                          case LoadMoreStatus.fail:
                            return '';
                            break;
                          default:
                            return 'Loading.. please wait';
                            break;
                        }
                      },
                    ),
                    onRefresh: _refresh,
                  ),
                ):
                ListTile(
                  title: Image.asset('assets/images/empty.gif'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "No History",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )
                    :
                Center(
                  child: JumpingDotsProgressIndicator(
                    fontSize: Get.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            ),
          ],
        )
    );
  }

  Future<bool> _loadMore() async {
    await Future.delayed(Duration(seconds: 0, milliseconds: 2000));
    load();
    return list.length%10 == 0 ?true:false;
  }

  Future<void> _refresh() async {
    loading =true;
    setState(() {});
    var result = await Utility.unitHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString());
    list=result;
    loading =false;
    _finish=result.length == 20?false:true;
    empty = result.isEmpty;
    setState(() {});
  }
}

class SingleHistory extends StatelessWidget {
  final PocketHistory history;
  final Session user;
  SingleHistory({this.history,this.user});

  @override
  Widget build(BuildContext context) {
    //return Text('${(_start/60).round()}');
    return Column(
        children:[
          SizedBox(height: 10,),
          ListTile(
            onTap: () {


            },
            leading:CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.white,
              child: Center(child: history.status == 'success'?Icon(Icons.check,color: Colors.green,):Icon(Icons.close,color: Colors.red,),),
            ),
            title: history.channelId == 4?Text("You recieved a ${history.channelType.sentenceCase} of ${history.amount.round()} Units",
              style: TextStyle(fontWeight: FontWeight.bold),
            ):Text("You bought  ${history.amount.round()} Units",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text("${Utility.presentDate(history.createdDate)}"),
                    )

                  ],
                ),
                if(history.channelId == 4 )
                  FutureBuilder(
                    future: UserRepo.getUserUsingWallet(history.from),
                    builder: (context,AsyncSnapshot<User>user){
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: user.hasData && user.data != null?Text("From: ${user.data.fname}"):const SizedBox.shrink(),
                          )
                        ],
                      );
                    },
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text("${history.paymentTypeDesc.sentenceCase}"),
                    )
                  ],
                ),
              ],
            ),
          ),
          Divider(),
        ]
    );
  }
}



