import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/fav/repository/favItem.dart';
import 'package:pocketshopping/src/user/fav/repository/favRepo.dart';
import 'package:pocketshopping/src/user/fav/singleFavWidget.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';

class FavoriteWidget extends StatefulWidget {
  Session user;
  FavoriteWidget({@required this.user});

  @override
  State<StatefulWidget> createState() => _FavoriteState();
}

class _FavoriteState extends State<FavoriteWidget> {

  bool loading;
  List<bool> isSelected;
  List<FavItem> fav;
  Position position;

  @override
  void initState() {
    isSelected = [true, false];
    loading = false;
    FavRepo.getFavourites(widget.user.user.uid,'count').then((value) { if(mounted)setState((){fav=value.favourite.values.toList();});});
    Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high,
        locationPermissionLevel: GeolocationPermission.locationAlways).then((value)
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
    return fav != null?
    fav.isNotEmpty?
    Container(
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
                            fav=null;
                            if(isSelected[0]){
                              FavRepo.getFavourites(widget.user.user.uid,'count').then((value) => setState((){fav=value.favourite.values.toList();}));
                            }
                            else{
                              FavRepo.getFavourites(widget.user.user.uid,'visitedAt').then((value) => setState((){fav=value.favourite.values.toList();}));
                            }
                          });
                        },
                        isSelected: isSelected,
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width,
                            minWidth: MediaQuery.of(context).size.width*0.4),
                      ),
                    ],
                  ),



              ])),
          SliverGrid(
            gridDelegate:
            SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent:
              MediaQuery.of(context).size.width * 0.5,
              //maxCrossAxisExtent :200,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio: 1,
            ),
            delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final page = SingleFavoriteWidget(item:fav[index],
                    position:position,user: widget.user.user,);
                return page;
              },
              childCount: fav.length,
            ),
          )
        ]
    )
    ):Center(
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
                    fontSize: MediaQuery.of(context).size.height * 0.06),
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

    ):Center(
        child: JumpingDotsProgressIndicator(
        fontSize: MediaQuery.of(context).size.height * 0.12,
    color: PRIMARYCOLOR,
        ));
  }
}