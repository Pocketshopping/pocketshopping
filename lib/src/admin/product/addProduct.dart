import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';

class AddProduct extends StatelessWidget {
  AddProduct({this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
          '${session.merchant.bName}',
          style: TextStyle(color: PRIMARYCOLOR),
        )),
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: BlocProvider<ProductBloc>(
          create: (context) =>
              ProductBloc()..add(ProductCount(mID: session.merchant.mID)),
          child: ProductForm(
            session: session,
          ),
        ),
      ),
    );
  }
}
