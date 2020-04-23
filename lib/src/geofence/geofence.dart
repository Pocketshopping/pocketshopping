import 'package:badges/badges.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/user/package_user.dart';


class GeoFence extends StatefulWidget{


  @override
  State<StatefulWidget> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence>{

  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search,color: PRIMARYCOLOR,);
  Widget _appBarTitle = new Text("PocketShopping",style: TextStyle(color: PRIMARYCOLOR,fontSize: 20), );
  ViewModel vmodel;
  String barcode = "";
  int _value=0;
  int loader=0;
  List<String> categories =[];
  ScrollController _scrollController = new ScrollController();
  Session CurrentUser;
  List<String> covers =[
    'https://cdn.dribbble.com/users/230290/screenshots/5574626/crisp_drb.jpg',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR_6b3C9f_GUEM_kNQYmLmcBH9kC-xvbs4whyuWPl7Di86BTBvo',
    'https://www.cometonigeria.com/wp-content/uploads/Vanilla-logo.jpg',
    'https://theprofficers.com/wp-content/uploads/2015/02/uncle-ds-restaurant-logo-e1554529462345.png',
    'https://nightlife.ng/wp-content/uploads/2018/04/n6pa.jpg',
    'https://jevinik.com.ng/images/logo.png',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSrqjg3uWWgw6gMSi7R4TVqxvlWI0i_0KZi4BLTDA9rVBbQQq3o',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcRSarwgXmjE7GBzd-riLX8dnxuqbssaJ-U3xrGPHzmTrZ3kTyE6',
    'https://lh3.googleusercontent.com/P008O2T_gGAda0C3qDi91Zi8w0H3bLg2ooQAHep4MZC5R3k0PW_k_WPTJbQPgYZonWjnbfON=s1280-p-no-v1'

  ];

  @override
  void initState() {

    super.initState();
    loader=6;
    categories=['Restuarant','Bar'];
    CurrentUser = BlocProvider.of<UserBloc>(context).state.props[0];


  }

