import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';

import 'AwareListItem.dart';
import 'bSheetTemplate.dart';

class Customer extends StatefulWidget {
  Customer({this.themeColor = Colors.black54});

  final Color themeColor;

  _CustomerState createState() => new _CustomerState();
}

class _CustomerState extends State<Customer> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('My Customer');
  ViewModel vmodel;
  int currentTab = 0;
  NewCustomer tab1;
  RecurringCustomer tab2;

  @override
  void initState() {
    super.initState();
    currentTab = 0;
    tab1 = NewCustomer(
      tab: currentTab,
    );
    tab2 = RecurringCustomer();
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
        this._appBarTitle = Text("My Customer");
      }
    });
  }

  _CustomerState() {
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
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
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
                  text: "New Customer",
                ),
                Tab(
                  text: "Old Customer",
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
        ),
        body: TabBarView(
          children: [tab1, tab2],
        ),
      ),
    );
  }
}

class NewCustomer extends StatelessWidget {
  final Color themeColor;
  final String search;
  final int tab;

  NewCustomer({Key key, this.themeColor, this.search, this.tab})
      : super(key: key);

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
                    ? NewCustomerIndicatorTitle
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

class RecurringCustomer extends StatelessWidget {
  final Color themeColor;

  RecurringCustomer({Key key, this.themeColor}) : super(key: key);

  ViewModel vmodel;
  int tab;

  setTab(int val) {
    tab = val;
  }

  void handleSearch({String search}) {
    print("_from completed $search");
    vmodel.handleSearch(search: search);
  }

  @override
  Widget build(BuildContext context) {
    print(tab.toString());
    void detail(String name) {
      showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheetTemplate(
          height: MediaQuery.of(context).size.height * 0.6,
          opacity: 0.2,
          child: showRecurringDetail(
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
                    ? OldCustomerIndicatorTitle
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
                'New Customer ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            "https://i.imgur.com/BoN9kdC.png")))),
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Customer Name',
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "time",
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                "Amount Spent",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Container(
            height: marginLR * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "AttendedToBy",
                style: TextStyle(color: Colors.black54),
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
                  /*Navigator.push(
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
            ],
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Order(s) Made',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "OrderID",
                    style: TextStyle(color: Colors.black54),
                  ),
                  FlatButton(
                    onPressed: () {},
                    color: Colors.greenAccent,
                    child: Text("View Details"),
                  ),
                ],
              ),
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

class showRecurringDetail extends StatelessWidget {
  final String name;

  showRecurringDetail({this.name});

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
                'New Customer ',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                        fit: BoxFit.fill,
                        image: new NetworkImage(
                            "https://i.imgur.com/BoN9kdC.png")))),
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Customer Name',
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "time",
                style: TextStyle(color: Colors.black54),
              ),
              Text(
                "Amount Spent",
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
          Container(
            height: marginLR * 0.01,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "AttendedToBy",
                style: TextStyle(color: Colors.black54),
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
                  /*Navigator.push(
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
            ],
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Align(
            alignment: Alignment.center,
            child: Center(
              child: Text(
                'Order(s) Made',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          Container(
            height: marginLR * 0.03,
          ),
          Column(
            children: <Widget>[
              Column(
                children: List<Widget>.generate(
                  7,
                  (int index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          onTap: () {},
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Center(
                                child: Text("OrderId"),
                              ),
                              Center(
                                child: Text("Amount"),
                              ),
                            ],
                          ),
                        ),
                        Divider()
                      ],
                    );
                  },
                ).toList(),
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
