import 'package:flutter/material.dart';
import 'package:pocketshopping/widget/template.dart';

class CustomerChat extends StatefulWidget {
  final String coverUrl;
  final Color themeColor;
  final String title;
  final bool fabActionButton;
  final List<String> filterItems;

  CustomerChat({
    this.fabActionButton = false,
    this.filterItems,
    this.title = 'PocketShopping',
    this.coverUrl =
        'https://scontent-los2-1.xx.fbcdn.net/v/t1.0-9/13015366_962282610522031_7032913772865906850_n.jpg?_nc_cat=110&_nc_sid=dd9801&_nc_ohc=2tFLxKELYhUAX9UaXox&_nc_ht=scontent-los2-1.xx&oh=f4372b89baf627b42395be5d593f81ca&oe=5EA6150F',
    this.themeColor,
  });

  @override
  State<StatefulWidget> createState() => _CustomerChatState();
}

class _CustomerChatState extends State<CustomerChat> {
  List<int> items = [];
  ScrollController _scrollController = new ScrollController();
  List<Color> itemColor = [];
  String filter = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = [1, 2, 3, 4, 5, 6];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Template(
        scroller: _scrollController,
        coverUrl: widget.coverUrl,
        color: widget.themeColor != null ? widget.themeColor : Colors.black54,
        title: widget.title,
        body: SliverList(delegate: SliverChildListDelegate([Container()])),
        footer: SliverList(
            delegate: SliverChildListDelegate(
          [
            Container(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(),
          ],
        )),
      ),
    );
  }
}
