import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/pocketPay/repository/ticketObj.dart';
import 'package:pocketshopping/src/pocketPay/repository/ticketRepo.dart';
import 'package:pocketshopping/src/pocketPay/ticketForm.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';


class TicketWidget extends StatefulWidget {
  final Session user;
  TicketWidget({this.user});
  @override
  _TicketWidgetState createState() => new _TicketWidgetState();
}

class _TicketWidgetState extends State<TicketWidget> {
  int get count => list.length;

  List<Ticket> list = [];
  bool _finish;
  bool loading;
  bool empty;
  List<bool> isSelected;
  DateTime from;
  DateTime to;
  DateTime thirtyDays;
  int page;

  void initState() {
    page = 1;
    isSelected = [true, false];
    thirtyDays = DateTime.now().subtract(Duration(days: 30));
    from = DateTime(thirtyDays.year,thirtyDays.month,thirtyDays.day,00,00,00);
    to = DateTime.now();
    _finish = true;
    loading =true;
    empty = false;
    TicketRepo.ticketHistory(pocket: widget.user.user.walletId,pNumber: page).then((value){
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
    TicketRepo.ticketHistory(pocket: widget.user.user.walletId,pNumber: page).then((value){
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
          title: Text('Support',style: TextStyle(color: PRIMARYCOLOR),),
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
                    fontSize: MediaQuery.of(context).size.height * 0.12,
                    color: PRIMARYCOLOR,
                  ),
                )
            ),
            Expanded(
              flex: 0,
              child: FlatButton(
                onPressed: (){
                  Get.to(TicketFormWidget(user: widget.user,)).then((value) async{
                    await _refresh();
                  });
                },
                color: PRIMARYCOLOR,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Create Ticket',style: TextStyle(color: Colors.white),),),
                )
              ),
            )
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
    var result = await TicketRepo.ticketHistory(pocket: widget.user.user.walletId,pNumber: page);
    list=result;
    loading =false;
    _finish=result.length == 20?false:true;
    empty = result.isEmpty;
    setState(() {});
  }
}

class SingleHistory extends StatelessWidget {
  final Ticket history;
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
              child: Center(child: history.isResolved ?Icon(Icons.check,color: Colors.green,):Icon(Icons.access_time,color: Colors.orangeAccent,),),
            ),
            title: Text("${history.complain}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      flex: 0,
                      child:Text("${history.category}"),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("${Utility.presentDate(history.dateTime)}"),
                      ),
                    )

                  ],
                ),
                if(!history.isResolved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text("Active Ticket"),
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



