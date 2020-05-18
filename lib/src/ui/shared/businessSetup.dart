import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/business/business.dart' as biz;
import 'package:pocketshopping/src/repository/user_repository.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/psCard.dart';

class BSetup extends StatelessWidget {
  final UserRepository _userRepository;

  BSetup({
    Key key,
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          body: Center(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.9,
                child: psHeadlessCard(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        //offset: Offset(1.0, 0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    child: Column(
                      children: [
                        Container(
                          child: Image.asset('assets/images/business.png'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 10),
                          child: Text(
                            'Would you like to setup a business?',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: RaisedButton(
                              onPressed: () {
                                Get.to(biz.SetupBusiness());
                              },
                              color: PRIMARYCOLOR,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Center(
                                  child: Text(
                                    'Yes, I want to',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: RaisedButton(
                              onPressed: () {
                                BlocProvider.of<AuthenticationBloc>(context)
                                    .add(
                                  AppStarted(),
                                );
                                //Get.back();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Center(
                                  child: Text(
                                    'No',
                                    style: TextStyle(color: PRIMARYCOLOR),
                                  ),
                                ),
                              ),
                            )),
                      ],
                    ))),
          ),
        ));
  }
}
