import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/component/TakePicturePage.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/model/DataModel/productDataModel.dart';
import 'package:pocketshopping/page/admin.dart';
import 'package:pocketshopping/page/admin/nextAddProductPage.dart';
import 'package:recase/recase.dart';

class AddProduct extends StatefulWidget {
  AddProduct({this.withSuccess = false});

  bool withSuccess;

  @override
  State<StatefulWidget> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map formType;
  String btype;
  final TextEditingController _typeAheadController = TextEditingController();
  var _nameController = TextEditingController();
  var _priceController = TextEditingController();
  var _descriptionController = TextEditingController();

  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _pricehtFocus = FocusNode();
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _nextFocus = FocusNode();

  dynamic camresult;
  List<File> croppedFile;
  File pImage;
  int imageCount;
  String pCount;

  BuildContext nctx;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    formType = {
      'Restuarant': 'Item',
      'Super Market': 'Product',
      'Bar': 'Item',
      'Store': 'Product',
      'Park': 'Item',
      'default': 'Product',
    };
    croppedFile = [];
    btype = 'default';
    camresult = null;
    imageCount = 0;
    pCount = "";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      ProductDataModel(mID: psProvider.of(context).value['user']['merchantID'])
          .getCount()
          .then((value) => setState(() => {pCount = "Product Count: $value"}));
    } catch (error) {}
  }

  void _showCamera() async {
    final cameras = await availableCameras();

    final camera = cameras.first;

    camresult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(
                  camera: camera,
                  fabColor: PRIMARYCOLOR,
                )));
    pImage = File(camresult);
    await cropImage(pImage);
    setState(() {});
  }

  cropImage(File image) async {
    File temp;
    temp = await ImageCropper.cropImage(
        sourcePath: pImage.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio3x2,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Editor',
          toolbarColor: PRIMARYCOLOR,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0));
    croppedFile.add(temp);
    imageCount += 1;
    //print('image$imageCount');
    setState(() {});
  }

  Future getItemImageFromLib() async {
    pImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    await cropImage(pImage);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (nctx != null && widget.withSuccess) {
        Scaffold.of(nctx).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
          content: Text('1 new product added'),
          action: SnackBarAction(
            label: "View All",
            textColor: Colors.white,
            //disabledTextColor: TEXT_BLACK_LIGHT,
            onPressed: () {
              print("I know you are testing the action in the SnackBar!");
            },
          ),
        ));
        widget.withSuccess = false;
      }
    });

    final name = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter a ${formType[btype]} name';
        } else if (value.length <= 2) {
          return 'Enter a valid ${formType[btype]} name';
        } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Special characters or numbers are not allowed.';
        }
        return null;
      },
      controller: this._nameController,
      textInputAction: TextInputAction.next,
      focusNode: this._nameFocus,
      onFieldSubmitted: (term) {
        _nameFocus.unfocus();
        FocusScope.of(context).requestFocus(this._pricehtFocus);
      },
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        labelText: "${formType[btype]} Name",
        hintText: '${formType[btype]} Name',
        border: InputBorder.none,
      ),
    );

    final description = TextFormField(
      validator: (value) {
        if (value.isEmpty && value.length > 250) {
          return 'description can not be more than 250 characters';
        }
        return null;
      },
      controller: this._descriptionController,
      textInputAction: TextInputAction.done,
      focusNode: this._descriptionFocus,
      keyboardType: TextInputType.text,
      autofocus: false,
      maxLines: 3,
      decoration: InputDecoration(
        //labelText:"${formType[btype]} description",

        hintText: '${formType[btype]} description',
        border: InputBorder.none,
      ),
    );

    final price = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter a ${formType[btype]} price';
        } else if (num.tryParse(value) == null) {
          return 'Enter a valid ${formType[btype]} price';
        }
        return null;
      },
      controller: this._priceController,
      textInputAction: TextInputAction.next,
      focusNode: this._pricehtFocus,
      onFieldSubmitted: (term) {
        _pricehtFocus.unfocus();
        FocusScope.of(context).requestFocus(this._categoryFocus);
      },
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        labelText: "${formType[btype]} Price",
        hintText: '${formType[btype]} Price',
        border: InputBorder.none,
      ),
      inputFormatters: <TextInputFormatter>[
        WhitelistingTextInputFormatter.digitsOnly
      ],
    );

    final category = TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        focusNode: this._categoryFocus,
        controller: this._typeAheadController,
        decoration: InputDecoration(
          labelText: '${formType[btype]} Category',
          border: InputBorder.none,
        ),
        textInputAction: TextInputAction.done,
      ),
      suggestionsCallback: (pattern) async {
        List<String> data = List();
        if (pattern.isNotEmpty) {
          data = await ProductDataModel().getCategory(pattern.sentenceCase);
        } else {
          data.add(" ");
        }
        return data;
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
        this._typeAheadController.text = suggestion;
      },
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter  ${formType[btype]} category or select from list';
        } else if (value.length <= 2) {
          return 'Enter a valid ${formType[btype]} name';
        } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
          return 'Special characters or numbers are not allowed.';
        }
        return null;
      },
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.2,
        ),
      ),
      autoFlipDirection: true,
      hideOnEmpty: true,
    );

    final addProduct = Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
        focusNode: _nextFocus,
        color: PRIMARYCOLOR,
        onPressed: () {
          FocusScope.of(context).requestFocus(this._nextFocus);
          if (_formKey.currentState.validate()) {
            ProductDataModel product = ProductDataModel(
                mID: psProvider.of(context).value['user']['merchantID'],
                pDesc: _descriptionController.text.trim(),
                pName: _nameController.text.trim(),
                pPrice: double.parse(_priceController.text.trim()),
                pCategory: _typeAheadController.text.trim().sentenceCase,
                pUploader: psProvider.of(context).value['uid'],
                pFilePhoto: croppedFile.isNotEmpty ? croppedFile : []);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddProductNextPage(
                          product: product,
                        )));
          }
        },
        child: Center(
            child: Text(
          'Next',
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
    return WillPopScope(
        onWillPop: () async {
          return Navigator.push(
              context, MaterialPageRoute(builder: (context) => AdminPage()));
        },
        child: Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                  MediaQuery.of(context).size.height *
                      0.1), // here the desired height
              child: AppBar(
                centerTitle: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: PRIMARYCOLOR,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AdminPage()));
                  },
                ),
                title: Text(
                  "Product",
                  style: TextStyle(color: PRIMARYCOLOR),
                ),
                automaticallyImplyLeading: false,
              ),
            ),
            body: Builder(builder: (ctx) {
              //if(mounted)
              //Scaffold.of(ctx).showSnackBar(SnackBar(content: Text('Welcome User')));
              nctx = ctx;
              return CustomScrollView(
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate(
                    [
                      Container(
                        child: Center(
                          child: Text(
                            pCount,
                            style: TextStyle(color: PRIMARYCOLOR, fontSize: 18),
                          ),
                        ),
                      ),
                      psCard(
                          color: PRIMARYCOLOR,
                          title: 'Product Search',
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              //offset: Offset(1.0, 0), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ],
                          child: FlatButton(
                            onPressed: () {},
                            color: PRIMARYCOLOR,
                            child: Text(
                              "Search For ${formType[btype]}",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                      Center(
                        child: Text(
                          "Or",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      psCard(
                        color: PRIMARYCOLOR,
                        title: 'Add New Product',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    child: name,
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
                                    child: price,
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
                                    child: category,
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
                                    child: description,
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
                                            "${formType[btype]} Photo: $imageCount/5",
                                            style: TextStyle(
                                                color: Colors.black54)),
                                        imageCount < 5
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: <Widget>[
                                                  Center(
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        getItemImageFromLib();
                                                      },
                                                      child: Column(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.file_upload,
                                                            color:
                                                                Colors.black54,
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.05,
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Text(
                                                                "Select a Photo",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54)),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        _showCamera();
                                                      },
                                                      child: Column(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.photo_camera,
                                                            color:
                                                                Colors.black54,
                                                            size: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.05,
                                                          ),
                                                          FittedBox(
                                                            fit: BoxFit.contain,
                                                            child: Text(
                                                              "Capture a Photo",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black54),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Container(),
                                        Container(
                                            padding: EdgeInsets.only(top: 10),
                                            child: croppedFile.isNotEmpty
                                                ? Wrap(
                                                    spacing: 5.0,
                                                    children:
                                                        List<Widget>.generate(
                                                            croppedFile.length,
                                                            (index) =>
                                                                Container(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.4,
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          width:
                                                                              1,
                                                                          color: Colors
                                                                              .grey
                                                                              .withOpacity(0.5))),
                                                                  child: Column(
                                                                    children: <
                                                                        Widget>[
                                                                      Align(
                                                                        alignment:
                                                                            Alignment.centerLeft,
                                                                        child:
                                                                            IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              croppedFile.remove(croppedFile[index]);
                                                                              imageCount -= 1;
                                                                            });
                                                                          },
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          icon:
                                                                              Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Colors.black54,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Image
                                                                          .file(
                                                                        croppedFile[
                                                                            index],
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      )
                                                                    ],
                                                                  ),
                                                                )).toList())
                                                : Container())
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(
                                        MediaQuery.of(context).size.width *
                                            0.02),
                                    child: addProduct,
                                  ),
                                ])),
                      ),
                    ],
                  )),
                ],
              );
            })));
  }
}
