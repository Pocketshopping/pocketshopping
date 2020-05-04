import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/ViewModel/ViewModel.dart';
import 'package:pocketshopping/widget/AwareListItem.dart';
import 'package:pocketshopping/widget/ListItem.dart';
import 'package:pocketshopping/widget/bSheetTemplate.dart';
import 'package:provider/provider.dart';

class CloseOrder extends StatelessWidget {
  const CloseOrder({Key key}) : super(key: key);

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
                SchedulerBinding.instance.addPostFrameCallback(
                    (duration) => model.handleItemCreated(index));
              },
              child: ListItem(
                title: model.items[index],
                template: OpenOrderHomeDeliveryIndicatorTitle,
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
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(
              top: marginLR * 0.03,
              left: marginLR * 0.06,
              right: marginLR * 0.06),
          padding:
              EdgeInsets.only(top: marginLR * 0.03, bottom: marginLR * 0.03),
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Center(
                  child: Text(
                    name,
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
              Container(
                height: marginLR * 0.03,
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Center(
                  child: Text(
                    'Order Details',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(
                height: marginLR * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Payment Method",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Pocket",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Order Type",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Home Delivery",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Amount",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "2345",
                      style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Date and Time ",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "21-1-2020 12:23:0",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "CompletedBy",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "joshy",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Date Time Completed",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "2020-1-1 12:13:09",
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1, color: Colors.grey.shade300))),
              ),
              Container(
                height: marginLR * 0.03,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Center(
                  child: Text(
                    'Order Items',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Container(
                height: marginLR * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Item",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Qty",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Amount",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
              Container(
                height: marginLR * 0.03,
              ),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(
                top: marginLR * 0.03,
                left: marginLR * 0.06,
                right: marginLR * 0.06),
            padding:
                EdgeInsets.only(top: marginLR * 0.03, bottom: marginLR * 0.03),
            child: Column(
              children: List<Widget>.generate(
                7,
                (int index) {
                  return Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              "Item",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Qty",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Amount",
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      Divider()
                    ],
                  );
                },
              ).toList(),
            ))
      ],
    );
  }
}
