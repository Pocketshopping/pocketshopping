import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/login.dart';

class BusinessSetupComplete extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

      return  WillPopScope(
          onWillPop: () async => false,
    child:Scaffold(
          backgroundColor: Colors.white,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
            child: AppBar(
              centerTitle: true,
              elevation:0.0,
              backgroundColor: Colors.white,
              title:Text("Business Setup",style: TextStyle(color: PRIMARYCOLOR),),

              automaticallyImplyLeading: false,
            ),
          ),

          body:
           Container(

                  color: Colors.white,
                  child:

                  Column(

                    children: [
                        Container(
                          margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.height*0.05,
                              right: MediaQuery.of(context).size.height*0.05,
                          ),
                          child: Center(
                              child:
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/completed.gif',
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height*0.4,
                                    fit: BoxFit.cover,
                                  ),
                                  Text("Your business setup is complete",style: TextStyle(fontSize: 16,color: Colors.black54),),
                                 Container(height: 10,),
                                  Center(child:Text("Note your business will be activated once you add atleast one product "
                                      "so head straight to your dashboard and start adding product."
                                      "",style: TextStyle(fontSize: 14,color: Colors.black54),)),
                                  Container(height: 10,),
                                  FlatButton(
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => AdminPage()));
                                    },
                                    color: PRIMARYCOLOR,
                                    child: Padding(
                                      padding:  EdgeInsets.all( MediaQuery.of(context).size.height*0.02),
                                      child: Text("DashBoard",style: TextStyle(color: Colors.white),),
                                    ),
                                  )
                                ],
                              )

                          ),
                        ),



                      // Progress bar

                    ],
                  ),
                )

    )

      );



  }



}