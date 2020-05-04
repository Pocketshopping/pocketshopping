import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/productDataModel.dart';
import 'package:pocketshopping/page/admin/addProduct.dart';

class AddProductNextPage extends StatefulWidget {
  AddProductNextPage({
    this.product,
  });

  ProductDataModel product;

  @override
  State<StatefulWidget> createState() => _AddProductNextPageState();
}

class _AddProductNextPageState extends State<AddProductNextPage> {
  final _formKey = GlobalKey<FormState>();
  Map formType;
  String btype;
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  var _stockController = TextEditingController();
  final FocusNode _submitFocus = FocusNode();

  final format = DateFormat("yyyy-mm");

  String barcode;
  DateTime initialDate;
  DateTime expiryDate;
  DateTime manufactureDate;
  String expiryText;
  String manufactureText;
  String eDateLabel;
  String mDateLabel;
  bool submitted;
  String report;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formType = {'REST': 'Item', 'STORE': 'Product', 'BAR': 'Item'};
    btype = 'REST';
    barcode = "";
    initialDate = DateTime.now();
    expiryDate = initialDate;
    manufactureDate = initialDate;
    eDateLabel = "";
    mDateLabel = "";
    expiryText = 'Expiry Date(optional)';
    manufactureText = 'Manufactured Date(optional)';
    submitted = false;
    report = "loading";
  }

  Future barScanner() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = '';
        });
      } else {
        setState(() => this.barcode = '');
      }
    } on FormatException {
      setState(() => this.barcode = '');
    } catch (e) {
      setState(() => this.barcode = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mDate = FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          showMonthPicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime(DateTime.now().year, DateTime.now().month),
                  initialDate: expiryDate ?? initialDate)
              .then((date) => {
                    if (date != null)
                      {
                        setState(() {
                          manufactureDate = date;
                          manufactureText = date.month.toString() +
                              "/" +
                              date.year.toString();
                          mDateLabel = 'Manufactured Date(optional)';
                        })
                      }
                    else
                      {
                        setState(() {
                          manufactureDate = null;
                          manufactureText = 'Manufactured Date(optional)';
                          mDateLabel = '';
                        })
                      }
                  });
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                manufactureText,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ],
        ));

    final stock = TextFormField(
      controller: this._stockController,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.number,
      autofocus: false,
      //initialValue: '1',
      decoration: InputDecoration(
        labelText: "Stock Count (Optional)",
        hintText: 'Stock Count (Optional)',
        border: InputBorder.none,
      ),
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
    );

    final eDate = FlatButton(
        padding: EdgeInsets.all(0.0),
        onPressed: () {
          showMonthPicker(
                  context: context,
                  firstDate:
                      DateTime(DateTime.now().year, DateTime.now().month),
                  lastDate: DateTime(DateTime.now().year + 5),
                  initialDate: expiryDate ?? initialDate)
              .then((date) => {
                    if (date != null)
                      {
                        setState(() {
                          expiryDate = date;
                          expiryText = date.month.toString() +
                              "/" +
                              date.year.toString();
                          eDateLabel = 'Expiry Date(optional)';
                        })
                      }
                    else
                      {
                        setState(() {
                          expiryDate = null;
                          expiryText = 'Expiry Date(optional)';
                          eDateLabel = '';
                        })
                      }
                  });
        },
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                expiryText,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
          ],
        ));

    final manufacturer = TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._manufacturerController,
        decoration: InputDecoration(
          labelText: 'Manufacturer (Optional)',
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
      ),
      suggestionsCallback: (pattern) {
        return [''];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      transitionBuilder: (context, suggestionBox, controller) {
        return suggestionBox;
      },
      onSuggestionSelected: (suggestion) {
        this._manufacturerController.text = suggestion;
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.2,
        ),
      ),
      autoFlipDirection: true,
      hideOnEmpty: true,
    );

    final unit = TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: this._unitController,
        decoration: InputDecoration(
          labelText: 'Product Unit (Optional)',
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
      ),
      suggestionsCallback: (pattern) {
        return ['AB', 'AC', 'AD', pattern];
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      transitionBuilder: (context, suggestionBox, controller) {
        return suggestionBox;
      },
      onSuggestionSelected: (suggestion) {
        this._unitController.text = suggestion;
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.2,
        ),
      ),
      autoFlipDirection: true,
      hideOnEmpty: true,
    );

    return WillPopScope(
        onWillPop: () async => !submitted,
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      0.1), // here the desired height
              child: Builder(
                builder: (ctx) => AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: PRIMARYCOLOR,
                    ),
                    onPressed: () {
                      if (submitted) {
                        Scaffold.of(ctx).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text('I am working please wait')));
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  title: Text(
                    "Product",
                    style: TextStyle(color: PRIMARYCOLOR),
                  ),
                  automaticallyImplyLeading: false,
                ),
              ),
            ),
            body: Builder(
                builder: (ctx) => CustomScrollView(slivers: <Widget>[
                      SliverList(
                          delegate: SliverChildListDelegate(
                        [
                          Container(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          psCard(
                            color: PRIMARYCOLOR,
                            title: 'Details',
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                //offset: Offset(1.0, 0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ],
                            child: Form(
                                key: _formKey,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: stock,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: unit,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: manufacturer,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Column(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                mDateLabel,
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            mDate
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Column(
                                          children: <Widget>[
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                eDateLabel,
                                                style: TextStyle(
                                                    color: Colors.black54),
                                              ),
                                            ),
                                            eDate
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              //                   <--- left side
                                              color: Colors.black12,
                                              width: 1.0,
                                            ),
                                          ),
                                        ),
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              "Barcode/QRcode (Optional)",
                                              style: TextStyle(
                                                  color: Colors.black54),
                                            ),
                                            SizedBox(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02,
                                            ),
                                            Center(
                                              child: FlatButton(
                                                onPressed: () {
                                                  barScanner();
                                                },
                                                child: Column(
                                                  children: <Widget>[
                                                    Icon(
                                                      Icons.camera,
                                                      color: Colors.black54,
                                                      size:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.08,
                                                    ),
                                                    FittedBox(
                                                      fit: BoxFit.contain,
                                                      child: Text(
                                                          "Scan BarCode/QRCode",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .black54)),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.only(top: 10),
                                              child: barcode.isNotEmpty
                                                  ? Text(barcode)
                                                  : Container(),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          child: FlatButton(
                                              focusNode: _submitFocus,
                                              color: PRIMARYCOLOR,
                                              onPressed: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        this._submitFocus);
                                                if (_formKey.currentState
                                                    .validate()) {
                                                  if (!submitted) {
                                                    setState(() {
                                                      submitted = true;
                                                      report =
                                                          'Creating Product..please wait';
                                                    });
                                                    widget.product.pUnit =
                                                        _unitController.text
                                                                .trim() ??
                                                            "";
                                                    widget.product.pStockCount =
                                                        int.parse(_stockController
                                                                .text.isNotEmpty
                                                            ? _stockController
                                                                .text
                                                            : "0");
                                                    widget.product
                                                            .pManufacturer =
                                                        _manufacturerController
                                                                .text
                                                                .trim() ??
                                                            "";
                                                    widget.product.pMDate =
                                                        manufactureText !=
                                                                'Manufactured Date(optional)'
                                                            ? manufactureText
                                                            : "";
                                                    widget.product
                                                        .pEDate = expiryText !=
                                                            'Expiry Date(optional)'
                                                        ? expiryText
                                                        : "";
                                                    widget.product.pQRCode =
                                                        barcode ?? "";
                                                    widget.product
                                                        .pGroup = psProvider
                                                            .of(context)
                                                            .value['user']
                                                        ['businessCategory'];
                                                    widget.product.pPhoto =
                                                        await uploadMultipleImages(
                                                            widget.product
                                                                .pFilePhoto);
                                                    String pid = await widget
                                                        .product
                                                        .save();
                                                    if (pid.isNotEmpty) {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      AddProduct(
                                                                        withSuccess:
                                                                            true,
                                                                      )));
                                                    }
                                                  } else {
                                                    Scaffold.of(ctx)
                                                        .showSnackBar(SnackBar(
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            content: Text(
                                                                'I am working please wait')));
                                                    //setState(() {
                                                    //submitted=false;
                                                    //});
                                                    //print("working");
                                                  }
                                                }
                                              },
                                              child: !submitted
                                                  ? Center(
                                                      child: Text(
                                                      "Create",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ))
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                            height: MediaQuery
                                                                        .of(
                                                                            context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.03,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 1.5,
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                            )),
                                                        Text(
                                                          "  " + report,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      ],
                                                    )),
                                        ),
                                      ),
                                    ])),
                          ),
                        ],
                      )),
                    ]))));
  }

  Future<List<String>> uploadMultipleImages(List<File> _imageList) async {
    List<String> _imageUrls = List();

    try {
      for (int i = 0; i < _imageList.length; i++) {
        final StorageReference storageReference =
            FirebaseStorage().ref().child("ProductPhoto/${DateTime.now()}.png");

        final StorageUploadTask uploadTask =
            storageReference.putFile(_imageList[i]);

        final StreamSubscription<StorageTaskEvent> streamSubscription =
            uploadTask.events.listen((event) {
          print(event.toString());
        });

        // Cancel your subscription when done.
        await uploadTask.onComplete;
        streamSubscription.cancel();

        String imageUrl = await storageReference.getDownloadURL();
        _imageUrls.add(imageUrl); //all all the urls to the list
      }
      //upload the list of imageUrls to firebase as an array
      return _imageUrls;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
