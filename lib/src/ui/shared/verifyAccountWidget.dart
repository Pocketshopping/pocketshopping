
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/ui/constant/appColor.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class VerifyAccountWidget  extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: psCard(
                  color: PRIMARYCOLOR,
                  title: 'GetStarted',
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      //offset: Offset(1.0, 0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                  child:
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            //                   <--- left side
                            color: Colors.black12,
                            width: 1.0,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(
                          Get.width * 0.02),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('A verification link has been sent to your mailbox once your email address is verified you can proceed with login'),
                          const SizedBox(height: 20,),
                          FlatButton(
                            onPressed: (){
                              BlocProvider.of<AuthenticationBloc>(context)
                                  .add(
                                AppStarted(),
                              );
                            },
                            color: PRIMARYCOLOR,
                            child: Text('Get Started',style: TextStyle(color: Colors.white),),
                          )
                        ],
                      )

                  )

              ),
            )
          ],
        )
      )
    );
  }
}