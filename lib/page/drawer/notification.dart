import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/model/DataModel/notificationDataModel.dart';
import 'package:pocketshopping/model/DataModel/staffDataModel.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/admin.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => new _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool loading;
  bool report;
  bool success;
  var format = DateFormat('HH:mm a  MMMM d, y');
  BuildContext contx;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = false;
    report = false;
    success = true;
  }

  makeSatff(DocumentSnapshot doc) async {
    if (loading) {
      Scaffold.of(contx).showSnackBar(SnackBar(
        content: Text('I am working please wait!'),
        behavior: SnackBarBehavior.floating,
      ));
    } else {
      setState(() {
        loading = true;
      });
      var tempData = await doc.data['notificationInitiator'].get(source: Source.server);
      UserData(
              uid: psProvider.of(context).value['uid'],
              role: 'staff',
              bid: tempData.data['staffWorkPlace'].documentID)
          .upDate()
          .then((value) => {
                StaffDataModel(
                  sid: doc.data['notificationInitiator'].documentID,
                  sStatus: 'ACTIVE',
                  sStart: DateTime.now(),
                ).upDate().then((value) => null),
                NotificationDataModel(nid: doc.documentID)
                    .upDate()
                    .then((value) => null),
                Auth().upDateUserRole('staff').then((value) => null),
                setState(() {
                  loading = false;
                  report = true;
                  success = true;
                })
              })
          .catchError((onError) {
        print(onError);
        setState(() {
          loading = false;
          report = true;
          success = false;
        });
      });
    }
  }

  Widget staffRequest(DocumentSnapshot doc) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 1.0,
                  spreadRadius: 1.0),
            ]),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: !loading
            ? !report
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                          child: Icon(
                        Icons.work,
                        size: MediaQuery.of(context).size.width * 0.2,
                        color: Colors.black54,
                      )),
                      Center(
                          child: Text(
                        doc.data['notificationBody'],
                        style: TextStyle(fontSize: 18),
                      )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(format.format(DateTime.parse(doc
                                .data['notificationCreatedAt']
                                .toDate()
                                .toString()))),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: FlatButton(
                              onPressed: () async {
                                await makeSatff(doc);
                              },
                              child: Container(
                                color: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(
                                  'Yes',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: FlatButton(
                              onPressed: () {
                                if (loading) {
                                  Scaffold.of(contx).showSnackBar(SnackBar(
                                    content: Text('I am working please wait!'),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                } else {
                                  setState(() {
                                    loading = true;
                                  });
                                }
                              },
                              child: Container(
                                color: Colors.redAccent,
                                padding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Text(
                                  'No',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : success
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                              child: Icon(
                            Icons.thumb_up,
                            size: MediaQuery.of(context).size.width * 0.2,
                            color: Colors.greenAccent,
                          )),
                          Center(
                              child: Text(
                                  "Congratulations! You are now a staff of ${doc.data['notificationBody'].toString().split('at')[1].split('do')[0]}")),
                          Center(
                            child: FlatButton(
                              onPressed: () {
                                psProvider.of(context).value['notifications'] =
                                    null;
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AdminPage()));
                              },
                              child: Text('Check out your workplace'),
                            ),
                          )
                        ],
                      )
                    : Column(
                        children: <Widget>[
                          Center(
                              child: Icon(
                            Icons.error,
                            size: MediaQuery.of(context).size.width * 0.2,
                            color: Colors.redAccent,
                          )),
                          Center(
                              child: Text(
                                  "Error processing request check your connection and try again",
                                  style: TextStyle(color: Colors.black54))),
                          Center(
                            child: FlatButton(
                              onPressed: () async {
                                await makeSatff(doc);
                              },
                              child: Text(
                                'Try Again',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          )
                        ],
                      )
            : Center(
                child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  Text(
                    'Processing Request please wait!',
                    style: TextStyle(
                        fontStyle: FontStyle.italic, color: Colors.black54),
                  )
                ],
              )));
  }

  Widget notificationWidget() {
    if (psProvider.of(context).value['notifications'] == null) {
      return FutureBuilder(
        builder: (context, notificationSnap) {
          if (notificationSnap.connectionState == ConnectionState.none &&
              notificationSnap.hasData == null) {
            //print('project snapshot data is: ${projectSnap.data}');
            return Container();
          }
          if (notificationSnap.hasData) {
            if (notificationSnap.data.length != 0) {
              return ListView.builder(
                itemCount: notificationSnap.data.length,
                itemBuilder: (context, index) {
                  var data = notificationSnap.data;
                  if (data[index].data['notificationAction'] ==
                      'STAFFREQUEST') {
                    return staffRequest(
                      data[index],
                    );
                  } else {
                    return Column(
                      children: <Widget>[
                        Text('${data[index].data['notificationAction']}')
                      ],
                    );
                  }
                },
              );
            } else {
              return Container(
                  color: Colors.white,
                  child: Center(
                      child: Column(
                    children: <Widget>[
                      Image.asset('assets/images/empty.gif'),
                      Text(
                        'No Pending Rquest',
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  )));
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        future: NotificationDataModel(
                uid: psProvider.of(context).value['uid'], nCleared: false)
            .getAll(),
      );
    } else {
      return ListView.builder(
        itemCount: psProvider.of(context).value['notifications'].length,
        itemBuilder: (context, index) {
          var data = psProvider.of(context).value['notifications'];
          if (data[index].data['notificationAction'] == 'STAFFREQUEST') {
            return staffRequest(
              data[index],
            );
          } else {
            return Column(
              children: <Widget>[
                Text('${data[index].data['notificationAction']}')
              ],
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.1), // here the desired height
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: PRIMARYCOLOR,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              " Request(s)",
              style: TextStyle(color: PRIMARYCOLOR),
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: Builder(builder: (cxt) {
          contx = cxt;
          return notificationWidget();
        }),
      ),
    );
  }
}
