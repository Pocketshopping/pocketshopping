

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/widget/template.dart';
import 'package:pocketshopping/component/psCard.dart';

//import 'package:camera_utils/camera_utils.dart';



class AddBranch extends StatefulWidget {
  AddBranch({this.coverUrl='',this.color=null});
  final String coverUrl;
  final Color color;
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
    orders=false;
    messages=false;
    products = false;
    finances = false;
    managers = false;
    loaded=true;
    office='Office1Office1Office1Office1Office1Office1Office1Office1Office1Office1';

  }







  @override
  Widget build(BuildContext context) {

    final addStaff=Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
        color: widget.color,
        onPressed: () {
          // Validate returns true if the form is valid, or false
          // otherwise.
          if (_formKey.currentState.validate() && !loaded) {
            // If the form is valid, display a Snackbar.
            setState(() {
              loaded=true;
            });

          }
          else{
            print('added');
          }
        },
        child: Text('Create New Branch with this device',style: TextStyle(color: Colors.white),),
      ),
    );




    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
        child:Builder(
          builder: (ctx) =>AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(

              icon: Icon(Icons.arrow_back_ios,color:PRIMARYCOLOR,
              ),

              onPressed: (){

                if(true){
                  Scaffold.of(ctx)
                      .showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text('I am working please wait')));
                }
                else{
                  Navigator.pop(context);
                }

              },
            ) ,

            title:Text("Product",style: TextStyle(color: PRIMARYCOLOR),),

            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: Builder(
        builder: (ctx) =>CustomScrollView(
            slivers: <Widget>[ SliverList(
          delegate: SliverChildListDelegate(
            [
              Container(height: MediaQuery.of(context).size.height*0.02,),
              psCard(
                color: widget.color,
                title: 'New Business Branch',
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    //offset: Offset(1.0, 0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
                child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          if(loaded)
                            Column(children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide( //                   <--- left side
                                      color: Colors.black12,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                child: Center(child:
                                Column(
                                  children: <Widget>[
                                    Center(
                                        child:Container(
                                          child:Column(
                                            children: <Widget>[
                                              Text("Use the OTP below  to create new branch on a new device."
                                                ,style: TextStyle(fontSize: 18),),
                                              SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                              Text("The new device will have admin privileges while you retain superAdmin privilege on the new branch")
                                            ],
                                          )
                                        ) ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                    Center(
                                      child:  Text("Business ID"),
                                    ),
                                    Center(
                                        child:Container(
                                          child:Text("12345678"
                                            ,style: TextStyle(fontSize: 20),),
                                        ) ),
                                    SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                    Center(
                                      child: Text("Or"
                                        ,style: TextStyle(fontSize: 20),),
                                    ),

                                    addStaff,



                                  ],
                                )),
                              ),

                        ],
                            )
    ]

                    )

              ),




            ],
          )
      ),
    ]
                    )
      )
    );
  }
}