import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:timeline_node/timeline_node.dart';

class TrackerTimeLineObject{
  final TimelineNodeStyle style;
  final String message;
  TrackerTimeLineObject({this.style,this.message});
}


class OrderTrackerWidget extends StatefulWidget{
  OrderTrackerWidget({this.merchant,this.user,this.cPosition});
  final Merchant merchant;
  final GeoFirePoint cPosition;
  final User user;
  @override
  State<StatefulWidget> createState() => _OrderTrackerWidgetState();
}
class _OrderTrackerWidgetState extends State<OrderTrackerWidget> {
  int _start;
  String counter;
  Timer _timer;


  @override
  void initState() {
    _start=500;
    counter='00:00';
    startTimer();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopScope,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            elevation: 0.0,
            centerTitle: true,
            backgroundColor: Color.fromRGBO(255, 255, 255, 1),
            leading: IconButton(

              icon: Icon(Icons.arrow_back_ios,color:Colors.grey,
              ),
              onPressed: (){
                int count = 0;
                Navigator.popUntil(context, (route) {
                  return count++ == 2;
                });
              },
            ) ,
            title:Text('Tracker',style: TextStyle(color: PRIMARYCOLOR),),

            automaticallyImplyLeading: false,
          ),

        body: Center(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                    child: Text('Status: Processing',style: TextStyle(fontSize: 20),),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.3,
                  height: MediaQuery.of(context).size.height*0.18,
                  child: CircularStepProgressIndicator(
                    totalSteps: 500,
                    currentStep: _start,
                    stepSize: 10,
                    selectedColor: PRIMARYCOLOR,
                    unselectedColor: Colors.grey[200],
                    padding: 0,
                    width: 150,
                    height: 150,
                    selectedStepSize: 15,
                    child: Center(
                      child: Text('$counter to Delivery',textAlign: TextAlign.center,),
                    ),
                  )
                ),
          false?
          psHeadlessCard(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: Column(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide( //                   <--- left side
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      ),
                    ),
                    height: MediaQuery.of(context).size.height*0.3,
                    padding: EdgeInsets.all(MediaQuery
                        .of(context)
                        .size
                        .width * 0.02),
                    child:  timelineMaker()
                ),
                ]
            )
          ):Container(),
                psHeadlessCard(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      //offset: Offset(1.0, 0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide( //                   <--- left side
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.all(MediaQuery
                            .of(context)
                            .size
                            .width * 0.02),
                        child:  Row(
                          children: <Widget>[
                            Expanded(
                              child: Text('OrderId:'),
                            ),
                            Expanded(
                              child: Text('test2'),
                            )
                          ],
                        )
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide( //                   <--- left side
                                color: Colors.black12,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(MediaQuery
                              .of(context)
                              .size
                              .width * 0.02),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Text('test1'),
                              ),
                              Expanded(
                                child: Text('test2'),
                              )
                            ],
                          )
                      ),
                      Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide( //                   <--- left side
                                color: Colors.black12,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.all(MediaQuery
                              .of(context)
                              .size
                              .width * 0.02),
                          child:  Row(
                            children: <Widget>[
                              Expanded(
                                child: Text('test1'),
                              ),
                              Expanded(
                                child: Text('test2'),
                              )
                            ],
                          )
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopScope()async{
    return false;
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
            countDownFormater(_start);
          }
        },
      ),
    );
  }

  void countDownFormater(int sec){
    int minute=0;
    int second=0;

    minute = (sec/60).round();
    second = sec%60;
    if(minute>0)
    setState(() {
      counter='$minute min';
    });
    else
      setState(() {
        counter='$_start sec';
      });
  }

  Widget timelineMaker(){
    List<TrackerTimeLineObject> timeline=[];
    timeline.addAll([
      TrackerTimeLineObject(
          message: 'Order created at ${DateTime.now().toString()}',
          style: TimelineNodeStyle(
              type: TimelineNodeType.Left,
              lineType: TimelineNodeLineType.Full,
          )
      ),
      TrackerTimeLineObject(
          message: 'Hsi icsuds sdcsd',
          style: TimelineNodeStyle(
              type: TimelineNodeType.Left,
              lineType: TimelineNodeLineType.Full,
          )
      ),
      TrackerTimeLineObject(
        message: 'Hsi icsuds sdcsd',
        style: TimelineNodeStyle(
          type: TimelineNodeType.Left,
          lineType: TimelineNodeLineType.Full,
        )
      )
    ]);
    return ListView.builder(
      itemCount: timeline.length,
        itemBuilder: (context,index){
        return TimelineNode(
          style: timeline[index].style,
          indicator: SizedBox(
            width: 10,
            height: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                color: PRIMARYCOLOR,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(timeline[index].message),
          ),
        );
        });
  }

}