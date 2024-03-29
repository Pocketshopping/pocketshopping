import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/favObj.dart';
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/fav/singleFavWidget.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class FavoriteWidget extends StatefulWidget {
  final Session user;
  FavoriteWidget({@required this.user});

  @override
  State<StatefulWidget> createState() => _FavoriteState();
}

class _FavoriteState extends State<FavoriteWidget> {

  bool loading;
  List<bool> isSelected;
  String type;
  Position position;

  @override
  void initState() {
    isSelected = [true, false];
    loading = false;
    type = 'count';
    //FavRepo.getFavourites(widget.user.user.uid,'count').then((value) { if(mounted)setState((){fav=value.favourite.values.toList();});});
    getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((value)
        {
          if(mounted)
            setState((){position=value;});
        }
    );

    //visitedAt
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print(fav.favourite);
    return position != null?FutureBuilder(
      future: FavRepo.getFavourites(widget.user.user.uid,type,),
      builder: (context,AsyncSnapshot<Favourite> snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
          return Center(
              child: JumpingDotsProgressIndicator(
                fontSize: Get.height * 0.12,
                color: PRIMARYCOLOR,
              ));
        }
        else if(snapshot.hasError){
          return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Error communicating with server check internet connection and try again.')
              )
          );
        }
        else {
          if(snapshot.data.favourite.values.toList().isNotEmpty){
            return Container(
              //padding: EdgeInsets.only(right: 10, left: 10),
                child: CustomScrollView(
                    slivers: <Widget>[
                      SliverList(
                          delegate: SliverChildListDelegate([
                            SizedBox(
                              height: 10,
                            ),

                            Column(
                              //mainAxisAlignment: MainAxisAlignment,
                              children: <Widget>[
                                ToggleButtons(
                                  borderColor: Colors.blue.withOpacity(0.5),
                                  fillColor: Colors.blue,
                                  borderWidth: 1,
                                  selectedBorderColor: Colors.blue,
                                  selectedColor: Colors.white,
                                  borderRadius: BorderRadius.circular(0),
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'Most Visited',
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'Last Visited',
                                      ),
                                    ),
                                  ],
                                  onPressed: (int index) {
                                    setState(() {
                                      for (int i = 0; i < isSelected.length; i++) {
                                        isSelected[i] = i == index;
                                      }
                                      if(isSelected[0]){
                                          type = 'count';
                                      }
                                      else{
                                        type = 'visitedAt';
                                      }
                                      setState(() {});
                                    });
                                  },
                                  isSelected: isSelected,
                                  constraints: BoxConstraints(
                                      maxWidth: Get.width,
                                      minWidth: Get.width*0.4),
                                ),
                              ],
                            ),



                          ])),
                      SliverGrid(
                        gridDelegate:
                        SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent:
                          Get.width * 0.5,
                          //maxCrossAxisExtent :200,
                          mainAxisSpacing: 5.0,
                          crossAxisSpacing: 5.0,
                          childAspectRatio: 1,
                        ),
                        delegate: new SliverChildBuilderDelegate(
                              (BuildContext context, int index) {
                            final page = SingleFavoriteWidget(item:snapshot.data.favourite.values.toList()[index],
                              position:position,user: widget.user.user,);
                            return page;
                          },
                          childCount: snapshot.data.favourite.values.toList().length,
                        ),
                      )
                    ]
                )
            );
          }
          else{
            return Center(
              child: ListTile(
                title: Image.asset('assets/images/empty.gif'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        'Empty',
                        style: TextStyle(
                            fontSize: Get.height * 0.06),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "Looks like you are yet to use pocketshopping.",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

            );
          }
        }
      },
    ):
    Center(
        child: JumpingDotsProgressIndicator(
          fontSize: Get.height * 0.12,
          color: PRIMARYCOLOR,
        ));
  }
}