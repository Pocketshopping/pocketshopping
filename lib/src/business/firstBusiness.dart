import 'package:flutter/material.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/business/business.dart';


class FirstBusinessPage extends StatelessWidget{
  final Color themecolor;
  final String cover;
  FirstBusinessPage({this.themecolor=PRIMARYCOLOR,this.cover=PocketShoppingDefaultCover});
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: Colors.white,

        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.1), // here the desired height
          child: AppBar(
            centerTitle: true,
            elevation:0.0,
            backgroundColor: Colors.white,
            leading: IconButton(

              icon: Icon(Icons.arrow_back_ios,color:PRIMARYCOLOR,
              ),
              onPressed: (){
                Navigator.pop(context);
              },
            ) ,
            title:Text("Business Setup",style: TextStyle(color: PRIMARYCOLOR),),

            automaticallyImplyLeading: false,
          ),
        ),

        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
                delegate: SliverChildListDelegate(
                    [
                      Container(height: MediaQuery.of(context).size.height*0.02,),
                      psCard(
                        color: themecolor,
                        title: 'New Business',
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Center(child:Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide( //                   <--- left side
                                      color: Colors.black12,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                child: Text("Please do well to read our terms and conditions. What do you want to do",style: TextStyle(),),
                              )),
                              Center(child:Container(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                child: FlatButton(
                                  onPressed: (){

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>SetupBusiness()));
                                  },
                                  color: themecolor,
                                  child: Text("Create a new business",style: TextStyle(color: Colors.white),),
                                ),
                              )),
                              Container(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                child: Center(child:Text("Or",style: TextStyle(fontSize: 18),)),
                              ),
                              Center(child:Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide( //                   <--- left side
                                      color: Colors.black12,
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                child: FlatButton(
                                  onPressed: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>ExistingBusiness()));
                                  },
                                  color: themecolor,
                                  child: Text("Create a new branch for existing business",style: TextStyle(color: Colors.white),),
                                ),
                              )),



                            ]
                        ),
                      )
                    ]
                )
            )
          ],
        )
    );

  }
}