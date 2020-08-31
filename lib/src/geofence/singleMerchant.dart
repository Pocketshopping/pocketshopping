import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:badges/badges.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as loc;
import 'package:pocketshopping/src/business/business.dart';
import 'package:pocketshopping/src/order/repository/cartObj.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'orderUI.dart';

class MerchantUI extends StatefulWidget {
  final Merchant merchant;
  final User user;
  final double distance;
  final Position initPosition;

  MerchantUI({this.merchant, this.user, this.distance, this.initPosition});

  @override
  State<StatefulWidget> createState() => _MerchantUIState();
}

class _MerchantUIState extends State<MerchantUI> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText;
  Icon _searchIcon = new Icon(
    Icons.search,
    color: PRIMARYCOLOR,
  );
  Widget _appBarTitle;
  ViewModel vmodel;
  String barcode;
  int _value;
  List<dynamic> category;
  String selectedCategory;
  bool searchMode;
  int track;
  int orderCount;
  StreamSubscription<loc.LocationData> geoStream;
  Position position;
  double dist;
  Session session;
  loc.Location location;
  List<CartItem> cart;

  @override
  void initState() {
    _appBarTitle = new Text(
      '${widget.merchant.bName}',
      style: TextStyle(color: PRIMARYCOLOR),
    );
    searchMode = false;
    _searchText = "";
    barcode = "";
    dist = widget.distance;
    _value = 0;
    track = 0;
    cart = List();
    location = new loc.Location();
    orderCount = 1;
    position = widget.initPosition;
    try{

      CloudFunctions.instance
          .getHttpsCallable(
        functionName: "FetchMerchantsProductCategory",
      )
          .call({'mID': widget.merchant.mID}).then((value)  {
        if(mounted)
        setState(() {
          category = value.data;
          if (category.isNotEmpty) selectedCategory = category[0];
        });
      });
    }
    catch(_){Get.back();}
    location.changeSettings(
        accuracy: loc.LocationAccuracy.high, interval: 60000);
    geoStream = location.onLocationChanged.listen((loc.LocationData cLoc) {
      position = Position(
          latitude: cLoc.latitude,
          longitude: cLoc.longitude,
          altitude: cLoc.altitude,
          accuracy: cLoc.accuracy);
      dist = GeoFirePoint(cLoc.latitude, cLoc.longitude).distance(
          lat: widget.merchant.bGeoPoint['geopoint'].latitude,
          lng: widget.merchant.bGeoPoint['geopoint'].longitude);
      if (mounted) setState(() {});
    });

    //});
    super.initState();
  }



  void _searchPressed() {
    _filter.clear();
    if(mounted)
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(
          Icons.close,
          color: PRIMARYCOLOR,
        );
        this._appBarTitle = Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          child: TextFormField(
            controller: _filter,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search ${widget.merchant.bName}',
              filled: true,
              fillColor: Colors.grey.withOpacity(0.2),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
            autofocus: true,
            enableSuggestions: true,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              if (value.isNotEmpty) {
                vmodel.handleSearch(search: _filter.text);
                _searchText = value;
                if(mounted)
                setState(() {});
              }
            },
          )
        );

        searchMode = true;
      } else {
        this._searchIcon = Icon(
          Icons.search,
          color: PRIMARYCOLOR,
        );
        this._appBarTitle = Text(
          widget.merchant.bName,
          style: TextStyle(color: PRIMARYCOLOR),
        );
        searchMode = false;
        vmodel.handleChangeCategory(category: selectedCategory);
      }
    });
  }



  @override
  void dispose() {
    _filter?.dispose();
    geoStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = Get.height;

    return category != null
        ? category.isNotEmpty
            ? Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      Get.height *
                          0.25), // here the desired height
                  child: AppBar(
                    elevation: 0.0,
                    centerTitle: true,
                    backgroundColor: Colors.white,//Color.fromRGBO(255, 255, 255, 1),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: _searchIcon,
                        onPressed: _searchPressed,
                      ),
                    ],
                    bottom: PreferredSize(
                        preferredSize: Size.fromHeight(
                            Get.height * 0.1),
                        child: Builder(
                            builder: (context) => Container(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                color: Colors.white,
                                //margin: EdgeInsets.only(bottom: 20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        category != null
                                            ? Text(
                                                !searchMode
                                                    ? "Categories"
                                                    : 'Search',
                                                style: TextStyle(
                                                    fontSize: height * 0.04,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Container(),
                                        Row(
                                          children: <Widget>[
                                            cart.length > 0
                                                ? AvatarGlow(
                                                    startDelay: Duration(
                                                        milliseconds: 1000),
                                                    glowColor: Colors.red,
                                                    endRadius: 40.0,
                                                    duration: Duration(
                                                        milliseconds: 2000),
                                                    repeat: true,
                                                    showTwoGlows: true,
                                                    repeatPauseDuration:
                                                        Duration(
                                                            milliseconds: 100),
                                                    child: Material(
                                                      elevation: 8.0,
                                                      shape: CircleBorder(),
                                                      child: Badge(
                                                        badgeContent: Text(
                                                          cart.length
                                                              .toString(),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        position: BadgePosition
                                                            .topRight(
                                                                top: 1,
                                                                right: 1),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            if (cart.length > 0)
                                                              showCart(cart);
                                                            else
                                                              Scaffold.of(
                                                                  context)
                                                                ..hideCurrentSnackBar()
                                                                ..showSnackBar(
                                                                    SnackBar(
                                                                  content: Text(
                                                                      'basket is empty'),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .redAccent,
                                                                  behavior:
                                                                      SnackBarBehavior
                                                                          .floating,
                                                                ));
                                                          },
                                                          color: PRIMARYCOLOR,
                                                          icon: Icon(
                                                            Icons
                                                                .shopping_basket,
                                                            size: height * 0.05,
                                                          ),
                                                        ),
                                                        showBadge:
                                                            cart.length > 0
                                                                ? true
                                                                : false,
                                                        animationDuration:
                                                            Duration(
                                                                seconds: 5),
                                                      ),
                                                    ),
                                                    shape: BoxShape.circle,
                                                    animate: true,
                                                    curve: Curves.fastOutSlowIn,
                                                  )
                                                : Badge(
                                                    badgeContent: Text(
                                                      cart.length.toString(),
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                    position:
                                                        BadgePosition.topRight(
                                                            top: 1, right: 1),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        if (cart.length > 0)
                                                          showCart(cart);
                                                        else
                                                          Scaffold.of(context)
                                                            ..hideCurrentSnackBar()
                                                            ..showSnackBar(
                                                                SnackBar(
                                                              content: Text(
                                                                  'basket is empty'),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              behavior:
                                                                  SnackBarBehavior
                                                                      .floating,
                                                            ));
                                                      },
                                                      color: PRIMARYCOLOR,
                                                      icon: Icon(
                                                        Icons.shopping_basket,
                                                        size: height * 0.05,
                                                      ),
                                                    ),
                                                    showBadge: cart.length > 0
                                                        ? true
                                                        : false,
                                                    animationDuration:
                                                        Duration(seconds: 5),
                                                  ),
                                            IconButton(
                                              onPressed: () => launch("tel:${widget.merchant.bTelephone}"),
                                              icon: Icon(

                                                Icons.call,
                                                color: PRIMARYCOLOR,
                                              ),
                                            ),
                                            /*
                                            IconButton(
                                              onPressed: (){},
                                              icon: Icon(
                                                Icons.place,
                                                color: PRIMARYCOLOR,
                                              ),
                                            ),*/
                                          ],
                                        )
                                      ],
                                    ),
                                    category != null
                                        ? searchMode
                                            ? Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      _searchText.isNotEmpty
                                                          ? 'Showing result for $_searchText'
                                                          : 'Search for product in ${widget.merchant.bName}',
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                ],
                                              )
                                            : Column(
                                                children: <Widget>[
                                                  Container(
                                                    height: height * 0.1,
                                                    child: ListView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      children: <Widget>[
                                                        Wrap(
                                                          spacing: 4.0,
                                                          children: List<
                                                              Widget>.generate(
                                                            category.length,
                                                            (int index) {
                                                              return ChoiceChip(
                                                                elevation: 4,
                                                                label: Text(
                                                                  '${category[index]}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                                selected:
                                                                    _value ==
                                                                        index,
                                                                backgroundColor:
                                                                    Color
                                                                        .fromRGBO(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            1),
                                                                onSelected: (bool
                                                                    selected) {
                                                                  if(mounted)
                                                                  setState(() {
                                                                    int lastIndex =
                                                                        _value;
                                                                    _value = selected
                                                                        ? index
                                                                        : null;
                                                                    if (_value ==
                                                                        null) {
                                                                      _value =
                                                                          lastIndex;
                                                                      selectedCategory =
                                                                          category[
                                                                              _value];
                                                                    } else {
                                                                      selectedCategory =
                                                                          category[
                                                                              _value];
                                                                    }
                                                                    // selectedCategory = selected ? category[index] : "";
                                                                    vmodel.handleChangeCategory(
                                                                        category:
                                                                            selectedCategory);
                                                                  });
                                                                },
                                                              );
                                                            },
                                                          ).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  /*dist>0.1?
                              widget.merchant.bDelivery == 'No'?
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: Text('Sorry we do not offer home delivery',
                                  style: TextStyle(color: Colors.red,),),
                              )
                                  :
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                alignment: Alignment.centerLeft,
                                child: Text('We offer home delivery',
                                  style: TextStyle(color: Colors.green,),),
                              )
                                  :Container()*/
                                                ],
                                              )
                                        : Container()
                                  ],
                                )))),
                    title: _appBarTitle,
                    automaticallyImplyLeading: false,
                  ),
                ),
                body: ChangeNotifierProvider<ViewModel>(
                  create: (context) => ViewModel(query: {
                    'typeOf': 'PRODUCT',
                    'mid': widget.merchant.mID,
                    'category': selectedCategory,
                  }),
                  child: Consumer<ViewModel>(
                    builder: (context, model, child) => ListView.builder(
                      itemCount: model.items.length,
                      itemBuilder: (context, index) => AwareListItem(
                        itemCreated: () {
                          vmodel = model;
                          return SchedulerBinding.instance.addPostFrameCallback(
                              (duration) => model.handleItemCreated(index));
                        },
                        child: ListItem(
                          title: model.items[index],
                          template: model.items[0] != SearchEmptyIndicatorTitle
                              ? MerchantUIIndicatorTitle
                              : SearchEmptyIndicatorTitle,
                          callback: (value) {
                            switch (value['callType']) {
                              case 'ORDER':
                                orderCallback(value['payload']);
                                break;
                              case 'DETAIL':
                                detailCallback();
                                break;
                              case 'CART':
                                cartCallback(value['payload'], context);
                                break;
                              default:
                                detailCallback();
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: Get.height * 0.4,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          blendMode: BlendMode.dstIn,
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image: widget.merchant.bPhoto.isNotEmpty
                                ? widget.merchant.bPhoto
                                : PocketShoppingDefaultCover,
                            fit: BoxFit.cover,
                            width: Get.width,
                            height: height * 0.4,
                          ),
                        ),
                      ),
                      Container(
                        height: Get.height * 0.6,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: <Widget>[
                            Text(
                              widget.merchant.bName ?? 'Merchant',
                              style: TextStyle(
                                  fontSize:
                                      Get.height * 0.06,
                                  color: Colors.black54),
                                textAlign: TextAlign.center
                            ),
                            SizedBox(height: 20),
                            Text(
                              'We are currently setting up our pocketshopping account.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      Get.height * 0.03,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Contact Us',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      Get.height * 0.03,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 10),
                            FlatButton(
                                onPressed: () => launch("tel:${widget.merchant.bTelephone}"),
                              child: Icon(Icons.call,
                                  size:
                                      Get.height * 0.1,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 10),
                           /* Text(
                              'Contact Us',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize:
                                      Get.height * 0.02,
                                  color: Colors.black54),
                            ),
                            SizedBox(height: 5),
                            Text(
                              widget.merchant.bTelephone ?? '',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: Get.height *
                                      0.025,
                                  color: Colors.black54),
                            ),*/
                          ],
                        ),
                      )
                    ],
                  ),
                ))
        : Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: JumpingDotsProgressIndicator(
                fontSize: Get.height * 0.12,
                color: PRIMARYCOLOR,
              ),
            ),
          );
  }

  detailCallback() {
    showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
              height: Get.height * 0.4,
              child: Container(
                child: Container(),
              ),
            ));
  }

  cartCallback(dynamic data, BuildContext cntx) {
    CartItem item = CartItem(item: data, count: 1, total: (data.pPrice * 1));
    if (cart.contains(item)) {
      if (!Get.isSnackbarOpen)
        Get.snackbar('Already in the Basket', "Item already in the basket",
            messageText: Text(
              'Item already in the basket',
              style: TextStyle(color: Colors.white),
            ),
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.redAccent.withOpacity(0.7),
            mainButton: FlatButton(
              onPressed: () {
                cart.remove(item);
                if(mounted)
                setState(() {});
              },
              child: Text('Remove'),
            ));
    } else {
      cart.add(item);
      if(mounted)
      setState(() {});
      if (!Get.isSnackbarOpen)
        Get.snackbar('Basket', "Item added to the basket",
            messageText: Text(
              'Item added to the basket',
              style: TextStyle(color: Colors.white),
            ),
            snackPosition: SnackPosition.TOP,
            backgroundColor: PRIMARYCOLOR.withOpacity(0.5),
            mainButton: FlatButton(
              onPressed: () {
                cart.remove(item);
                if(mounted)
                setState(() {});
              },
              child: Text('Remove'),
            ));
    }
  }

  orderCallback(dynamic data) {
    showModalBottomSheet(
      context: context,
      builder: (_) => OrderUI(
        merchant: widget.merchant,
        payload: data,
        user: widget.user,
        distance: dist,
        initPosition: position,
      ),
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
    );
  }

  cartOps() {
    if(mounted)
    setState(() {});
  }

  showCart(dynamic data) {
    showModalBottomSheet(
      context: context,
      builder: (_) => OrderUI(
        merchant: widget.merchant,
        payload: data,
        user: widget.user,
        distance: dist,
        initPosition: position,
        cartOps: cartOps,
      ),
      isScrollControlled: true,
    );
  }
}