  setCategory()async{
    await CategoryData().getAll().then((value) => {
      categories.addAll(value),
      setState(() { })
    });
    //print(categories.length);
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
        this._searchIcon =  Icon(Icons.close,color: PRIMARYCOLOR,);
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
        this._searchIcon =  Icon(Icons.search,color: PRIMARYCOLOR,);
        this._appBarTitle =  Text("PocketShopping",style: TextStyle(color: PRIMARYCOLOR),);

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
                            FittedBox(fit:BoxFit.contain,child:Icon(Icons.camera,color: Colors.green, size: MediaQuery.of(context).size.height*0.1,)),
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


  _GeoFenceState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";

        });
      } else {
        setState(() {
          _searchText = _filter.text;
          print(_searchText);
        });
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    double height=MediaQuery.of(context).size.height;
    return BlocProvider<GeoFenceBloc>(
      create: (context) => GeoFenceBloc()..add(NearByMerchant(category: 'Restuarant')),
      child: BlocBuilder<GeoFenceBloc,GeoFenceState>(
        builder: (context,state){
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.2), // here the desired height
              child: AppBar(
                elevation: 0.0,
                centerTitle: true,
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: PRIMARYCOLOR,
                  ),
                  onPressed: () {
                    //print("your menu action here");
                    Scaffold.of(context).openDrawer();
                  },
                ),
                actions: <Widget>[
                  IconButton(
                    icon: _searchIcon,
                    onPressed: _searchPressed,

                  ),
                ],
                bottom: PreferredSize(
                    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15),
                    child: Container(
                        padding: EdgeInsets.only(left: 10,right: 10),
                        //margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Categories", style: TextStyle(fontSize: height*0.04,fontWeight:
                                FontWeight.bold),),
                                Badge(
                                    badgeContent: Text('1',style: TextStyle(color:Colors.white),),
                                    position: BadgePosition.topRight(top:1, right: 1),
                                    child: IconButton(
                                      onPressed: (){},
                                      color: Colors.grey,
                                      icon: Icon(Icons.shopping_basket,size: height*0.05,),
                                    )
                                ),


                              ],
                            ),
                            Container(
                              height: height*0.06,
                              child:
                              ListView(
                                scrollDirection: Axis.horizontal,
                                children: <Widget>[
                                  Wrap(
                                    spacing: 2.0,
                                    children: List<Widget>.generate(
                                      // psProvider.of(context).value['category'].length,
                                      state.categories.length,
                                          (int index) {
                                        return ChoiceChip(

                                          label: Text(
                                              state.categories[index]
                                              ,style: TextStyle(color:
                                          Colors.grey)),

                                          selected: _value == index,
                                          backgroundColor: Colors.white,
                                          onSelected: (bool selected) {
                                            setState(() {
                                              _value = selected ? index : null;
                                            });
                                            print('index: ${ state.categories[index]}');

                                            BlocProvider.of<GeoFenceBloc>(context)
                                            .add(NearByMerchant(
                                            category: state.categories[index]
                                            ));


                                          },
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                            )

                          ],
                        )
                    )
                ),

                title:_appBarTitle,

                automaticallyImplyLeading: false,
              ),
            ),
            backgroundColor: Colors.white,
            body: Container(
              padding: EdgeInsets.only(right: 10,left: 10),
              child: CustomScrollView(
                controller: _scrollController,

                slivers: <Widget>[

                  if (state.isLoading)
          SliverList(
          delegate: SliverChildListDelegate(
          [
                    SizedBox(height: 20,),
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ]
          )
          ),

                  if (state.isSuccess)
                    state.nearByMerchants.isNotEmpty?
                    SliverList(
                        delegate: SliverChildListDelegate(
                            [
                              Container(
                                child: Text('${state.category} within a 50km radius',
                                style: TextStyle(color: Colors.black54),),
                                margin: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                width: MediaQuery.of(context).size.width*0.8,

                              ),
                            ]
                        )
                    ):SliverList(delegate: SliverChildListDelegate([Container()]),),

                  if (state.isSuccess)
                    state.nearByMerchants.isNotEmpty?
                  SliverGrid(
                    gridDelegate:
                    SliverGridDelegateWithMaxCrossAxisExtent (
                      maxCrossAxisExtent: MediaQuery.of(context).size.width*0.5,
                      //maxCrossAxisExtent :200,
                      mainAxisSpacing: 5.0,
                      crossAxisSpacing: 5.0,
                      childAspectRatio: 1,
                    ),
                    delegate: new SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final page = SinglePlaceWidget(
                              merchant: state.nearByMerchants[index],
                              cPosition: GeoFirePoint(
                                  state.currentPosition.latitude,
                                  state.currentPosition.longitude
                              ),
                              user: CurrentUser.user,

                            );
                        return page;
                      },
                      childCount: state.nearByMerchants.length,
                    ),
                  ):
          SliverList(
          delegate: SliverChildListDelegate(
          [
            Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/images/emptyPlace.png'),
                          Text('No ${state.category} within a 50km radius',
                          style: TextStyle(color: Colors.black54),)
                        ],

                        ),
                      ),

          ]
          )
          ),
                  if (state.nearByMerchants.length>9)
                  SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Container(
                            color: Color.fromRGBO(246, 246, 250, 1),
                            //height: MediaQuery.of(context).size.height*0.2,
                            child: FlatButton(
                              onPressed: () => {
                                this.setState(() {loader +=3;}),
                                this. _scrollController.animateTo(_scrollController.position.maxScrollExtent
                                    +MediaQuery.of(context).size.height*0.5
                                    , duration: const Duration(milliseconds: 500), curve: Curves.easeOut)
                              },
                              color: Colors.black12,
                              padding: EdgeInsets.all(0.0),
                              child: Column( // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  Text("Load More",style: TextStyle(color: Colors.black54),)
                                ],
                              ),
                            ),

                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),

          );
        },
      ),
    );


  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

class ChatBubbleTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xFF486993);

    var path = Path();
    path.lineTo(-15, 0);
    path.lineTo(0, -15);
    path.lineTo(0, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/*


SliverList(
delegate: SliverChildListDelegate(
[


Padding(
padding: EdgeInsets.all(7),
child: Align(
alignment: Alignment.centerRight,
child: Stack(
children: [
Container(
padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
decoration: BoxDecoration(
color: Color(0xFF486993),
borderRadius: BorderRadius.all(Radius.circular(20)),
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: <Widget>[
RichText(
text: TextSpan(
children: <TextSpan>[
TextSpan(
text:state.isSuccess? state.nearByMerchants.isNotEmpty?'${state.category} near you  ':'ouch no ${state.category} near you  ':'Fetching nearby merchants.. please wait',
style: TextStyle(
color: Colors.white,
fontSize: 14.0
),
),
TextSpan(
text: '3:16 PM',
style: TextStyle(
color: Colors.grey,
fontSize: 12.0,
fontStyle: FontStyle.italic
),
),
],
),
),
Icon(Icons.check, color: Color(0xFF7ABAF4), size: 16,)
]
),
),
Positioned(
bottom: 0,
right: 0,
child: CustomPaint(
painter: ChatBubbleTriangle(),
)
)
]
)
),
),



]
)
),*/
