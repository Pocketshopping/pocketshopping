import 'package:badges/badges.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/page/user/place.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';

class LocationUI extends StatefulWidget {
  final Color themeColor;

  LocationUI({this.themeColor});

  @override
  State<StatefulWidget> createState() => _LocationUIState();
}

class _LocationUIState extends State<LocationUI> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(
    Icons.search,
    color: PRIMARYCOLOR,
  );
  Widget _appBarTitle = new Text(
    "PocketShopping",
    style: TextStyle(color: PRIMARYCOLOR),
  );
  ViewModel vmodel;
  String barcode = "";
  int _value = 0;
  int loader = 0;
  List<String> categories = [];
  ScrollController _scrollController = new ScrollController();
  List<String> covers = [
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
    loader = 6;
    //categories.add("hello");
    setCategory();
  }

  setCategory() async {
    await CategoryData()
        .getAll()
        .then((value) => {categories.addAll(value), setState(() {})});
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
    } on FormatException {
      setState(() => this.barcode = 'you cancelled the QRcode search');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextFormField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
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
        this._searchIcon = Icon(
          Icons.search,
          color: widget.themeColor,
        );
        this._appBarTitle = Text(
          "PocketShopping",
          style: TextStyle(color: widget.themeColor),
        );
      }
    });
  }

  _SeacrhUsingQRCode() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheetTemplate(
        height: MediaQuery.of(context).size.height * 0.6,
        opacity: 0.2,
        child: Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  child: FlatButton(
                    onPressed: () => {this.scan()},
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      // Replace with a Row for horizontal icon + text
                      children: <Widget>[
                        Center(
                            child: Text(
                          "Search Using QRcode/Barcode",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                          textAlign: TextAlign.center,
                        )),
                        Container(
                          height: 10,
                        ),
                        FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(
                              Icons.camera,
                              color: Colors.green,
                              size: MediaQuery.of(context).size.height * 0.1,
                            )),
                        Center(
                            child: Text(
                          "Scan QRCode to search for product",
                          style: TextStyle(color: Colors.black54),
                          textAlign: TextAlign.center,
                        )),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  barcode,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  _LocationUIState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
          vmodel.handleSearch(search: _searchText);
          print(_searchText);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    print(psProvider.of(context).value['uid']);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            0.25), // here the desired height
        child: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              color: widget.themeColor,
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
              preferredSize:
                  Size.fromHeight(MediaQuery.of(context).size.height * 0.15),
              child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  //margin: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Categories",
                            style: TextStyle(
                                fontSize: height * 0.04,
                                fontWeight: FontWeight.bold),
                          ),
                          Badge(
                              badgeContent: Text(
                                psProvider.of(context).value['cart'].toString(),
                                style: TextStyle(color: Colors.white),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                color: Colors.grey,
                                icon: Icon(
                                  Icons.shopping_basket,
                                  size: height * 0.05,
                                ),
                              ))
                        ],
                      ),
                      Container(
                        height: height * 0.1,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: <Widget>[
                            Wrap(
                              spacing: 2.0,
                              children: List<Widget>.generate(
                                // psProvider.of(context).value['category'].length,
                                categories.length,
                                (int index) {
                                  return ChoiceChip(
                                    label: Text(
                                        //psProvider.of(context).value['category'][index]
                                        categories[index],
                                        style: TextStyle(color: Colors.grey)),
                                    selected: _value == index,
                                    backgroundColor:
                                        Color.fromRGBO(255, 255, 255, 1),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _value = selected ? index : null;
                                      });
                                      psProvider.of(context).value['cart'] += 1;
                                    },
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))),
          title: _appBarTitle,
          automaticallyImplyLeading: false,
        ),
      ),
      backgroundColor: Color.fromRGBO(246, 246, 250, 1),
      body: Container(
        padding: EdgeInsets.only(right: 10, left: 10),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: MediaQuery.of(context).size.width * 0.5,
                //maxCrossAxisExtent :200,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                childAspectRatio: 1,
              ),
              delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return SinglePlaceWidget(
                      themeColor: widget.themeColor,
                      mData: {
                        'title': 'Amala Place' + index.toString(),
                        'cover': covers[index % loader]
                      });
                },
                childCount: loader,
              ),
            ),
            SliverList(
                delegate: SliverChildListDelegate(
              [
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
                        Text(
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
    );
  }
}
