import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/request/repository/requestObject.dart';
import 'package:pocketshopping/src/request/repository/requestRepo.dart';
import 'package:pocketshopping/src/ui/constant/constants.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/bloc/user.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:progress_indicators/progress_indicators.dart';

class BlankWorkplace extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _BlankWorkplaceState();
}

class _BlankWorkplaceState extends State<BlankWorkplace> {
  bool isSubmitting;
  Session currentUser;


  @override
  void initState() {
    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    isSubmitting = false;
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
              title: Text(
                'My WorkPlace',
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
            backgroundColor: Colors.white,
            body: Container(
              child: FutureBuilder(
                future: RequestRepo.getSacked(currentUser.user.uid),
                builder: (context,AsyncSnapshot<List<Request>>request){
                  if(request.connectionState == ConnectionState.waiting){
                    return Center(
                      child: JumpingDotsProgressIndicator(
                        fontSize: MediaQuery.of(context).size.height * 0.12,
                        color: PRIMARYCOLOR,
                      ),
                    );
                  }
                  else if(request.hasError){
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('Error accessing your workplace. Restart the app and try again, if the problem persist report to your employer for further action.',
                          textAlign: TextAlign.center,),
                      )
                    );
                  }
                  else{
                    if(request.data.isNotEmpty){
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Text('${request.data.first.requestBody}',textAlign: TextAlign.center,),
                            ),
                            Center(
                              child: FlatButton(
                                onPressed: ()async{
                                  Utility.bottomProgressLoader(body: 'Changing account..please wait');
                                  await RequestRepo.clear(request.data.first.requestID);
                                  Get.back();
                                  await UserRepository().changeRole('user');
                                  BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
                                },
                                color: PRIMARYCOLOR,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                                  child: Text(
                                    'Click here to continue using app as user',style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }
                    else
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('Error accessing your workplace. Restart the app and try again, if the problem persist report to your employer for further action.',
                              textAlign: TextAlign.center,),
                          ),
                          FlatButton(
                            onPressed: ()async{
                              //Utility.bottomProgressLoader(body: 'Changing account..please wait');
                              //await RequestRepo.clear(request.data.first.requestID);
                              //Get.back();
                              await UserRepository().changeRole('user');
                              BlocProvider.of<AuthenticationBloc>(context).add(AppStarted());
                            },
                            color: PRIMARYCOLOR,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                              child: Text(
                                'Click here to continue',style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ]
                      );
                  }
                },
              )
            )
        )
    );
  }
}
