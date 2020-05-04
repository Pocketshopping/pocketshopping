import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';

import 'AwareListItem.dart';
import 'bSheetTemplate.dart';

class Reviews extends StatefulWidget {
  final Color themeColor;

  Reviews({this.themeColor = Colors.black54});

  _ReviewsState createState() => new _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Customer Reviews');
  ViewModel vmodel;

  Positive tab1 = Positive();
  Neutral tab2 = Neutral();
  Negative tab3 = Negative();
  int currentTab = 0;

  @override
  void initState() {
    super.initState();
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = Icon(Icons.close);
        this._appBarTitle = TextFormField(
          controller: _filter,
          decoration: InputDecoration(
              prefixIcon:
                  Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
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
        this._searchIcon = Icon(Icons.search);
        this._appBarTitle = Text("Customer Reviews");
      }
    });
  }

  _ReviewsState() {
    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() {
          _searchText = "";
        });
      } else {
        setState(() {
          _searchText = _filter.text;
          //vmodel.handleSearch(search: _searchText);
          if (currentTab == 0) {
            tab1.handleSearch(search: _searchText);
          } else if (currentTab == 1) {
            tab2.handleSearch(search: _searchText);
          } else if (currentTab == 2) {
            tab3.handleSearch(search: _searchText);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
              0.2), // here the desired height
          child: AppBar(
            backgroundColor: widget.themeColor,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
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
            title: _appBarTitle,
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  currentTab = index;
                });
                //print(index.toString());
              },
              tabs: [
                Tab(
                  text: "Positive",
                ),
                Tab(
                  text: "Neutral",
                ),
                Tab(
                  text: "Negative",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [tab1, tab2, tab3],
        ),
      ),
    );
  }
}

class Positive extends StatelessWidget {
  final Color themeColor;
  final String search;

  Positive({Key key, this.themeColor, this.search}) : super(key: key);

  ViewModel vmodel;

  void handleSearch({String search}) {
    print("_from completed $search");
    vmodel.handleSearch(search: search);
  }

  @override
  Widget build(BuildContext context) {
    void detail(String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
          height: MediaQuery.of(context).size.height * 0.6,
          opacity: 0.2,
          child: showDetail(
            name: name,
          ),
        ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(),
        child: Consumer<ViewModel>(
          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel = model;
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyIndicatorTitle
                    ? ReviewsIndicatorTitle
                    : SearchEmptyIndicatorTitle,
                callback: (value) {
                  detail(value);
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

class Neutral extends StatelessWidget {
  final Color themeColor;

  Neutral({Key key, this.themeColor}) : super(key: key);

  ViewModel vmodel;

  void handleSearch({String search}) {
    print("_from completed $search");
    vmodel.handleSearch(search: search);
  }

  @override
  Widget build(BuildContext context) {
    void detail(String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
          height: MediaQuery.of(context).size.height * 0.6,
          opacity: 0.2,
          child: showDetail(
            name: name,
          ),
        ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(),
        child: Consumer<ViewModel>(
          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel = model;
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyIndicatorTitle
                    ? ReviewsIndicatorTitle
                    : SearchEmptyIndicatorTitle,
                callback: (value) {
                  detail(value);
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

class Negative extends StatelessWidget {
  final Color themeColor;

  Negative({Key key, this.themeColor}) : super(key: key);

  ViewModel vmodel;

  void handleSearch({String search}) {
    print("_from completed $search");
    vmodel.handleSearch(search: search);
  }

  @override
  Widget build(BuildContext context) {
    void detail(String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
          height: MediaQuery.of(context).size.height * 0.6,
          opacity: 0.2,
          child: showDetail(
            name: name,
          ),
        ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      body: ChangeNotifierProvider<ViewModel>(
        create: (context) => ViewModel(),
        child: Consumer<ViewModel>(
          builder: (context, model, child) => ListView.builder(
            itemCount: model.items.length,
            itemBuilder: (context, index) => AwareListItem(
              itemCreated: () {
                vmodel = model;
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: model.items[0] != SearchEmptyIndicatorTitle
                    ? ReviewsIndicatorTitle
                    : SearchEmptyIndicatorTitle,
                callback: (value) {
                  detail(value);
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

class showDetail extends StatelessWidget {
  final String name;

  showDetail({this.name});

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.only(
          top: marginLR * 0.03, left: marginLR * 0.06, right: marginLR * 0.06),
      padding: EdgeInsets.only(top: marginLR * 0.03, bottom: marginLR * 0.03),
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Old Customer ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
              alignment: Alignment.center,
              child: Center(
                child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.15,
                    decoration: new BoxDecoration(
                        shape: BoxShape.circle,
                        image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                                "https://i.imgur.com/BoN9kdC.png")))),
              )),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Customer Name',
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.6), width: 1.0)),
            ),
            height: marginLR * 0.01,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "number of time this customer Visited",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    "0",
                    style: TextStyle(color: Colors.black54),
                  )),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.6), width: 1.0)),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Amount Generated from this customer",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "23",
                      style: TextStyle(color: Colors.black54),
                    ),
                  )
                ],
              ),
            ],
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: FlatButton(
                onPressed: () {
                  /* Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      CustomerChat(title: 'Customer Chat',)),
                );*/
                },
                color: Colors.blueAccent,
                child: Text(
                  "Send Message",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Customer Experience',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          RatingBar(
            onRatingUpdate: (rate) {},
            initialRating: 3.5,
            minRating: 1,
            maxRating: 5,
            itemSize: MediaQuery.of(context).size.width * 0.08,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "i enjoyed the meal but i would advise you work more on your customer care service thank you",
                style: TextStyle(color: Colors.black54),
              ),
              FlatButton(
                onPressed: () {
                  /*Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        CustomerChat(title: 'Customer Chat',)),
                  );*/
                },
                color: Colors.greenAccent,
                child: Text(
                  "View all Reviews for this customer",
                  style: TextStyle(color: Colors.black54),
                ),
              )
            ],
          ),
          Container(
            height: marginLR * 0.03,
          ),
        ],
      ),
    );
  }
}
