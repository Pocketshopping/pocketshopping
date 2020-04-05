import 'package:flutter/material.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/page/user/menu.dart';
import 'package:pocketshopping/page/user/product.dart';
import 'package:pocketshopping/component/dialog.dart';
import 'package:pocketshopping/page/map.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:badges/badges.dart';
import 'package:pocketshopping/page/user/drawer.dart';
import 'package:pocketshopping/widget/bSheetMapTemplate.dart';
import 'package:pocketshopping/widget/bSheetCartWidget.dart';
import 'package:pocketshopping/widget/bSheetMessageWidget.dart';
import 'package:pocketshopping/widget/bSheetReviewWidget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pocketshopping/widget/bSheetSocialWidget.dart';

class MerchantWidget extends StatefulWidget {
  static String tag = 'Merchant-page';
  MerchantWidget({
    this.data,
    this.page,

  });
  final Map data;
  final Function page;
  @override
  _MerchantWidget createState() => new _MerchantWidget();
}


  class _MerchantWidget extends State<MerchantWidget> {


      String _status;
      PaletteColor color;
      GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
      String coverImage;
      int _cartCount;
      int loadmore=0;
      ScrollController _scrollController = new ScrollController();

      @override
      void initState(){
        super.initState();
        _status = 'open';
        color= PaletteColor(Color(0xff33805D),2);
        coverImage=widget.data['cover'];
        _updatePalettes();
        loadmore=6;
      }

      void _incrementcartCount(){
        setState(() {
          _cartCount +=1;
        });

      }

      void _decrementCartCount(){
        setState(() {
          _cartCount -=1;
        });
      }

      _updatePalettes() async{
        final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
          NetworkImage(widget.data['cover']),
          size:  Size(200,200),

        );
        //print(generator.paletteColors.toString());
        color = generator.paletteColors.isNotEmpty?getDarkest(generator.paletteColors):PaletteColor(const Color(0xff33805D),2);

        setState(() {});

      }

      PaletteColor getDarkest(List<PaletteColor> colors){
        double heighest=0.6;
        PaletteColor pcolor;
        for(int i=0; i<colors.length;i++){
          double temp  = colors[i].color.computeLuminance();
          if (temp < heighest) {
            pcolor = colors[i];
            break;

          }
        }

        return pcolor;
      }

      void running(){
        print ("sdsd");
      }


      @override
      Widget build(BuildContext context) {

        Widget pageMaker(){
          return widget.page();
        }

        return Scaffold(
          key: _scaffoldKey,
          drawer:  DrawerWidget(),
          body:Builder(
          builder: (context) =>
            Container(

            height: MediaQuery.of(context).size.height,
            child:
             Stack(
              children: <Widget>[
                Container(

               decoration: BoxDecoration(
              color: const Color(0xff000000),
            image: DecorationImage(
            image: NetworkImage(coverImage),

            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.dstATop),
            //colorFilter: Colors.black.withOpacity(0.4),

          ),
        ),
        child:
        Container(
        child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
      Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(children: <Widget>[
        FittedBox(fit: BoxFit.contain,child:
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30,
            color:  const Color(0xffffffff),
          ),
          onPressed: () {
            //print("your menu action here");
            Navigator.of(context).pop();
          },
        ),
        ),
          Text(
          'Title',
          style: TextStyle(fontSize:30.0,color:Colors.white,fontWeight: FontWeight.w700,),

          ),
      ],)
        ),
       Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child:  Text(
      '(Sub Title)',
      style: TextStyle(color: Colors.white, fontSize: 14.0),
    ),
        ),

  ]),


        height: MediaQuery.of(context).size.height*0.25,
        width: MediaQuery.of(context).size.width,

  ),


                ),
                Positioned(
                  top: MediaQuery.of(context).size.height*0.21,
                  left: 0.0,
                  right: 0.0,
                  child: Container(

                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1.0),
                          border: Border.all(
                              color: Colors.grey.withOpacity(0.5), width: 1.0),
                          color: Colors.white),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: color == null? const Color(0xff000000): color.color,
                            ),
                            onPressed: () {
                              //print(context);

                              Scaffold.of(context).openDrawer();
                            },
                          ),
                          Expanded(

                            child: TextField(


                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(left: 10.0),
                                border: InputBorder.none,
                                hintText: widget.data['title'] != null ?"Search "+widget.data['title']:'Search This Merchant',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              color: color == null? const Color(0xff000000): color.color,
                            ),
                            onPressed: () {
                             Navigator.of(context).pushNamed(MapSample.tag);
                            },
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.place,
                              color: color == null? const Color(0xff000000): color.color,
                            ),
                            onPressed: () {
                              //dialog(context,{'title':'info',}).showMerchantMap();
                              showBottomSheet(
                                context: context,
                                   builder: (context) =>
                                   BottomSheetMapTemplate()
                              );
                            },
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.28,left: 5,right:5),
                   width: MediaQuery.of(context).size.width,
                  child:
                  CustomScrollView(
                    controller: _scrollController,
                      slivers: <Widget>[
                        SliverList(
                            delegate: SliverChildListDelegate(

                              [
                                Container(
                                  //padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                          children:<Widget>[
                                            FittedBox(fit: BoxFit.contain,child: IconButton(
                                              icon: Icon(
                                                Icons.call,
                                                color: color == null? const Color(0xff000000): color.color,
                                              ),
                                              onPressed: () {
                                                dialog(context,{'title':'info',}).showMerchantMap();
                                              },
                                            ),),
                                            FittedBox(fit: BoxFit.contain,child:RatingBar(
                                              onRatingUpdate: (rate){},
                                              initialRating: 3.5,
                                              minRating: 1,
                                              maxRating: 5,
                                              itemSize: MediaQuery.of(context).size.width*0.08,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                                              itemBuilder: (context, _)=>Icon(Icons.star, color: Colors.amber,),

                                            )),
                                            FittedBox(fit: BoxFit.contain,child:IconButton(
                                              icon: Icon(
                                                FontAwesome5.address_card,
                                                color: color == null? const Color(0xff000000): color.color,
                                              ),
                                              onPressed: () {
                                                showBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        BottomSheetSocialWidget()
                                                );
                                              },
                                            )
                                            ),

                                            FittedBox(fit: BoxFit.contain,child:IconButton(
                                              icon: Icon(
                                                Icons.message,
                                                color: color == null? const Color(0xff000000): color.color,
                                              ),
                                              onPressed: () {

                                                showBottomSheet(
                                                    context: context,
                                                    builder: (context) =>
                                                        BottomSheetMessageWidget()
                                                );

                                              },
                                            )
                                            ),

                                          ]
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(top: 5,bottom: 5,left: 20,right: 20),
                                        width: MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[

                                             Expanded(
                                               flex:1,
                                                 child:Container(
                                               color:Colors.white,
                                        alignment: Alignment.center,
                                        child: Container(
                                                width: MediaQuery.of(context).size.width*0.16,
                                                height: MediaQuery.of(context).size.height*0.08,
                                                alignment: Alignment.center,

                                                decoration: new BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                    image: new DecorationImage(
                                                        fit: BoxFit.fill,
                                                        image: new NetworkImage(
                                                            "https://i.imgur.com/BoN9kdC.png")
                                                    )
                                                )

                                           )
                                             )
                                        ),

                                           Expanded(
                                             flex: 3,
                                             child:Container(
                                               padding: EdgeInsets.only(left: 10),
                                              child: Column(
                                                children: <Widget>[
                                                 Align(alignment:Alignment.centerLeft,child: Text("Abiodun Musa Emeka")),
                                                  Center(
                                                    child: Text("My app was running good I just update the "
                                                        "code in one file and I am receiving this "
                                                        "error before that error every page was "
                                                        "navigating perfectly and now all the pages "
                                                        "are good to work instead of this page I "
                                                        "am navigating".substring(0,100)+"..."),
                                                  ),
                                                  ],
                                              ),
                                            )
                                           )

                                          ],
                                        )
                                      ),
                                      Align(alignment:Alignment.center, child:FlatButton(
                                        onPressed: (){
                                          showBottomSheet(
                                              context: context,
                                              builder: (context) =>
                                                  BottomSheetReviewWidget()
                                          );
                                        },
                                        child: Text("See More reviews"),
                                      )),
                                    ],
                                  )



                                ),
                              ],
                            )
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            height: MediaQuery.of(context).size.height*0.1,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: MediaQuery.of(context).size.width*0.3,
                                  child: Card(
                                    child: MenuWidget(color == null? const Color(0xff000000): color.color),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SliverList(
                            delegate: SliverChildListDelegate(
                                [
                                  Container(
                                    margin: EdgeInsets.only(bottom: 2.0),
                                    child: Align(
                                      child: Text("Sowing Food"),
                                    ),
                                  )
                                ])),

                        SliverGrid(
                          gridDelegate:
                          SliverGridDelegateWithMaxCrossAxisExtent(

                            maxCrossAxisExtent: MediaQuery.of(context).size.width*0.5,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                            childAspectRatio: 0.8,


                          ),
                          delegate: new SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              return ProductWidget(
                                  PRIMARYCOLOR
                              );
                            },
                            childCount: loadmore,
                          ),
                        ),

                        SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Container(
                                  color: Colors.white,
                                  //height: MediaQuery.of(context).size.height*0.2,
                                  child: FlatButton(
                                    onPressed: () => {
                                      
                                      this.setState(() {loadmore +=6;}),
                                   this. _scrollController.animateTo(_scrollController.position.maxScrollExtent
                                    +MediaQuery.of(context).size.height*0.5
                                    , duration: const Duration(milliseconds: 500), curve: Curves.easeOut)
                                    },
                                    color: Colors.black12,
                                    padding: EdgeInsets.all(10.0),
                                    child: Column( // Replace with a Row for horizontal icon + text
                                      children: <Widget>[
                                        Text("Load More",style: TextStyle(color: Colors.black54),),
                                      ],
                                    ),
                                  ),

                                ),
                              ],
                            )
                        ),

                      ]
                  )

             ),
              ],
            ),

          ),
          ),


          floatingActionButton:Builder(
              builder: (context) => FloatingActionButton(
            onPressed: (){


              showBottomSheet(
                  context: context,
                  builder: (context) =>
                  BottomSheetCartWidget()
              );


            },
            backgroundColor: color.color,
            tooltip: 'Increment',
            child:_cartCount>0 ? Badge(
              badgeContent: Text(_cartCount.toString(),style: TextStyle(color:Colors.white),),
              child: Icon(Icons.shopping_cart),
            ):Icon(Icons.shopping_cart),

          )),


          
        );
      }
    }


