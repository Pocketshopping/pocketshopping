import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/bloc/requestBloc.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class RequestScreen extends StatefulWidget {
  RequestScreen({this.requests,this.uid});
  final String uid;
  final List<Request> requests;

  @override
  State<StatefulWidget> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool isSubmitting;
  bool isLoading;
  List<Request> _requests;
  bool workRequestAccepted;

  @override
  void initState() {
    isSubmitting = false;
    _requests = widget.requests;
    isLoading = _requests.isEmpty;
    if(_requests.isEmpty)
    {
      isLoading=true;
      RequestRepo.getAll(widget.uid).then((value) {
        setState(() {
          _requests.addAll(value);
          isLoading=false;
        });
      });
    }
    workRequestAccepted = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          if (isSubmitting)
            return false;
          else {
            return true;
          }
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              centerTitle: true,
              backgroundColor: Color.fromRGBO(255, 255, 255, 1),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                ),
                onPressed: () {
                  if (!isSubmitting) Get.back();
                },
              ),
              title: Text(
                'My Request',
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
            backgroundColor: Colors.white,
            body: !isLoading?Container(
              child: ListView(
                children: [
                  _requests.isNotEmpty
                      ? Column(
                          children: requests(),
                        )
                      : Container(
                    child: ListTile(
                      title: Image.asset('assets/images/empty.gif'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Text(
                              'Empty',
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height * 0.06),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "No New Request",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ):Center(
              child: JumpingDotsProgressIndicator(
                fontSize: MediaQuery.of(context).size.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            ),
        )
    );
  }

  List<Widget> requests() {
    return List<Widget>.generate(
        _requests.length, (index) => oneRequest(_requests[index]));
  }

  Widget oneRequest(Request request) {
    switch(request.requestAction){
      case'WORKREQUEST':
        return psCard(
            color: PRIMARYCOLOR,
            title: request.requestTitle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Center(
                      child: Text(
                        request.requestBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  !isSubmitting
                      ? Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            processResponse(request, 'Y');
                          },
                          child: Text('Accept'),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            processResponse(request, 'n');
                          },
                          child: Text('Decline'),
                        ),
                      )
                    ],
                  )
                      : Container()
                ],
              ),
            ));
        break;
      case'STAFFWORKREQUEST':
        return psCard(
            color: PRIMARYCOLOR,
            title: request.requestTitle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Center(
                      child: Text(
                        request.requestBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  !isSubmitting
                      ? Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            processResponse(request, 'Y');
                          },
                          child: Text('Accept'),
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          onPressed: () {
                            processResponse(request, 'n');
                          },
                          child: Text('Decline'),
                        ),
                      )
                    ],
                  )
                      : Container()
                ],
              ),
            ));
        break;
      case'REMOVEWORK':
        return psCard(
            color: PRIMARYCOLOR,
            title: request.requestTitle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Center(
                      child: Text(
                        request.requestBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  !isSubmitting
                      ? Row(
                    children: [
                      Expanded(
                        child: FlatButton(
                          onPressed: () async{
                            Utility.bottomProgressLoader(body: 'Changing account..please wait');
                            await RequestRepo.clear(request.requestID);
                            Get.back();
                            await UserRepository().changeRole('user');
                            BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
                            Get.back();
                          },
                          child: Text('Okay'),
                        ),
                      ),
                    ],
                  )
                      : Container()
                ],
              ),
            ));
        break;
      default:
        return psCard(
            color: PRIMARYCOLOR,
            title: request.requestTitle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                //offset: Offset(1.0, 0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Center(
                      child: Text(
                        request.requestBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ));
        break;
    }

  }

  processResponse(Request request, String response) {
    setState(() {
      isSubmitting = true;
    });
    GetBar(
      title: 'Response',
      messageText: Text(
        'Processing Response',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(days: 365),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: PRIMARYCOLOR,
      showProgressIndicator: true,
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ).show();
    if (response == 'Y') {
      LogisticRepo.agentAccept(request.requestInitiatorID, request.requestID,
              request.requestReceiver)
          .then((value) {
        if (Get.isSnackbarOpen) {
          Get.back();
          GetBar(
            title: 'Response',
            messageText: Text(
              'Work request has been approved.',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: PRIMARYCOLOR,
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            mainButton: FlatButton(
              onPressed: () {
                Get.back();
                BlocProvider.of<AuthenticationBloc>(context).add(
                  AppStarted(),
                );
                Get.back();
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Text(
                    'View',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ).show();
          setState(() {
            _requests.removeWhere(
                (element) => element.requestAction == 'WORKREQUEST');
            isSubmitting = false;
            RequestBloc.instance.newCount(_requests.length);
          });
        }
      }).catchError((_) {
        print(_);
        if (Get.isSnackbarOpen) {
          Get.back();
          GetBar(
            title: 'Response',
            messageText: Text(
              'Error responding, check your connection and try again',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ).show();
          setState(() {
            isSubmitting = false;
          });
        }
      });
    } else {
      LogisticRepo.decline(request.requestInitiatorID, request.requestID)
          .then((value) {
        setState(() {
          _requests.removeWhere((element) => element == request);
          RequestBloc.instance.newCount(_requests.length);
        });
        if (Get.isSnackbarOpen) {
          Get.back();
          GetBar(
            title: 'Response',
            messageText: Text(
              'Work request has been declined.',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: PRIMARYCOLOR,
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ).show();
          setState(() {
            _requests.removeWhere((element) => element == request);
            isSubmitting = false;
          });
        }
      }).catchError((_) {
        if (Get.isSnackbarOpen) {
          Get.back();
          GetBar(
            title: 'Response',
            messageText: Text(
              'Error responding, check your connection and try again',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 3),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
          ).show();
          setState(() {
            isSubmitting = false;
          });
        }
      });
    }


  }
  
  
}
