import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/src/notification/notification.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class TimerWidget extends StatefulWidget {
  TimerWidget(
      {this.seconds,
      this.message = '',
      this.onFinish,
      this.onAgent,
      this.onMerchant,
      this.mode
      });

  final int seconds;
  final Function onFinish;
  final Function onAgent;
  final Function onMerchant;
  final String message;
  final String mode;

  @override
  State<StatefulWidget> createState() => _TimerState();
}

class _TimerState extends State<TimerWidget> {
  int _start;
  String counter;
  Timer _timer;
  Stream<LocalNotification> _notificationsStream;
  bool mResponded;
  bool aResponded;
  bool querying;
  String acceptedBy;
  int responseCount;

  @override
  void initState() {
    responseCount = 0;
    _start = widget.seconds;
    counter = '${(widget.seconds / 60)}';
    mResponded = null;
    aResponded = null;
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
                mResponded = payload['Response'] as bool;
                acceptedBy = payload['acceptedBy'] as String;
              });
              NotificationsBloc.instance.clearNotification();
              break;
            case 'AgentRequestResponse':
              setState(() {
                if (payload['Response']) {
                  aResponded = payload['Response'] as bool;
                  acceptedBy = payload['acceptedBy'] as String;
                } else {
                  responseCount += 1;
                  if (responseCount == (payload['agentCount'] as int)) {
                    aResponded = false;
                  }
                }
              });
              NotificationsBloc.instance.clearNotification();
              break;

            default:
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
                        if (mResponded != null) {
                          if (mResponded) {
                            _start = 1;
                            widget.onFinish(acceptedBy);
                          } else {
                            querying = false;
                            _start = 1;
                          }
                        } else {
                          querying = false;
                        }

                        if (aResponded != null) {
                          if (aResponded)
                            {
                              _start = 1;
                              widget.onFinish(acceptedBy);
                            }
                          else {
                            querying = false;
                            _start = 1;
                          }
                        }
                      } else {
                        if (_start == 58) {
                          if (widget.mode == 'Delivery')
                            widget.onAgent();
                          else if(widget.mode == 'Pickup')
                            widget.onMerchant();
                        }
                        if (mResponded != null) {
                          if (mResponded)
                            {
                              _start = 1;
                              widget.onFinish(acceptedBy);
                            }
                          else {
                            querying = false;
                            _start = 1;
                          }
                        }
                        if (aResponded != null) {
                          if (aResponded)
                            {
                              _start = 1;
                              widget.onFinish(acceptedBy);
                            }
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
