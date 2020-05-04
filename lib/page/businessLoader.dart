import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/firebase/BaseAuth.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:pocketshopping/model/DataModel/userData.dart';
import 'package:pocketshopping/page/businessSetupComplete.dart';

class BusinesSetupLoader extends StatefulWidget {
  BusinesSetupLoader({
    //this.coverUrl=PocketShoppingDefaultCover,
    this.data,
  });

  MerchantDataModel data;

  @override
  State<StatefulWidget> createState() => _BusinesSetupLoaderState();
}

class _BusinesSetupLoaderState extends State<BusinesSetupLoader> {
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://pocketshopping-a57c2.appspot.com');

  StorageUploadTask _uploadTask;
  String job;
  String filePath;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.data.bCroppedPhoto != null
        ? _startUpload()
        : photolessRegistration();
  }

  photolessRegistration() {
    setState(() {
      job = 'Setting up business account please wait.';
    });
    widget.data.save().then((value) => {
          UserData(
                  uid: psProvider.of(context).value['uid'],
                  role: 'admin',
                  bid: value)
              .upDate(),
          Auth().upDateUserRole('admin').then((value) => null),
          UserData(uid: psProvider.of(context).value['uid'])
              .getOne()
              .then((value) => {
                    psProvider.of(context).value['user'] = value,
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusinessSetupComplete()))
                  })
        });
  }

  /// Starts an upload task
  void _startUpload() {
    /// Unique file name for the file

    setState(() {
      job = "Uploading Business Cover please wait";
      filePath = 'MerchantCover/${DateTime.now()}.png';
      _uploadTask =
          _storage.ref().child(filePath).putFile(widget.data.bCroppedPhoto);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.bCroppedPhoto != null) {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
              backgroundColor: Colors.white,
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(
                    MediaQuery.of(context).size.height *
                        0.1), // here the desired height
                child: AppBar(
                  centerTitle: true,
                  elevation: 0.0,
                  backgroundColor: Colors.white,
                  title: Text(
                    "Business Setup",
                    style: TextStyle(color: PRIMARYCOLOR),
                  ),
                  automaticallyImplyLeading: false,
                ),
              ),
              body: StreamBuilder<StorageTaskEvent>(
                  stream: _uploadTask.events,
                  builder: (_, snapshot) {
                    var event = snapshot?.data?.snapshot;

                    double progressPercent = event != null
                        ? event.bytesTransferred / event.totalByteCount
                        : 0;
                    if (progressPercent == 1) {
                      job = 'Setting up business account please wait.';
                      snapshot.data.snapshot.ref
                          .getDownloadURL()
                          .then((value) => {
                                widget.data.bPhoto = value,
                                widget.data.save().whenComplete(() => {
                                      UserData(
                                              uid: psProvider
                                                  .of(context)
                                                  .value['uid'],
                                              role: 'admin',
                                              bid: value)
                                          .upDate(),
                                      UserData(
                                              uid: psProvider
                                                  .of(context)
                                                  .value['uid'])
                                          .getOne()
                                          .then((value) => {
                                                psProvider
                                                    .of(context)
                                                    .value['user'] = value,
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            BusinessSetupComplete()))
                                              })
                                    })
                              });

                      print('completed');
                    }

                    return Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          if (_uploadTask.isComplete)
                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.1),
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/working.gif',
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    job,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              )),
                            ),

                          if (_uploadTask.isInProgress)
                            Container(
                              margin: EdgeInsets.only(
                                  top:
                                      MediaQuery.of(context).size.height * 0.1),
                              child: Center(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset(
                                    'assets/images/cloud-upload.gif',
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    job,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              )),
                            ),

                          // Progress bar
                        ],
                      ),
                    );
                  })));
    } else {
      return WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      0.1), // here the desired height
              child: AppBar(
                centerTitle: true,
                elevation: 0.0,
                backgroundColor: Colors.white,
                title: Text(
                  "Business Setup",
                  style: TextStyle(color: PRIMARYCOLOR),
                ),
                automaticallyImplyLeading: false,
              ),
            ),
            body: Container(
                color: Colors.white,
                child: Column(children: [
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/working.gif',
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          job,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ],
                    )),
                  ),
                ])),
          ));
    }
  }
}
