import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/logistic/provider.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class RequestScreen extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool isSubmitting;
  List<Request> _requests;
  bool workRequestAccepted;

  @override
  void initState() {
    isSubmitting = false;
    _requests = widget.requests;
    workRequestAccepted = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                'My WorkPlace',
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
            backgroundColor: Colors.white,
            body: Container(
              child: ListView(
                children: [
                  _requests.isNotEmpty
                      ? Column(
                    children: requests(),
                  )
                      : Container()
                ],
              ),
            )
        )
    );
  }

  List<Widget> requests() {
    return List<Widget>.generate(
        _requests.length, (index) => oneRequest(_requests[index]));
  }

  Widget oneRequest(Request request) {
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
