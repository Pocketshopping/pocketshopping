import 'package:flutter/material.dart';


class AwareListItem extends StatefulWidget {
  final Function itemCreated;
  final Widget child;
  const AwareListItem({
    Key key,
    this.itemCreated,
    this.child,
  }) : super(key: key);

  @override
  _AwareListItemState createState() => _AwareListItemState();
}

class _AwareListItemState extends State<AwareListItem> {
  @override
  void initState() {
    super.initState();
    if (widget.itemCreated != null) {
      widget.itemCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return

      widget.child;
  }
}