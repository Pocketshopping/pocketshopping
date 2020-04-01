import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';




class SourceProduct extends StatefulWidget{
  final Color themeColor;
  SourceProduct({this.themeColor});
  @override
  _SourceProductState createState() => new _SourceProductState();
}


class _SourceProductState extends State<SourceProduct> {

  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text("Product On PocketShopping",style: TextStyle(fontSize: 14), );
  ViewModel vmodel;
  String barcode = "";

  @override
  void initState() {

    super.initState();
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      Navigator.pop(context);
      setState(() => vmodel.handleQRcodeSearch(search: barcode));
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'you cancelled the QRcode search');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon =  Icon(Icons.close);
        this._appBarTitle =  TextFormField(
          controller: _filter,
          decoration:  InputDecoration(
              prefixIcon:  Icon(Icons.search),
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
        this._appBarTitle =  Text("Product On PocketShopping",style: TextStyle(fontSize: 14),);

      }
    });
  }

  _SeacrhUsingQRCode(){
    showModalBottomSheet(
      context: context,
      builder: (context) =>
          BottomSheetTemplate(
            height: MediaQuery.of(context).size.height*0.6,
            opacity: 0.2,
            child: Center(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child:

                    Container(

                      child: FlatButton(

                        onPressed: () => {
                          this.scan()
                        },

                        padding: EdgeInsets.all(10.0),
                        child: Column( // Replace with a Row for horizontal icon + text
                          children: <Widget>[
                            Center(child:Text("Search Using QRcode/Barcode",style: TextStyle(fontSize:14, color: Colors.black54),textAlign: TextAlign.center,)),
                             Container(height: 10,),
                            FittedBox(fit:BoxFit.contain,child:Icon(Icons.camera,color: widget.themeColor, size: MediaQuery.of(context).size.height*0.1,)),
                            Center(child:Text("Scan QRCode to search for product",style: TextStyle(color: Colors.black54),textAlign: TextAlign.center,)),
                          ],
                        ),
                      ),
                    ),



                  )
                  ,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(barcode, textAlign: TextAlign.center,),
                  )
                  ,
                ],
              ),
            ),
          ),
      isScrollControlled: true,
    );
  }


  _SourceProductState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";

        });
      } else {
        setState(() {
          _searchText = _filter.text;
          vmodel.handleSearch(search: _searchText);
          print(_searchText);
        });
      }
    });
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15), // here the desired height
        child: AppBar(
          centerTitle: true,
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
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: _SeacrhUsingQRCode,

            ),

          ],

          title:_appBarTitle,

          automaticallyImplyLeading: false,
        ),
      ),
      body: ChangeNotifierProvider<ViewModel>(

        create: (context) => ViewModel(searchTerm: _searchText),
        child: Consumer<ViewModel>(

          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel=model;
                return SchedulerBinding.instance.addPostFrameCallback(
                        (duration) => model.handleItemCreated(index));

              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyIndicatorTitle?SourceProductIndicatorTitle:SearchEmptyIndicatorTitle,
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      color: Colors.greenAccent,
                      onPressed: (){},
                      child: Text("Add",style: TextStyle(color: Colors.black54),),
                    ),
                  ),
                  Expanded(
                    child: FlatButton(
                      color: Colors.redAccent,
                      onPressed: (){},
                      child: Text("Edit Before Adding",style: TextStyle(color: Colors.black54),),
                    ),
                  ),
                ],
              ),
            ],
          ),

        ),
      ],
    );


  }
}