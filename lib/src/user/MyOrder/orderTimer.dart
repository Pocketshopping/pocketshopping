import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderTimerWidget extends StatefulWidget {
  OrderTimerWidget({
    this.seconds,
    this.datetime = '',
    this.onFinish,
  });

  final int seconds;
  final Function onFinish;
  final dynamic datetime;

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<OrderTimerWidget> {
  int _start;
  String counter;
  Timer _timer;
  String colorsState;

  @override
  void initState() {
    //print(setStartCount().toString());
    colorsState = (setStartCount() / 60).round() > 0 ? 'green' : 'red';
    _start = setStartCount();
    counter = '${(setStartCount() / 60).round()}';
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: colorsState == 'green' ? Colors.green : Colors.redAccent,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$counter",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "min",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ));
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    if (mounted)
      _timer = new Timer.periodic(
          oneSec,
          (Timer timer) => {
                if (mounted)
                  setState(
                    () {
                      if (_start < 1) {
                        timer.cancel();
                        colorsState = 'red';
                      } else {
                        _start = _start - 1;
                        countDownFormater(_start);
                      }
                    },
                  ),
              });
  }

  void countDownFormater(int sec) {
    int minute = 0;
    minute = (sec / 60).round();
    if (minute > 0)
      setState(() {
        counter = '$minute';
      });
  }

  int setStartCount() {
    var otime =
        DateTime.parse((widget.datetime as Timestamp).toDate().toString())
            .add(Duration(seconds: widget.seconds));
    int diff = otime.difference(DateTime.now()).inSeconds;
    if (diff > 0)
      return diff;
    else
      return 0;
  }
}
