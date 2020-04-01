import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';

import 'AwareListItem.dart';
import 'bSheetTemplate.dart';


class ManageOrder extends StatefulWidget {

  ManageOrder({this.themeColor = Colors.black54});

  final Color themeColor;
  _ManageOrderState createState() => new _ManageOrderState();
}
  class _ManageOrderState extends State<ManageOrder> {


    final TextEditingController _filter = new TextEditingController();
    String _searchText = "";
    Icon _searchIcon = new Icon(Icons.search);
    Widget _appBarTitle = new Text( 'Manage Order' );
    ViewModel vmodel;
    CompletedOrder tab1=CompletedOrder();
    CancelledOrder tab2=CancelledOrder();
    int currentTab=0;

    @override
    void initState() {

      super.initState();
    }

    void _searchPressed() {
      setState(() {
        if (this._searchIcon.icon == Icons.search) {
          this._searchIcon =  Icon(Icons.close);
          this._appBarTitle =  TextFormField(
            controller: _filter,
            decoration:  InputDecoration(
                prefixIcon:  Icon(Icons.search,color:Colors.white.withOpacity(0.5)),
                hintText: 'Search by Name...',
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                )

            ),
          );
        } else {
          this._searchIcon =  Icon(Icons.search);
          this._appBarTitle =  Text("Manage Orders");

        }
      });
    }

    _ManageOrderState() {
      _filter.addListener(() {
        if (_filter.text.isEmpty) {
          setState(() {
            _searchText = "";

          });
        } else {
          setState(() {
            _searchText = _filter.text;
            //vmodel.handleSearch(search: _searchText);
            if(currentTab == 0) {
              tab1.handleSearch(search: _searchText);
            }
            else if(currentTab == 1) {
              tab2.handleSearch(search: _searchText);
            }


          });
        }
      });
    }


    @override
  Widget build(BuildContext context) {

    return  DefaultTabController(

      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.2), // here the desired height
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
              IconButton(
                icon: _searchIcon,
                onPressed: _searchPressed,

              ),
            ],

            title: _appBarTitle,

            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  currentTab = index;
                });
                //print(index.toString());
              },
              tabs: [
                Tab(text: "Completed Order",),
                Tab(text: "Cancelled Order",),
              ],
            ),


            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [
            tab1,
            tab2
          ],
        ),
      ),

    );

  }
}


class CompletedOrder extends StatelessWidget {


  final Color themeColor;
  final String search;
  CompletedOrder({Key key,this.themeColor,this.search}) : super(key: key);

  ViewModel vmodel;
  void handleSearch({String search}) {
    print("_from completed $search");
          vmodel.handleSearch(search: search);
  }
  @override
  Widget build(BuildContext context) {
    void detail(String name){
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            BottomSheetTemplate(
              height: MediaQuery.of(context).size.height*0.6,
              opacity: 0.2,
              child: showDetail(name: name,),
            ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<ViewModel>(

        create: (context) => ViewModel(),
        child: Consumer<ViewModel>(

          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel = model;
                SchedulerBinding.instance.addPostFrameCallback(
                        (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] !=SearchEmptyIndicatorTitle?CompletedOrderIndicatorTitle:SearchEmptyIndicatorTitle,
                callback: (value){
                  detail(value);
                  return value ;
                },
              ),
            ),
          ),
        ),
      ),

    );
  }


}



class CancelledOrder extends StatelessWidget {


  final Color themeColor;
  CancelledOrder({Key key,this.themeColor}) : super(key: key);

