import 'package:badges/badges.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:provider/provider.dart';

class MerchantUI extends StatefulWidget {
  final Color themeColor;

  MerchantUI({this.themeColor});

  @override
  State<StatefulWidget> createState() => _MerchantUIState();
}

class _MerchantUIState extends State<MerchantUI> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(
    Icons.search,
    color: PRIMARYCOLOR,
  );
  Widget _appBarTitle = new Text(
    "Amala Place",
    style: TextStyle(color: PRIMARYCOLOR),
  );
  ViewModel vmodel;
  String barcode = "";
  int _value = 0;

  @override
  void initState() {
    super.initState();
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
          "Amala Place",
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

  _MerchantUIState() {
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
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            0.25), // here the desired height
        child: AppBar(
          elevation: 0.0,
          centerTitle: true,
          backgroundColor: Color.fromRGBO(255, 255, 255, 1),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.pop(context);
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
                                7,
                                (int index) {
                                  return ChoiceChip(
                                    label: Text(
                                      'Amala_Item $index',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    selected: _value == index,
                                    backgroundColor:
                                        Color.fromRGBO(255, 255, 255, 1),
                                    onSelected: (bool selected) {
                                      setState(() {
                                        _value = selected ? index : null;
                                      });
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
      body: ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(searchTerm: _searchText),
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
                  //detail(value);
                  return value;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
