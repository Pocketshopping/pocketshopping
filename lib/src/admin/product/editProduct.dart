import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/ui/shared/imageEditor.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:recase/recase.dart';

class EditProductForm extends StatefulWidget {
  EditProductForm({this.session,this.product});

  final Session session;
  final Product product;

  @override
  State<StatefulWidget> createState() => _EditProductFormState();
}

class _EditProductFormState extends State<EditProductForm> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '1');
  final TextEditingController _categoryController = TextEditingController();
  Session CurrentUser;
  //ProductBloc _productBloc;
  bool _nameEnabler;
  bool _priceEnabler;
  bool _categoryEnabler;
  bool _descriptionEnabler;
  bool _countEnabler;
  bool _unitEnabler;
  List<bool> isSelected;
  File pImage;
  List<String> images;
  bool working;


  @override
  void initState() {
    working = false;
    images=(widget.product.pPhoto).cast<String>().toList();
    images.remove(PRODUCTDEFAULT);
    isSelected = [widget.product.availability==0, widget.product.availability==1];
    _nameEnabler = false;
    _priceEnabler = false;
    _categoryEnabler = false;
    _descriptionEnabler = false;
    _countEnabler = false;
    _unitEnabler = false;
    _nameController.text = widget.product.pName;
    _priceController.text = widget.product.pPrice.toString();
    _categoryController.text = widget.product.pCategory;
    _stockController.text = widget.product.pStockCount.toString();
    _unitController.text = widget.product.pUnit;
    _descriptionController.text = widget.product.pDesc;
    //print(widget.session.merchant.bName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double marginLR = MediaQuery.of(context).size.width;
      return WillPopScope(
          onWillPop: () async {
               Get.back(result: 'Refresh');
               return true;

          },
          child: Scaffold(
              appBar: PreferredSize(
                  preferredSize: Size.fromHeight(
                      MediaQuery.of(context).size.height *
                          0.08),
                  child: AppBar(
                    title: Text('Product Settings',style: TextStyle(color: PRIMARYCOLOR),),
                    backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    elevation: 0.0,
                  )
              ),
              backgroundColor: Colors.white,
              body: CustomScrollView(slivers: <Widget>[
                SliverList(
                    delegate: SliverChildListDelegate([
                      Container(
                          padding: EdgeInsets.only(
                              left: marginLR * 0.01, right: marginLR * 0.01),
                          margin: EdgeInsets.only(top: marginLR * 0.01),
                          child: Center(
                            child: psCard(
                              color: PRIMARYCOLOR,
                              title: '${widget.product.pName}',
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  //offset: Offset(1.0, 0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              child: Form(
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
                                              MediaQuery.of(context).size.width * 0.02),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller: _nameController,
                                                  decoration: InputDecoration(
                                                      labelText: 'Product Name',
                                                      hintText: 'Product Name',
                                                      border: InputBorder.none),
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: false,
                                                  autovalidate: true,
                                                  enabled: _nameEnabler,
                                                  autofocus: _nameEnabler,
                                                ),
                                              ),
                                              !working?
                                              Expanded(
                                                flex: 0,
                                                child: _nameEnabler?FlatButton(
                                                  onPressed: ()async{
                                                    if(_nameController.text.isNotEmpty){
                                                      await ProductRepo.updateProduct(widget.product.pID,
                                                          {
                                                            'productName':_nameController.text.sentenceCase,
                                                            'index': ProductRepo.makeIndexList(_nameController.text),
                                                          });
                                                    setState(() {
                                                      _nameEnabler=false;
                                                    });
                                                    }
                                                  },
                                                  color: PRIMARYCOLOR,
                                                  child: Text('Save',style: TextStyle(color: Colors.white),),
                                                ):
                                                FlatButton(
                                                  onPressed: ()async{

                                                      setState(() {
                                                        _nameEnabler=true;
                                                      });

                                                  },
                                                  child: Text('Edit'),
                                                )
                                              ):Container()
                                              ,
                                            ],
                                          )
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
                                              MediaQuery.of(context).size.width * 0.02),
                                          child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _priceController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Product Price',
                                                        hintText: 'Product Price',
                                                        border: InputBorder.none),
                                                    keyboardType: TextInputType.number,
                                                    autocorrect: false,
                                                    autovalidate: true,
                                                    enabled: _priceEnabler,
                                                    inputFormatters: <TextInputFormatter>[
                                                      //WhitelistingTextInputFormatter.digitsOnly
                                                    ],
                                                  ),
                                                ),
                                                !working?
                                                Expanded(
                                                    flex: 0,
                                                    child: _priceEnabler?FlatButton(
                                                      onPressed: ()async{
                                                        if(_priceController.text.isNotEmpty){
                                                          await ProductRepo.updateProduct(widget.product.pID,
                                                              {
                                                                'productPrice':double.tryParse(_priceController.text)??0.0,
                                                              });
                                                          setState(() {
                                                            _priceEnabler=false;
                                                          });
                                                        }
                                                      },
                                                      color: PRIMARYCOLOR,
                                                      child: Text('Save',style: TextStyle(color: Colors.white),),
                                                    ):
                                                    FlatButton(
                                                      onPressed: (){
                                                        setState(() {
                                                          _priceEnabler=true;
                                                        });
                                                      },
                                                      child: Text('Edit'),
                                                    )
                                                ):Container(),
                                              ],
                                            )
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
                                            child:
                                          Row(
                                        children: [
                                        Expanded(
                                        child: TypeAheadFormField(
                                          textFieldConfiguration:
                                          TextFieldConfiguration(
                                            controller: this._categoryController,
                                            decoration: InputDecoration(
                                              labelText: 'Product Category',
                                              border: InputBorder.none,
                                            ),
                                            textInputAction: TextInputAction.done,
                                            keyboardType: TextInputType.text,
                                            autocorrect: true,
                                            enabled: _categoryEnabler
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            List<String> data = List();
                                            if (pattern.isNotEmpty) {
                                              data = await ProductRepo()
                                                  .getCategory(
                                                  pattern.sentenceCase);
                                              return data;
                                            } else {
                                              return data;
                                            }
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          transitionBuilder:
                                              (context, suggestionBox, controller) {
                                            return suggestionBox;
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            this._categoryController.text =
                                                suggestion;
                                          },
                                          autovalidate: true,
                                          suggestionsBoxDecoration:
                                          SuggestionsBoxDecoration(
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  0.2,
                                            ),
                                          ),
                                          autoFlipDirection: true,
                                          hideOnEmpty: true,

                                        )
                                        ),
                                          !working?
                                            Expanded(
                                                flex: 0,
                                                child: _categoryEnabler?FlatButton(
                                                  onPressed: ()async{
                                                    if(_categoryController.text.isNotEmpty){
                                                      await ProductRepo.updateProduct(widget.product.pID,
                                                          {
                                                            'productCategory':_categoryController.text.sentenceCase,
                                                          });
                                                      setState(() {
                                                        _categoryEnabler=false;
                                                      });
                                                    }
                                                  },
                                                  color: PRIMARYCOLOR,
                                                  child: Text('Save',style: TextStyle(color: Colors.white),),
                                                ):
                                                FlatButton(
                                                  onPressed: (){
                                                    setState(() {
                                                      _categoryEnabler=true;
                                                    });
                                                  },
                                                  child: Text('Edit'),
                                                )
                                            ):Container(),
                                          ],
                                          )
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
                                              MediaQuery.of(context).size.width * 0.02),
                                          child:
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _descriptionController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Product Description',
                                                        hintText: 'Product Description',
                                                        border: InputBorder.none),
                                                    keyboardType: TextInputType.text,
                                                    autocorrect: false,
                                                    autovalidate: false,
                                                    enabled: _descriptionEnabler,
                                                    maxLines: 3,
                                                  ),
                                                ),
                                                !working?
                                                Expanded(
                                                    flex: 0,
                                                    child: _descriptionEnabler?FlatButton(
                                                      onPressed: ()async{
                                                        if(_descriptionController.text.isNotEmpty){
                                                          await ProductRepo.updateProduct(widget.product.pID,
                                                              {
                                                                'productDesc':_descriptionController.text.sentenceCase,
                                                              });
                                                          setState(() {
                                                            _descriptionEnabler=false;
                                                          });
                                                        }
                                                      },
                                                      color: PRIMARYCOLOR,
                                                      child: Text('Save',style: TextStyle(color: Colors.white),),
                                                    ):
                                                    FlatButton(
                                                      onPressed: (){
                                                        setState(() {
                                                          _descriptionEnabler=true;
                                                        });
                                                      },
                                                      child: Text('Edit'),
                                                    )
                                                ):Container(),
                                              ],
                                            )
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
                                              MediaQuery.of(context).size.width * 0.02),
                                          child:
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: _stockController,
                                                    decoration: InputDecoration(
                                                        labelText: 'Product Stock Count',
                                                        hintText: 'Product Stock Count',
                                                        border: InputBorder.none),
                                                    keyboardType: TextInputType.number,
                                                    autocorrect: false,
                                                    enabled: _countEnabler,
                                                    inputFormatters: <TextInputFormatter>[
                                                      WhitelistingTextInputFormatter.digitsOnly
                                                    ],
                                                  ),
                                                ),
                                                !working?
                                                Expanded(
                                                    flex: 0,
                                                    child: _countEnabler?FlatButton(
                                                      onPressed: ()async{
                                                        if(_stockController.text.isNotEmpty){
                                                          await ProductRepo.updateProduct(widget.product.pID,
                                                              {
                                                                'productStockCount':int.tryParse(_stockController.text)??1,
                                                              });
                                                          setState(() {
                                                            _countEnabler=false;
                                                          });
                                                        }
                                                      },
                                                      color: PRIMARYCOLOR,
                                                      child: Text('Save',style: TextStyle(color: Colors.white),),
                                                    ):
                                                    FlatButton(
                                                      onPressed: (){
                                                        setState(() {
                                                          _countEnabler=true;
                                                        });
                                                      },
                                                      child: Text('Edit'),
                                                    )
                                                ):Container(),
                                              ],
                                            )
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
                                            child:
                                          Row(
                                        children: [
                                        Expanded(
                                        child: TypeAheadFormField(
                                          textFieldConfiguration:
                                          TextFieldConfiguration(
                                            controller: _unitController,
                                            decoration: InputDecoration(
                                              labelText:
                                              'Product Unit Type. i.e KG, Liter, Meter',
                                              border: InputBorder.none,
                                            ),
                                            textInputAction: TextInputAction.done,
                                            keyboardType: TextInputType.text,
                                            autocorrect: true,
                                            enabled: _unitEnabler
                                          ),
                                          suggestionsCallback: (pattern) async {
                                            List<String> data = List();
                                            if (pattern.isNotEmpty) {
                                              // data = await MerchantRepo().getCategory(pattern.sentenceCase);
                                              return data;
                                            } else {
                                              return data;
                                            }
                                          },
                                          itemBuilder: (context, suggestion) {
                                            return ListTile(
                                              title: Text(suggestion),
                                            );
                                          },
                                          transitionBuilder:
                                              (context, suggestionBox, controller) {
                                            return suggestionBox;
                                          },
                                          onSuggestionSelected: (suggestion) {
                                            this._categoryController.text =
                                                suggestion;
                                          },
                                          suggestionsBoxDecoration:
                                          SuggestionsBoxDecoration(
                                            constraints: BoxConstraints(
                                              maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                                  0.2,
                                            ),
                                          ),
                                          autoFlipDirection: true,
                                          hideOnEmpty: true,
                                        )
                                          ),
                                          !working?
                                          Expanded(
                                              flex: 0,
                                              child: _unitEnabler?FlatButton(
                                                onPressed: ()async{
                                                  if(_unitController.text.isNotEmpty){
                                                    await ProductRepo.updateProduct(widget.product.pID,
                                                        {
                                                          'productUnit':_unitController.text,
                                                        });
                                                    setState(() {
                                                      _unitEnabler=false;
                                                    });
                                                  }
                                                },
                                                color: PRIMARYCOLOR,
                                                child: Text('Save',style: TextStyle(color: Colors.white),),
                                              ):
                                              FlatButton(
                                                onPressed: (){
                                                  setState(() {
                                                    _unitEnabler=true;
                                                  });
                                                },
                                                child: Text('Edit'),
                                              )
                                          ):Container(),
                                        ],
                                        )
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
                                            child:
                                            Column(
                                              children:[
                                                Center(
                                                  child: Text('Product Availability'),
                                                ),
                                            SizedBox(height: 10,),
                                            Center(child: ToggleButtons(
                                              borderColor: Colors.blue.withOpacity(0.5),
                                              fillColor: Colors.blue,
                                              borderWidth: 1,
                                              selectedBorderColor: Colors.blue,
                                              selectedColor: Colors.white,
                                              borderRadius: BorderRadius.circular(0),
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'Unvailable',
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    'Available',
                                                  ),
                                                ),
                                              ],
                                              onPressed: (int index) async{
                                                setState(() {
                                                  for (int i = 0; i < isSelected.length; i++) {
                                                    isSelected[i] = i == index;
                                                  }
                                                });
                                                if(!working) {
                                                  await ProductRepo
                                                      .updateProduct(
                                                      widget.product.pID,
                                                      {
                                                        'productAvailability': isSelected
                                                            .indexOf(true),
                                                      });
                                                  setState(() {});
                                                }
                                              },
                                              isSelected: isSelected,
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width,
                                                  minWidth: MediaQuery.of(context).size.width*0.25
                                              ),
                                            ),
                                            )
                                            ]
                                        )
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
                                              MediaQuery.of(context).size.width * 0.02),
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                  "Product Photo: ${images.length}/5",
                                                  style:
                                                  TextStyle(color: Colors.black54)),
                                              images.length < 5 && !working
                                                  ? Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                                children: <Widget>[
                                                  Center(
                                                    child: FlatButton(
                                                      onPressed: () {
                                                        _showCamera(1);
                                                      },
                                                      child: Column(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.file_upload,
                                                            color: Colors.black54,
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
                                                        _showCamera(0);
                                                      },
                                                      child: Column(
                                                        children: <Widget>[
                                                          Icon(
                                                            Icons.photo_camera,
                                                            color: Colors.black54,
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
                                                  child: images.isNotEmpty
                                                      ? Wrap(
                                                      spacing: 5.0,
                                                      children:
                                                      List<Widget>.generate(
                                                          images
                                                              .length,
                                                              (index) => Container(
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
                                                                  Alignment
                                                                      .centerLeft,
                                                                  child:
                                                                  !working?
                                                                  IconButton(
                                                                    onPressed:
                                                                        () {
                                                                         FirebaseStorage.instance.getReferenceFromUrl(images[index]).then((value){
                                                                          value.delete().then((value) => null);
                                                                          images.remove(images[index]);
                                                                          ProductRepo.updateProduct(widget.product.pID, {'productPhoto':images.isNotEmpty?images:[PRODUCTDEFAULT]}).then((value)
                                                                          {
                                                                            setState(() {});
                                                                          });

                                                                         });


                                                                    },
                                                                    alignment:
                                                                    Alignment.centerLeft,
                                                                    icon:
                                                                    Icon(
                                                                      Icons
                                                                          .delete,
                                                                      color:
                                                                      Colors.black54,
                                                                    ),
                                                                  ):Container(),
                                                                ),
                                                                Image.network(
                                                                  images[
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
                                        /*!working?
                                        Container(
                                            padding: EdgeInsets.all(
                                                MediaQuery.of(context).size.width *
                                                    0.02),
                                            child: Center(
                                                child: FlatButton.icon(
                                                  onPressed:(){
                                                    Get.defaultDialog(
                                                      title: 'Confirm',
                                                      content: Text('Are you sure. this process can not be undone'),
                                                      cancel: FlatButton(
                                                        onPressed: (){Get.back();},
                                                        child: Text('No'),
                                                      ),
                                                      confirm: FlatButton(
                                                        onPressed: ()async{
                                                          Get.back();
                                                          Get.snackbar('', 'Deleting',
                                                              backgroundColor: Colors.grey,
                                                              colorText: Colors.white,
                                                          snackStyle: SnackStyle.GROUNDED);
                                                          await ProductRepo.deleteProduct(widget.product.pID);
                                                          Get.back();
                                                          Get.snackbar('', 'Deleting',
                                                              backgroundColor: PRIMARYCOLOR,colorText: Colors.white,
                                                              snackStyle: SnackStyle.GROUNDED);
                                                          Get.back(result: 'Refresh');
                                                        },
                                                        child: Text('Yes'),
                                                      ),

                                                    );
                                                  },
                                                  padding: EdgeInsets.all(12),
                                                  color: Colors.red,
                                                  icon: Icon(Icons.delete,color: Colors.white,),
                                                  label:  Text('Delete Product',
                                                        style: TextStyle(
                                                            color: Colors.white)),

                                                )
                                            )):Container(),*/
                                      ])),
                            ),
                          )),
                    ]))
              ])));

  }

  void _showCamera(int type) async {
    dynamic camresult;
    if(type == 0) {
      final cameras = await availableCameras();
      final camera = cameras.first;
      camresult = await Get.to(TakePicturePage(camera: camera, fabColor: PRIMARYCOLOR,));
    }
    else{
      var hold = await ImagePicker.pickImage(source: ImageSource.gallery);
      camresult = hold.path;
    }


    if(camresult != null) {
      setState(() {
        pImage = File(camresult);
      });

      Get.dialog(Editor(
        imageFile: pImage,
        callbvck: (image)async{
          setState(() {working = true; });
          Get.snackbar('Uploading',
              'Product Image Uploading',
              backgroundColor: Colors.grey,
              colorText: Colors.black,
              snackStyle: SnackStyle.GROUNDED,
            duration: Duration(days: 365)
          );
          var _images = await Utility.uploadMultipleImages([image]);
          Get.back();
          if(_images.isNotEmpty)
          Get.snackbar('Uploaded',
            'Product Image Uploaded',duration: Duration(seconds: 3),
            backgroundColor: PRIMARYCOLOR,
            colorText: Colors.white,
            snackStyle: SnackStyle.GROUNDED,

          );
          else
            Get.snackbar('Upload Error',
              'Failed Uploading image',duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackStyle: SnackStyle.GROUNDED,

            );


          images.addAll(_images);
          await ProductRepo.updateProduct(widget.product.pID, {'productPhoto':images});
          working = false;
          setState(() { });

        }));
      //Utility.cropImage(pImage).then((value) => print(value.toString()));

    }


  }




  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

