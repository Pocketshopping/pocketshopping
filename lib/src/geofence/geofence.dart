import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:pocketshopping/src/geofence/package_geofence.dart';
import 'package:pocketshopping/src/geofence/reviewPlace.dart';
import 'package:pocketshopping/src/order/repository/orderRepo.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:pocketshopping/src/wallet/bloc/walletUpdater.dart';
import 'package:pocketshopping/src/wallet/repository/walletRepo.dart';
import 'package:progress_indicators/progress_indicators.dart';

class GeoFence extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GeoFenceState();
}

class _GeoFenceState extends State<GeoFence> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = const Icon(
    Icons.search,
    color: PRIMARYCOLOR,
  );
  Widget _appBarTitle = const Text(
    "PocketShopping",
    style: TextStyle(color: PRIMARYCOLOR, fontSize: 20),
  );

  String barcode = "";
  int _value = 0;
  int loader = 0;

  ScrollController _scrollController = new ScrollController();
  Session currentUser;
  GeoFenceBloc gBloc;
  //Stream<Wallet> _walletStream;
  //Wallet _wallet;
  List<bool> isSelected;

  @override
  void initState() {
    isSelected = [true, false];
    loader = 6;

    currentUser = BlocProvider.of<UserBloc>(context).state.props[0];
    gBloc = GeoFenceBloc();
    WalletRepo.getWallet(currentUser.user.walletId)
        .then((value) => WalletBloc.instance.newWallet(value));
    /*_walletStream = WalletBloc.instance.walletStream;
    _walletStream.listen((wallet) {
      if (mounted) {
        _wallet = wallet;
        setState(() {});
      }
    });*/
    //OrderRepo.getExpiredRequestBucket('304170436101').listen((event) { });
    Utility.locationAccess();
    super.initState();
  }


  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(
          Icons.close,
          color: PRIMARYCOLOR,
        );
        this._appBarTitle = TextFormField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search by Name...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.3),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              )),
        );
      } else {
        this._searchIcon = const Icon(
          Icons.search,
          color: PRIMARYCOLOR,
        );
        this._appBarTitle = const Text(
          "PocketShopping",
          style: TextStyle(color: PRIMARYCOLOR),
        );
      }
    });
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
  void dispose() {
    gBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return BlocProvider<GeoFenceBloc>(
      create: (context) => gBloc..add(NearByMerchant(category: 'Restuarant')),
      child: BlocBuilder<GeoFenceBloc, GeoFenceState>(
        builder: (context, state) {
          return DefaultTabController(
              length: 2,
              child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height * 0.3), // here the desired height
              child:  AppBar(
                  elevation: 0.0,
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(
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
                      preferredSize: Size.zero,
                      child: Container(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          //margin: EdgeInsets.only(bottom: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                height: height * 0.17,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: List<Widget>.generate(
                                    // psProvider.of(context).value['category'].length,
                                    state.categories.length,
                                        (int index) {
                                      return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            children: [
                                              FlatButton(
                                                child: CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: NetworkImage(
                                                      state.categories[index]
                                                          .categoryURI),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _value = index;
                                                  });
                                                  BlocProvider.of<GeoFenceBloc>(
                                                      context)
                                                      .add(NearByMerchant(
                                                      category: state
                                                          .categories[index]
                                                          .categoryName));
                                                },
                                              ),
                                              ChoiceChip(
                                                label: Text(
                                                  state.categories[index]
                                                      .categoryName,
                                                ),
                                                selected: _value == index,
                                                backgroundColor: Colors.white,
                                                onSelected: (bool selected) {
                                                  setState(() {
                                                    _value = index;
                                                  });
                                                  BlocProvider.of<GeoFenceBloc>(
                                                      context)
                                                      .add(NearByMerchant(
                                                      category: state
                                                          .categories[index]
                                                          .categoryName));
                                                },
                                                selectedColor: PRIMARYCOLOR,
                                                labelStyle:
                                                TextStyle(color: Colors.grey),
                                              )
                                            ],
                                          ));
                                    },
                                  ).toList(),
                                ),
                              ),
                              TabBar(
                                labelColor: PRIMARYCOLOR,
                                tabs: [
                                  const Tab(
                                    text: "Proximity",
                                  ),
                                  const Tab(
                                    text: "Reviews",
                                  ),
                                ],

                              ),
                            ],
                          ))),
                  title: _appBarTitle,
                  automaticallyImplyLeading: false,
                ),

            ),
            backgroundColor: Colors.white,
            body: TabBarView(
                children: [
            Container(
              padding: EdgeInsets.only(right: 10, left: 10),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: <Widget>[

                  if(state.isFailure)
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const  SizedBox(height: 10,),
                        Center(
                          child: Column(
                            children: [
                              Center(
                                child: Image.asset('assets/images/gpsError.png',
                                height:MediaQuery.of(context).size.height*0.3,
                                ),
                              ),
                             Padding(
                               padding: EdgeInsets.symmetric(vertical: 10,horizontal: 15),
                               child:  Text('Error Fetching GPS Cordinate ensure your GPS is '
                                   'enabled and full permission is granted to pocketshopping.',
                                 style: TextStyle(fontSize: 18,color: Colors.black54),
                               textAlign: TextAlign.center,),
                             ),
                              const SizedBox(height: 10,),
                              FlatButton.icon(
                                onPressed: (){
                                  gBloc.add(NearByMerchant(category: 'Restuarant'));
                                },
                                color: PRIMARYCOLOR,
                                icon: Icon(Icons.refresh,color: Colors.white,),
                                label: Text('Refresh',style: TextStyle(color: Colors.white),),
                              ),
                            ],
                          )
                        ),
                      ]
                      )
                  ),

                  if (state.isLoading)
                    SliverList(
                        delegate: SliverChildListDelegate([
                          const  SizedBox(height: 10,),
                      Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: MediaQuery.of(context).size.height * 0.12,
                          color: PRIMARYCOLOR,
                        ),
                      ),
                    ]
                        )
                    ),
                  if (state.isSuccess)
                    state.nearByMerchants.isNotEmpty
                        ? SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              child: Text(
                                '${state.category} within a 50km radius',
                                style: TextStyle(color: Colors.black54),
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              width: MediaQuery.of(context).size.width * 0.8,
                            ),
                          ]))
                        : SliverList(
                            delegate: SliverChildListDelegate([Container()]),
                          ),
                  if (state.isSuccess)
                    state.nearByMerchants.isNotEmpty
                        ? SliverGrid(
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
                                final page = SinglePlaceWidget(
                                  merchant: state.nearByMerchants[index],
                                  cPosition: GeoFirePoint(
                                      state.currentPosition.latitude,
                                      state.currentPosition.longitude),
                                  user: currentUser.user,
                                );
                                return page;
                              },
                              childCount: state.nearByMerchants.length,
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildListDelegate([
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Image.asset('assets/images/emptyPlace.png'),
                                  Text(
                                    'No ${state.category} within a 50km radius',
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          ])),

                  if (state.nearByMerchants.length > 9)
                    SliverList(
                        delegate: SliverChildListDelegate(
                      [
                        if (!state.isLoading)
                        Container(
                          color: Color.fromRGBO(246, 246, 250, 1),
                          //height: MediaQuery.of(context).size.height*0.2,
                          child: FlatButton(
                            onPressed: () => {
                              this.setState(() {
                                loader += 3;
                              }),
                              this._scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent +
                                      MediaQuery.of(context).size.height * 0.5,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeOut)
                            },
                            color: Colors.black12,
                            padding: EdgeInsets.all(0.0),
                            child: Column(
                              // Replace with a Row for horizontal icon + text
                              children: <Widget>[
                                const Text(
                                  "Load More",
                                  style: TextStyle(color: Colors.black54),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )),
                ],
              ),
            ),
                 review(state)
            ]
            )
          )


          );
        },
      ),
    );
  }

