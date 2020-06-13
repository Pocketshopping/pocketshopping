import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:pocketshopping/widget/template.dart';

class ItemLister extends StatefulWidget {
  final String coverUrl;
  final Color themeColor;
  final Function item;
  final Function detailer;
  final Function menu;
  final String title;
  final bool fabActionButton;
  final List<String> filterItems;
  final bool searchBar;
  final bool manage;

  ItemLister({
    this.fabActionButton = false,
    @required this.item,
    @required this.detailer,
    this.searchBar = true,
    this.manage = false,
    this.filterItems,
    this.menu,
    this.title = 'PocketShopping',
    this.coverUrl =
        'https://scontent-los2-1.xx.fbcdn.net/v/t1.0-9/13015366_962282610522031_7032913772865906850_n.jpg?_nc_cat=110&_nc_sid=dd9801&_nc_ohc=2tFLxKELYhUAX9UaXox&_nc_ht=scontent-los2-1.xx&oh=f4372b89baf627b42395be5d593f81ca&oe=5EA6150F',
    this.themeColor,
  });

  @override
  State<StatefulWidget> createState() => _ItemListerState();
}

class _ItemListerState extends State<ItemLister> {
  List<int> items = [];
  ScrollController _scrollController = new ScrollController();
  List<Color> itemColor = [];
  String filter = '';

  Widget detail() {}

  List<Widget> ListItem() {
    return new List<Widget>.generate(items.length, (int index) {
      return FlatButton(
          color: itemColor[index],
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => ClipRRect(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: MediaQuery.of(context).size.width,
                      //
                      child: Column(
                        children: <Widget>[
                          Container(
                            color: Colors.white,
                            alignment: Alignment.topRight,
                            height: MediaQuery.of(context).size.width * 0.05,
                            child: FlatButton(
                                onPressed: () => {Navigator.pop(context)},
                                child: Icon(Icons.close)),
                          ),
                          Expanded(
                            flex: 1,
                            child: widget.detailer(index),
                          ),
                        ],
                      ))),
              isScrollControlled: true,
            );
          },
          child: widget.item(index));
    });
  }

  Future<void> SendBroadcastMessage() async {}

  Future<void> CustomerChat() async {}

  void ColorReset() {
    itemColor = List<Color>.generate(items.length, (int index) {
      return Colors.white70;
    });
    setState(() {});
  }

  void LoadColor(int length) {
    itemColor.addAll(List<Color>.generate(length, (int index) {
      return Colors.grey.shade200;
    }));
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = [1, 2, 3, 4, 5, 6];
    ColorReset();
    filter = widget.filterItems != null ? widget.filterItems[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Template(
        scroller: _scrollController,
        coverUrl: widget.coverUrl,
        color: widget.themeColor != null ? widget.themeColor : Colors.black54,
        title: widget.title,
        header: widget.menu(widget.themeColor, filter),
        body: SliverList(
            delegate: SliverChildListDelegate([
          if (widget.searchBar)
            Container(
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.05,
                    right: MediaQuery.of(context).size.width * 0.05),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10.0),
                              hintText: 'Search This Merchant',
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: widget.themeColor,
                          ),
                          onPressed: () {
                            //Navigator.of(context).pushNamed(MapSample.tag);
                          },
                        ),
                      ],
                    ),
                  ],
                )),
          Column(
              children: !widget.manage
                  ? ListItem()
                  : widget.item(1) //orders !=null?orders:<Widget>[]
              ),
        ])),
        footer: SliverList(
            delegate: SliverChildListDelegate(
          [
            Container(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
              child: FlatButton(
                color: Colors.grey.withOpacity(0.5),
                onPressed: () {
                  List<int> data = [2, 3, 4, 5, 6, 7, 8, 9];
                  ColorReset();
                  LoadColor(data.length);
                  setState(() {
                    items.addAll(data);
                  });
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent +
                          MediaQuery.of(context).size.height * 0.5,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut);
                },
                child: Center(
                    child: Column(
                  children: <Widget>[
                    Icon(FontAwesome5Solid.long_arrow_alt_down),
                    Text("Load More"),
                  ],
                )),
              ),
            ),
          ],
        )),
      ),
      floatingActionButton: widget.fabActionButton
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    child: Container(
                        color: Colors.white,
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height * 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Filter By',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            DropdownButton<String>(
                              value: filter,
                              icon: Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle(
                                  color: Colors.black87, fontSize: 18),
                              onChanged: (String newValue) {
                                setState(() {
                                  filter = newValue;
                                });
                                Navigator.pop(context);
                              },
                              items: widget.filterItems
                                  .map<DropdownMenuItem<String>>(
                                      (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ],
                        )),
                  ),
                  isScrollControlled: true,
                );
              },
              backgroundColor: widget.themeColor,
              child: Icon(FontAwesome5Solid.filter),
            )
          : Container(),
    );
  }
}
