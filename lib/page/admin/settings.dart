import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';




class Settings extends StatefulWidget{
  final Color themeColor;
  Settings({this.themeColor});

  @override
  _SettingsState createState() => new _SettingsState();
}


class _SettingsState extends State<Settings> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15), // here the desired height
            child: AppBar(
            backgroundColor: widget.themeColor,
            leading: IconButton(

              icon: Icon(Icons.arrow_back_ios,color:Colors.white,
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ) ,
            actions: <Widget>[

            ],

            title: Text("Business Settings"),

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
                
                        template: SettingsIndicatorTitle,
                      ),
                    ),
                  ),
                ),
              ),
            
    );
  }
}