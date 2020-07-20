
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/src/order/bloc/trackerBloc.dart';
import 'package:pocketshopping/src/utility/utility.dart';

class Counter extends StatefulWidget{
  Counter({this.total,this.start,this.id,});

  final int total;
  final int start;
  final String id;

  @override
  State<StatefulWidget> createState() => _CounterState();
}

class _CounterState extends State<Counter> {


  final _current = ValueNotifier<int>(0);
  final _total = ValueNotifier<int>(0);
  final _trackerData = ValueNotifier<Map<String,Timestamp>>({});
  Timer _timer;
  Stream<Map<String,Timestamp>> _trackerStream;
  @override
  void initState() {
    _current.value = widget.start;
    _total.value = widget.total;
    startTimer();

    _trackerStream = TrackerBloc.instance.trackerStream;
    _trackerStream.listen((dateTime) {

      if(_current.value == 0){
        _trackerData.value = dateTime;
        if(dateTime.containsKey('r${widget.id}')){
          _current.value = Utility.setStartCount(dateTime['r${widget.id}'], 120);
          _total.value = 120;
          startTimer();
        }

      }

    });
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _total,
        builder: (_,int total,__){
          return ValueListenableBuilder(
              valueListenable: _current,
              builder: (_, int current, __) {
                return  Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Text('${(current/60).round()}min',style: TextStyle(color: Colors.black54,fontWeight: FontWeight.bold,fontSize: 20),)
                );
              }
          );
        }
    );

  }


  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_current.value < 1) {
          timer.cancel();}
        else {
          _current.value = _current.value - 1;
        }

      },
    );
  }
}