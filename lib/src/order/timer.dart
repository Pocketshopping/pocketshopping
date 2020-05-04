import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class TimerWidget extends StatefulWidget {
  TimerWidget({this.seconds, this.message = '', this.onFinish, this.onRepeat});

  final int seconds;
  final Function onFinish;
  final Function onRepeat;
  final String message;

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {
  int _start;
  String counter;
  Timer _timer;
  Stream<LocalNotification> _notificationsStream;
  bool responded;
  bool querying;
  String acceptedBy;

  @override
  void initState() {
    _start = widget.seconds;
    counter = '${(widget.seconds / 60)}';
    responded = null;
    querying = true;
    acceptedBy = '';
    startTimer();
    //NotificationsBloc.instance.clearNotification();
    _notificationsStream = NotificationsBloc.instance.notificationsStream;
    _notificationsStream.listen((notification) {
      if (notification != null) {
        //print('Notifications: ${notification.data['data']}');
        if (mounted &&
            notification.data['data']['payload'].toString().isNotEmpty) {
          var payload = jsonDecode(notification.data['data']['payload']);
          switch (payload['NotificationType']) {
            case 'OrderRequestResponse':
              setState(() {
                responded = payload['Response'] as bool;
                acceptedBy = payload['acceptedBy'] as String;
              });
              NotificationsBloc.instance.clearNotification();
              break;
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return querying
        ? Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: CircularStepProgressIndicator(
                      totalSteps: widget.seconds,
                      currentStep: _start,
                      stepSize: 10,
                      selectedColor: PRIMARYCOLOR,
                      unselectedColor: Colors.grey[200],
                      padding: 0,
                      width: 150,
                      height: 150,
                      selectedStepSize: 15,
                      child: Center(
                        child: widget.message.isNotEmpty
                            ? Text(
                                '$counter ${widget.message}',
                                textAlign: TextAlign.center,
                              )
                            : Container(),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Confirming order from merchant',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.03),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      'please wait..',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.03),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: MediaQuery.of(context).size.height * 0.18,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Sorry we can not process this order because the merchant'
                      ' is unavailable',
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.03),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: FlatButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                  )
                ],
              ),
            ),
          );
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
                        if (responded != null) {
                          if (responded) {
                            _start = 1;
                            widget.onFinish(acceptedBy);
                          } else {
                            querying = false;
                            _start = 1;
                          }
                        } else {
                          querying = false;
                        }
                      } else {
                        if (_start % 20 == 0) {
                          widget.onRepeat();
                        }
                        if (responded != null) {
                          if (responded)
                            widget.onFinish(acceptedBy);
                          else {
                            querying = false;
                            _start = 1;
                          }
                        }
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
        counter = '$minute min';
      });
    else
      setState(() {
        counter = '$_start sec';
      });
  }
}
