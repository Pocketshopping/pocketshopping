import 'package:flutter/material.dart';

class Template extends StatefulWidget {
  Template(
      {this.body,
      this.header,
      this.footer,
      this.scroller,
      this.color,
      this.coverUrl = '',
      this.title = 'PocketShopping',
      this.maxHeight = 250.0,
      this.minHeight = 150.0});

  final double maxHeight;
  final double minHeight;
  final ScrollController scroller;
  final Widget body;
  final Widget header;
  final Widget footer;
  final Color color;
  final String coverUrl;
  final String title;

  @override
  State<StatefulWidget> createState() => _TemplateState();
}

class _TemplateState extends State<Template> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: CustomScrollView(
      controller: widget.scroller,
      slivers: <Widget>[
        SliverPersistentHeader(
          pinned: true,
          delegate: MyDynamicHeader(
            widget.coverUrl,
            maxHeight: widget.maxHeight,
            minHeight: MediaQuery.of(context).size.height * 0.15,
            title: widget.title,
          ),
        ),
        if (widget.header != null) widget.header,
        if (widget.body != null) widget.body,
        if (widget.footer != null) widget.footer,
      ],
    )));
  }
}

class MyDynamicHeader extends SliverPersistentHeaderDelegate {
  MyDynamicHeader(this.cover,
      {this.maxHeight = 250.0,
      this.minHeight = 150.0,
      this.color,
      this.title = 'PocketShopping'});

  final String cover;
  final double maxHeight;
  final double minHeight;
  final Color color;
  final String title;

  int index = 0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    //height = MediaQuery.of(context).size.height*0.6;
    return LayoutBuilder(builder: (context, constraints) {
      if (++index > Colors.primaries.length - 1) index = 0;

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xff000000),
          image: DecorationImage(
            image: NetworkImage(cover),

            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.3), BlendMode.dstATop),
            //colorFilter: Colors.black.withOpacity(0.4),
          ),
        ),
        height: constraints.maxHeight,
        child: SafeArea(
          child: Container(
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                size: 30,
                                color: color == null
                                    ? const Color(0xffffffff)
                                    : color,
                              ),
                              onPressed: () {
                                //print("your menu action here");
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        ])),
                  ]),

              //height: MediaQuery.of(context).size.height*0.4,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ),
      );
    });
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate _) => true;

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;
}
