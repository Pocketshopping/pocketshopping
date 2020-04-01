import 'package:flutter/material.dart';
import 'package:pocketshopping/page/user/place.dart';
import 'package:pocketshopping/util/data.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:pocketshopping/widget/bSheetSearchWidget.dart';

class Favourite extends StatefulWidget {
  //static String tag = 'User-page';
  Favourite({this.session_,this.themeColor});
  final session session_;
  final Color themeColor;
  @override
  _FavouriteState createState() => new _FavouriteState();
}
class _FavouriteState  extends State<Favourite> {

  ScrollController _scrollController = new ScrollController();
  PaletteColor color;
  String coverImage;
  int _value = 1;
  int loader=0;
  String filter='';
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
  List<String> filterItems=['Proximity','Rate','Visit'];


  @override
  void initState(){
    super.initState();
    color= PaletteColor(widget.themeColor,2);
    coverImage='https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcR_6b3C9f_GUEM_kNQYmLmcBH9kC-xvbs4whyuWPl7Di86BTBvo';
    loader=6;
    filter='Proximity';
    _updatePalettes();
  }

  _updatePalettes() async{
    final PaletteGenerator generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(coverImage),
        size:  Size(200,200)
    );
    color = generator.dominantColor != null?
    generator.dominantColor.color.computeLuminance()<0.5?
    generator.dominantColor:generator.paletteColors.isNotEmpty?getDarkest(generator.paletteColors):
    PaletteColor(const Color(0xff33805D),2):PaletteColor(const Color(0xff33805D),2);
    setState(() {});
    widget.session_.fcolorsetter(color == null? const Color(0xff000000): color.color);
  }

  PaletteColor getDarkest(List<PaletteColor> colors){
    double heighest=0.5;
    PaletteColor pcolor;
    colors.forEach((color) {
      double temp  = color.color.computeLuminance();
      if (temp < heighest) {
        heighest = temp;
        pcolor = color;
      }


    });
    return pcolor;
  }




  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: <Widget>[
          Container(
            color: color.color,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height*0.15,
            child: Center(
              child: Image.asset('assets/images/wlogo.png',
                height: MediaQuery.of(context).size.height*0.08,
                width: MediaQuery.of(context).size.width*0.5,
                fit: BoxFit.contain,),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.115,
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
                        color: color.color,
                      ),
                      onPressed: () {
                        //print("your menu action here");
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                    Expanded(

                      child: TextField(
                        onTap: (){
                          showBottomSheet(
                            context: context,
                            builder: (context) {
                              return BottomSheetSearchWidget(
                                height: MediaQuery.of(context).size.height*0.73,
                                child: Container(),
                              );
                            },

                          );
                        },
                        onChanged:(text){

                        } ,
                        decoration: InputDecoration(
                          hintText: "Search Pocketshopping",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.search,
                        color: color.color,
                      ),
                      onPressed: () {
                        print("your menu action here");
                      },
                    ),

                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.18),
            alignment: Alignment.topCenter,
            child: Column(

              children:<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection:Axis.horizontal,
                        child: Wrap(
                          spacing: 2.0,
                          children: List<Widget>.generate(
                            7,
                                (int index) {
                              return ChoiceChip(

                                label: Text('Amala_Item $index',style: TextStyle(fontSize: 12),),
                                selected: _value == index,
                                onSelected: (bool selected) {
                                  setState(() {
                                    _value = selected ? index : null;
                                  });
                                },
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: (){},
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),

                Container(
                  margin: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05,right: MediaQuery.of(context).size.width*0.05),
                  child: Row(
                    children: <Widget>[

                      Expanded(
                          flex: 1,
                          child: DropdownButtonHideUnderline (
                            child: DropdownButton<String>(

                              value: filter,

                              icon: Icon(Icons.arrow_downward),
                              iconSize: 14,
                              elevation: 16,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 12),



                              onChanged: (String newValue) {
                                setState(() {
                                  filter = newValue;
                                });
                                Navigator.pop(context);
                              },
                              items: filterItems
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              })
                                  .toList(),
                            ),
                          )
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text("24 Places within 1km radius",style: TextStyle(fontSize: 12),),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  //width: MediaQuery.of(context).size.width,
                  //height: 3000,

                  child:CustomScrollView(
                    controller: _scrollController,
                    slivers: <Widget>[





                      SliverList(

                          delegate: SliverChildListDelegate(
                              [
                               // FirstMerchant(image: covers[2],themeColor: color.color,),
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height*0.01,
                                      bottom:MediaQuery.of(context).size.height*0.008,
                                    ),
                                    child: Text("Other places around you",style: TextStyle(fontSize: 12),),
                                  ),
                                ),


                              ]
                          )
                      ),

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
                            return SinglePlaceWidget(
                                themeColor:color.color,mData:{'title':'Amala Place'+index.toString(),'cover':covers[index%loader]});
                          },
                          childCount: loader,
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

                )

              ],
            ),

          ),

        ],
      ),


    );
  }
}


