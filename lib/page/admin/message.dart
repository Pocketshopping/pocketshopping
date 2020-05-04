import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:provider/provider.dart';

class Message extends StatefulWidget {
  final Color themeColor;

  Message({Key key, this.themeColor}) : super(key: key);

  @override
  _MessageState createState() => new _MessageState();
}

class _MessageState extends State<Message> {
  final TextEditingController _filter = new TextEditingController();
  String _searchText = "";
  Icon _searchIcon = new Icon(Icons.search);
  Widget _appBarTitle = new Text('Customer Care');
  ViewModel vmodel;

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
        this._appBarTitle = Text("Customer Care");
      }
    });
  }

  _MessageState() {
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height *
            0.15), // here the desired height
        child: AppBar(
          centerTitle: true,
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
                    ? MessageIndicatorTitle
                    : SearchEmptyIndicatorTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