  ViewModel vmodel;
  void handleSearch({String search}) {
    print("_from completed $search");
    vmodel.handleSearch(search: search);
  }
  @override
  Widget build(BuildContext context) {
    void detail(String name){
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            BottomSheetTemplate(
              height: MediaQuery.of(context).size.height*0.6,
              opacity: 0.2,
              child: showDetail(name: name,),
            ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<ViewModel>(

        create: (context) => ViewModel(),
        child: Consumer<ViewModel>(

          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel = model;
                SchedulerBinding.instance.addPostFrameCallback(
                        (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] !=SearchEmptyIndicatorTitle?CancelledOrderIndicatorTitle:SearchEmptyIndicatorTitle,
                callback: (value){
                  detail(value);
                  return value ;
                },
              ),
            ),
          ),
        ),
      ),

    );
  }




}



class showDetail extends StatelessWidget{
  final String name;
  showDetail({this.name});

  @override
  Widget build(BuildContext context) {
    double marginLR=MediaQuery.of(context).size.width;
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top:marginLR*0.03,left: marginLR*0.06,right: marginLR*0.06  ),
          padding: EdgeInsets.only(top: marginLR*0.03,bottom: marginLR*0.03),
          child:  Column(
            children: <Widget>[
              Align(alignment:Alignment.center,child: Center(child: Text(name,style: TextStyle(fontSize: 18),),),),

              Container(height: marginLR*0.03,),

              Align(alignment:Alignment.center,
                child: Container(
                    width: MediaQuery.of(context).size.width*0.4,
                    height: MediaQuery.of(context).size.height*0.2,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                "https://i.imgur.com/BoN9kdC.png")
                        )
                    )
                ),
              ),
              Align(alignment:Alignment.center,child: Center(child: Text('Customer Name',),),),
              Container(height: marginLR*0.03,),
              Container(height: marginLR*0.03,),
              Align(alignment:Alignment.topLeft,
                child: Center(child: Text('Order Details',style: TextStyle(fontSize: 18),),),),
              Container(height: marginLR*0.03,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("Payment Method",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("Pocket",style: TextStyle(color:Colors.black54,),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("Order Type",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("Home Delivery",style: TextStyle(color:Colors.black54,),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("Amount",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("2345",style: TextStyle(color:Colors.black54, fontWeight: FontWeight.bold),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("Date and Time ",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("21-1-2020 12:23:0",style: TextStyle(color:Colors.black54,),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("CompletedBy",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("joshy",style: TextStyle(color:Colors.black54,),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child:
                    Text("Date Time Completed",style: TextStyle(color:Colors.black54),),

                  ),
                  Expanded(
                    child:
                    Text("2020-1-1 12:13:09",style: TextStyle(color:Colors.black54,),),

                  ),


                ],
              ),
              Container(height: marginLR*0.03,
                decoration:
                BoxDecoration(border: Border(bottom: BorderSide( width: 1,
                    color: Colors.grey.shade300))),),

              Container(height: marginLR*0.03,),
              Align(alignment:Alignment.centerLeft,child: Center(child: Text('Order Items',style: TextStyle(fontSize: 18),),),),
              Container(height: marginLR*0.03,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text("Item",style: TextStyle(color:Colors.black54),),
                  ),
                  Expanded(
                    child: Text("Qty",style: TextStyle(color:Colors.black54),),
                  ),
                  Expanded(
                    child: Text("Amount",style: TextStyle(color:Colors.black54),),
                  ),
                ],
              ),
              Container(height: marginLR*0.03,),
            ],
          ),

        ),
        Container(
            margin: EdgeInsets.only(top:marginLR*0.03,left: marginLR*0.06,right: marginLR*0.06  ),
            padding: EdgeInsets.only(top: marginLR*0.03,bottom: marginLR*0.03),
            child:
            Column(
              children: List<Widget>.generate(
                7,
                    (int index) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text("Item",style: TextStyle(color:Colors.black54),),
                          ),
                          Expanded(
                            child: Text("Qty",style: TextStyle(color:Colors.black54),),
                          ),
                          Expanded(
                            child: Text("Amount",style: TextStyle(color:Colors.black54),),
                          ),
                        ],
                      ),
                      Divider()
                    ],
                  );
                },
              ).toList(),
            )
        )
      ],
    );


  }
}
