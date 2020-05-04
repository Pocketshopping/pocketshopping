import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatelessWidget {
  AccountPage({this.themeColor = Colors.black54});

  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            0.15), // here the desired height
        child: AppBar(
          backgroundColor: themeColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: <Widget>[],
          title: Text("Account Settings"),
          automaticallyImplyLeading: false,
        ),
      ),
      body: ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(searchTerm: 'hello'),
        child: Consumer<ViewModel>(
          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: AccountIndicatorTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
