import 'package:flutter/material.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/page/setUpBusiness.dart';
import 'package:pocketshopping/page/user.dart';


class BusinessSetUpPage extends StatefulWidget {
  static String tag = 'BusinessSetUp-page';
  @override
  _BusinessSetUpPageState createState() => new _BusinessSetUpPageState();
}

class _BusinessSetUpPageState extends State<BusinessSetUpPage> {

  @override
  Widget build(BuildContext context) {
    double marginLR =  MediaQuery.of(context).size.width;

    final profile = Hero(
      tag: 'hero',
      child: Column(children: <Widget>[
          Image.asset('assets/images/entrepreneurs.png',
          height: MediaQuery.of(context).size.height*0.4,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,),
          SizedBox(height: 10,),
          Text(
        'Do you want to add a business to pocketshopping',
        style: TextStyle(color: Colors.black54,fontSize: 16.0),
      ),
      ],),
    );

    

    

 

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: marginLR*0.008),
      child: RaisedButton(

        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>FirstBusinessPage()));

        },
        padding: EdgeInsets.all(12),
        color: PRIMARYCOLOR,
        child: Text('Yes! Add a business', style: TextStyle(color: Colors.white)),
      ),
    );

    final loginLabel =Padding(
      padding: EdgeInsets.symmetric(vertical: marginLR*0.008),
      child: RaisedButton(
        /*shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),*/
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>UserPage()));
        },
        padding: EdgeInsets.all(12),
        color: PRIMARYCOLOR.withOpacity(0.5),
        child: Text('No! Am okay as a user', style: TextStyle(color: Colors.white)),
      ),
    );

  final fields=Container(
    padding: EdgeInsets.only(left: marginLR*0.1, right: marginLR*0.1),
      child:Column(
         // shrinkWrap: true,
          //
          children: <Widget>[
            profile,
            SizedBox(height: 24.0),
            loginButton,
            loginLabel
          ],

  ),
    );

    return WillPopScope(
        onWillPop: () async => false,
    child:Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 0, right: 0),
          children: <Widget>[
            fields,
          ],
        ),
      ),
    )
    );
  }
}


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
    child: Text("Please do well to read our terms and conditions. What do you want to do",style: TextStyle(fontSize: 18),),
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

class ExistingBusiness extends StatefulWidget {
  static String tag = 'ExistingBusinessSetUp-page';
  @override
  _ExistingBusinessState createState() => new _ExistingBusinessState();
}

class _ExistingBusinessState extends State<ExistingBusiness>{
  final Color themecolor;
  final String cover;
  _ExistingBusinessState({this.themecolor=PRIMARYCOLOR,this.cover=PocketShoppingDefaultCover});
  final _formKey = GlobalKey<FormState>();
  var _bidController = TextEditingController();
  bool loading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading=false;
  }

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

      body: Builder(
      builder: (ctx) =>
      CustomScrollView(
          slivers: <Widget>[SliverList(
            delegate: SliverChildListDelegate(
                [
                  Container(height: MediaQuery.of(context).size.height*0.02,),
                  psCard(
                    color: themecolor,
                    title: 'New Branch',
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        //offset: Offset(1.0, 0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                    child:Form(
                      key: _formKey,
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
                            child: Text("To create a branch you need to request for branch link from the exisiting"
                                " business, once recieved you can create branch by visiting the link. Please do well to read our terms and conditions"
                                "",style: TextStyle(fontSize: 16),),
                          )),
                          ]
                    ),
                    )
                  )
                ]
            )
        ),
    ]
      )
      )
    );

  }
}
