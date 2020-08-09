import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loadmore/loadmore.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/pocketPay/repository/pocketHistory.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:recase/recase.dart';


class PocketHistoryWidget extends StatefulWidget {
  final Session user;
  PocketHistoryWidget({this.user});
  @override
  _PocketHistoryState createState() => new _PocketHistoryState();
}

class _PocketHistoryState extends State<PocketHistoryWidget> {
  int get count => list.length;

  List<PocketHistory> list = [];
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
    Utility.pocketHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString(),type: isSelected[0]?'credit':'debit').then((value){
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
    Utility.pocketHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString(),type: isSelected[0]?'credit':'debit').then((value){
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.15), // here the desired height
          child: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            centerTitle: true,
            bottom: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: ToggleButtons(
                    borderColor: Colors.blue.withOpacity(0.5),
                    fillColor: Colors.blue,
                    borderWidth: 1,
                    selectedBorderColor: Colors.blue,
                    selectedColor: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Credit',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          'Debit',
                        ),
                      ),
                    ],
                    onPressed: (int index) async {
                      for (int i = 0; i < isSelected.length; i++) {
                        isSelected[i] = i == index;
                      }
                      loading =true;
                      setState(() {});
                      var result = await Utility.pocketHistory(pocket: widget.user.user.walletId,
                          pNumber: page,from: from.toString(),to: to.toString(),type: index == 0 ?'credit':'debit');
                      list=result;
                      loading =false;
                      _finish=result.length == 20?false:true;
                      empty = result.isEmpty;
                      setState(() {});
                    },
                    isSelected: isSelected,
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width*0.35,
                        minWidth: MediaQuery.of(context).size.width*0.35),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: FlatButton.icon(
                            onPressed: (){
                              Get.dialog(
                                  Scaffold(
                                    backgroundColor: Colors.black.withOpacity(0.4),
                                    body: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 200,
                                                child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode.date,
                                                  initialDateTime: to,
                                                  onDateTimeChanged: (DateTime newDateTime) {
                                                    to = newDateTime;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FlatButton(
                                                onPressed: ()async{
                                                  Get.back();
                                                  loading =true;
                                                  setState(() {});
                                                  var result = await Utility.pocketHistory(pocket: widget.user.user.walletId,
                                                      pNumber: page,from: from.toString(),to: to.toString(),type: isSelected[0]?'credit':'debit');
                                                  list=result;
                                                  loading =false;
                                                  _finish=result.length == 20?false:true;
                                                  empty = result.isEmpty;
                                                  setState(() {});
                                                },
                                                color: PRIMARYCOLOR,
                                                child: Text('Ok',style: TextStyle(color: Colors.white),),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                              );
                            },
                            icon: Icon(Icons.calendar_today),
                            label: Text('${to.day} ${Utility.getMonth(to)}, ${to.year}'))
                    ),
                    Expanded(
                        child: FlatButton.icon(
                            onPressed: (){
                              Get.dialog(
                                  Scaffold(
                                    backgroundColor: Colors.black.withOpacity(0.4),
                                    body: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          color: Colors.white,
                                          margin: EdgeInsets.symmetric(horizontal: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                height: 200,
                                                child: CupertinoDatePicker(
                                                  mode: CupertinoDatePickerMode.date,
                                                  initialDateTime: from,
                                                  onDateTimeChanged: (DateTime newDateTime) {
                                                    // Do something
                                                    from = newDateTime;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: FlatButton(
                                                onPressed: ()async{
                                                  Get.back();
                                                  loading =true;
                                                  setState(() {});
                                                  var result = await Utility.pocketHistory(pocket: widget.user.user.walletId,
                                                      pNumber: page,from: from.toString(),to: to.toString(),type: isSelected[0]?'credit':'debit');
                                                  list=result;
                                                  loading =false;
                                                  _finish=result.length == 20?false:true;
                                                  empty = result.isEmpty;
                                                  setState(() {});
                                                },
                                                color: PRIMARYCOLOR,
                                                child: Text('Ok',style: TextStyle(color: Colors.white),),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                              );
                            },
                            icon: Icon(Icons.calendar_today),
                            label: Text('${from.day} ${Utility.getMonth(from)}, ${from.year}'))
                    ),
                  ],
                )
              ],
            ),
            ),
            automaticallyImplyLeading: false,
          ),
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
                          return list[index].amount>0?SingleHistory(history: list[index],user: widget.user,isCredit: isSelected[0],):const SizedBox.shrink();
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
                            return 'Error';
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
    var result = await Utility.pocketHistory(pocket: widget.user.user.walletId,
        pNumber: page,from: from.toString(),to: to.toString(),type: isSelected[0]?'credit':'debit');
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
  final bool isCredit;
  SingleHistory({this.history,this.user,this.isCredit});

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
            title: isCredit?history.channelId == 3?
            Text("You recieved $CURRENCY${history.amount.round()} for business transaction", style: TextStyle(fontWeight: FontWeight.bold),)
            :
            history.channelId == 4?
            Text("You recieved a ${history.channelType.sentenceCase} of $CURRENCY${history.amount.round()}", style: TextStyle(fontWeight: FontWeight.bold),)
            :
            Text("${history.channelType.sentenceCase} $CURRENCY${history.amount.round()}", style: TextStyle(fontWeight: FontWeight.bold),)
            :history.channelId == 3?
            Text("You paid $CURRENCY${history.amount.round()} for business transaction", style: TextStyle(fontWeight: FontWeight.bold),)
                :
            history.channelId == 4?
            Text("You made a ${history.channelType.sentenceCase} of $CURRENCY${history.amount.round()}", style: TextStyle(fontWeight: FontWeight.bold),)
                :
            Text("${history.channelType.sentenceCase} $CURRENCY${history.amount.round()}", style: TextStyle(fontWeight: FontWeight.bold),),
            subtitle:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if(isCredit)
                  if(history.channelId == 3)
                    FutureBuilder(
                      future:MerchantRepo.getMerchantByWallet(history.from),
                      builder: (c,AsyncSnapshot<Merchant> merchant){
                        return merchant.hasData && user.merchant != null?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("From: ${user.merchant.bName}"),
                            )

                          ],
                        ):const SizedBox.shrink();
                      },
                    )
                    else
                      FutureBuilder(
                        future:UserRepo.getUserUsingWallet(history.from) ,
                        builder: (c,AsyncSnapshot<User> user){
                          return user.hasData && user.data != null?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Text("From: ${user.data.fname}"),
                              )

                            ],
                          ):const SizedBox.shrink();
                        },
                      ),
                if(!isCredit)
                  if(history.channelId == 3)
                    FutureBuilder(
                      future:MerchantRepo.getMerchantByWallet(history.to),
                      builder: (c,AsyncSnapshot<Merchant> merchant){
                        return merchant.hasData && user.merchant != null?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("${user.merchant.bName}"),
                            )

                          ],
                        ):const SizedBox.shrink();
                      },
                    )
                  else
                    FutureBuilder(
                      future:UserRepo.getUserUsingWallet(history.to) ,
                      builder: (c,AsyncSnapshot<User> user){
                        return user.hasData && user.data != null?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Text("To: ${user.data.fname}"),
                            )

                          ],
                        ):const SizedBox.shrink();
                      },
                    ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text("${Utility.presentDate(history.createdDate)}"),
                    )

                  ],
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