//@override
//void dispose() {
//context.bloc().close();
//super.dispose();
//}

Widget review(dynamic state){

    return Container(
          padding: EdgeInsets.only(right: 10, left: 10),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 50.0,
                backgroundColor: Colors.white,
                title:  Center(child: ToggleButtons(
                    borderColor: Colors.blue.withOpacity(0.5),
                    fillColor: Colors.blue,
                    borderWidth: 1,
                    selectedBorderColor: Colors.blue,
                    selectedColor: Colors.white,
                    borderRadius: BorderRadius.circular(0),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: const Text(
                          'Rating',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child:const Text(
                          'Reviews',
                        ),
                      ),
                    ],
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < isSelected.length; i++) {
                          isSelected[i] = i == index;
                        }
                      });
                    },
                    isSelected: isSelected,
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width,
                        minWidth: MediaQuery.of(context).size.width*0.25
                    ),
                  ),
                )
              ),

              if (state.isLoading)
                SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: JumpingDotsProgressIndicator(
                          fontSize: MediaQuery.of(context).size.height * 0.12,
                          color: PRIMARYCOLOR,
                        ),
                      ),
                    ]
                    )
                ),
              if (state.isSuccess)
                state.nearByMerchants.isNotEmpty
                    ? SliverList(
                    delegate: SliverChildListDelegate([
                      SizedBox(height: 20,),

                      Container(
                        child: Text(
                          '${state.category} within a 50km radius',
                          style: TextStyle(color: Colors.black54),
                        ),
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        width: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ]))
                    : SliverList(
                  delegate: SliverChildListDelegate([Container()]),
                ),
              if (state.isSuccess)
                state.nearByMerchants.isNotEmpty
                    ? SliverGrid(
                  gridDelegate:
                  SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: MediaQuery.of(context).size.width,
                    //maxCrossAxisExtent :200,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    childAspectRatio: 2,
                  ),
                  delegate: new SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      final page = ReviewPlaceWidget(
                        merchant: state.nearByMerchants[index],
                        cPosition: GeoFirePoint(
                            state.currentPosition.latitude,
                            state.currentPosition.longitude),
                        user: currentUser.user,
                      );
                      return page;
                    },
                    childCount: state.nearByMerchants.length,
                  ),
                )
                    : SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset('assets/images/emptyPlace.png'),
                            Text(
                              'No ${state.category} within a 50km radius',
                              style: TextStyle(color: Colors.black54),
                            )
                          ],
                        ),
                      ),
                    ])),

              if (state.nearByMerchants.length > 9)
                SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (!state.isLoading)
                          Container(
                            color: Color.fromRGBO(246, 246, 250, 1),
                            //height: MediaQuery.of(context).size.height*0.2,
                            child: FlatButton(
                              onPressed: () => {
                                this.setState(() {
                                  loader += 3;
                                }),
                                this._scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent +
                                        MediaQuery.of(context).size.height * 0.5,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOut)
                              },
                              color: Colors.black12,
                              padding: EdgeInsets.all(0.0),
                              child: Column(
                                // Replace with a Row for horizontal icon + text
                                children: <Widget>[
                                  const Text(
                                    "Load More",
                                    style: TextStyle(color: Colors.black54),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    )),
            ],
          ),

    );
}
}