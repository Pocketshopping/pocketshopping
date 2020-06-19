import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class SetupBusiness extends StatelessWidget {
  final bool isAgent;
  final User agent;
  SetupBusiness({this.isAgent=false,this.agent});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'PocketShopping',
            style: TextStyle(color: PRIMARYCOLOR),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: BlocProvider<BusinessBloc>(
          create: (context) => BusinessBloc(),
          child: BusinessSetupForm(isAgent: isAgent,agent: agent,),
        ),
      ),
    );
  }
}
