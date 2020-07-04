import 'package:flutter/material.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';

class AddBranch extends StatefulWidget {
  AddBranch();

  @override
  State<StatefulWidget> createState() => _AddBranchState();
}

class _AddBranchState extends State<AddBranch> {
  final _formKey = GlobalKey<FormState>();

  bool orders;
  bool messages;
  bool products;
  bool finances;
  bool managers;

  String office;

  bool loaded;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    orders = false;
    messages = false;
    products = false;
    finances = false;
    managers = false;
    loaded = true;
    office =
        'Office1Office1Office1Office1Office1Office1Office1Office1Office1Office1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.1), // here the desired height
          child: Builder(
            builder: (ctx) => AppBar(
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: PRIMARYCOLOR,
                ),
                onPressed: () {
                  /*if(true){
                  Scaffold.of(ctx)
                      .showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('I am working please wait')));
                }
                else{*/
                  Navigator.pop(context);
                  //}
                },
              ),
              title: Text(
                "Branch",
                style: TextStyle(color: PRIMARYCOLOR),
              ),
              automaticallyImplyLeading: false,
            ),
          ),
        ),
        body: Container());
  }
}
