import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/constants/appColor.dart';
import 'package:pocketshopping/constants/ui_constants.dart';
import 'package:pocketshopping/model/DataModel/categoryData.dart';
import 'package:pocketshopping/page/businessSecondForm.dart';
import 'package:pocketshopping/component/psCard.dart';
import 'package:pocketshopping/model/DataModel/merchantData.dart';
import 'package:pocketshopping/component/psProvider.dart';
import 'package:transparent_image/transparent_image.dart';



class SetupBusiness extends StatefulWidget {
  static String tag = 'SetUpBusiness-page';
  SetupBusiness({
    this.coverUrl=PocketShoppingDefaultCover,
    this.color=PRIMARYCOLOR,
    this.data
  });
  final String coverUrl;
  final Color color;
  final Map<String,dynamic> data;
  @override
  State<StatefulWidget> createState() => _SetupBusinessState();
}

class _SetupBusinessState extends State<SetupBusiness> {

  final _formKey = GlobalKey<FormState>();
  var _nameController = TextEditingController();
  var _addressController = TextEditingController();
  var _descriptionController= TextEditingController();
  var _uniquController = TextEditingController();

  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _pricehtFocus = FocusNode();
  final FocusNode _unique = FocusNode();

  File camresult;
  String bcategory='Restuarant';
  String delivery ='No';
  List<String> serverCategory=[];
  File croppedFile;
  List<String> deliverItems;
  MerchantDataModel mdata;
  bool _autovalidator;
  MerchantDataModel mdm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    camresult = null;
    croppedFile=null;
    deliverItems=['No', 'Yes, I have my own delivery service', 'Yes, Use pocketshooping logistic(only in Abuja)'];
    mdata = MerchantDataModel();
    _autovalidator = false;
  }



  Future getItemImageFromLib()async{
    camresult = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(camresult);
    croppedFile = await ImageCropper.cropImage(
        sourcePath: camresult.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Editor',
        toolbarColor: PRIMARYCOLOR,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
      ),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0
      )

    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('popped');
    setState(() {
      serverCategory=psProvider.of(context).value['category']??['Restuarant','Store',"Bar","Super Market"];
    });
    if(widget.data != null) {
      _nameController..text = widget.data['businessName'];
      _descriptionController..text=widget.data['businessDescription'];
      setState(() {
        bcategory=widget.data['businessCategory'];
        delivery=deliverItems[(widget.data['businessDelivery']-1)];
      });
    }

    final branchUnique = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Enter a unique name for branch';
        }
        else if( !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)){
          return 'Special characters or numbers are not allowed.';
        }
        return null;
      },
      controller: this._uniquController,
      textInputAction: TextInputAction.done,
      focusNode: this._unique,
      keyboardType: TextInputType.phone,
      autofocus: false,

      decoration: InputDecoration(
        labelText:"Branch Unique Name",
        border: InputBorder.none,
      ),
    );

    final name = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Can't be left empty";
        }
        else if (value.length<3) {
          return 'Business name should be valid  word';
        }
        else if( !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)){
          return 'Special characters or numbers are not allowed.';
        }
        return null;
      },
      enabled: widget.data != null?false:true,
      controller: this._nameController,
      textInputAction: TextInputAction.next,
      focusNode: this._nameFocus,
      onFieldSubmitted: (term){
        _nameFocus.unfocus();
        FocusScope.of(context).requestFocus(this._pricehtFocus);
      },
      keyboardType: TextInputType.text,
      autofocus: false,

      decoration: InputDecoration(
        labelText:(widget.data !=null ?"Name: Note.you can not edit business name":"Business Name "),
        hintText: 'Business Name',
        border: InputBorder.none,
      ),
    );

    final description = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Can't be left empty";
        }
        else if (value.length > 250) {
          return 'Business description should not be more than 250 characters';
        }
        return null;
      },
      controller: this._descriptionController,
      textInputAction: TextInputAction.done,
      focusNode: this._descriptionFocus,
      keyboardType: TextInputType.text,
      autofocus: false,
      maxLines: 4,
      decoration: InputDecoration(
        labelText:"Business Description",

        hintText: 'describe your Business',
        border: InputBorder.none,

      ),
    );



    final address = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return "Can't be left empty";
        }
        return null;
      },
      controller: this._addressController,
      textInputAction: TextInputAction.next,
      focusNode: this._pricehtFocus,
      onFieldSubmitted: (term){
        _pricehtFocus.unfocus();
        FocusScope.of(context).requestFocus(this._unique);
      },
      keyboardType: TextInputType.text,
      autofocus: false,
      decoration: InputDecoration(
        labelText:"Business Address",
        hintText: 'Business Address',
        border: InputBorder.none,
      ),
     // inputFormatters: <TextInputFormatter>[
       // WhitelistingTextInputFormatter.digitsOnly
      //],


    );

    final category =  DropdownButtonFormField<String>(
      value: bcategory,
      items:  serverCategory
          .map((label) => DropdownMenuItem(
        child: Text(label,style: TextStyle(color: Colors.black54),),
        value: label,
      ))
          .toList(),
      hint: Text(widget.data != null?bcategory:'category'),
      decoration: InputDecoration(
          border: InputBorder.none
      ),
      onChanged: widget.data != null ?null:(value) {
        setState(() {
          bcategory = value;
        });
      },

    );


    final deliver = DropdownButtonFormField<String>(

      value: delivery,
      items:deliverItems
          .map((label) => DropdownMenuItem(
        child: Text(label,style: TextStyle(color: Colors.black54),),
        value: label,
      ))
          .toList(),
      hint: Text('Rating'),
      decoration: InputDecoration(
        border: InputBorder.none
      ),
      onChanged: (value) {
        setState(() {
          delivery = value;
        });
      },


    );


    final addProduct=Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: FlatButton(
        color: widget.color,
        onPressed: () async{
          // Validate returns true if the form is valid, or false
          // otherwise.
          if (_formKey.currentState.validate()) {
            mdata.bName=_nameController.text.trim();
            mdata.bDescription=_descriptionController.text.trim();
            mdata.bAddress=_addressController.text.trim();
            mdata.bCategory=bcategory.trim();
            mdata.bDelivery= deliverItems.indexOf(delivery)+1;

            if(croppedFile != null)
              {
                mdata.bCroppedPhoto=croppedFile;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            BusinessSetUpSecondPage(data:mdata,
                            fieldData: widget.data !=null ?widget.data:null,)));
              }
            else if(widget.data != null){
              mdata.bPhoto=widget.data['businessPhoto'];
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>BusinessSetUpSecondPage(data:mdata,fieldData: widget.data,)));
            }
            else{
              return (await showDialog(
                  context: context,
                  builder: (context) => new AlertDialog(
                title: new Text('Are you sure?'),
                content: new Text('You want to continue without business cover photo. Note we will use pocketshopping default photo if you fail to upload you business cover photo'),
                actions: <Widget>[
                  new FlatButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: new Text('No'),
                  ),
                  new FlatButton(
                    onPressed: () {
                      mdata.bPhoto=PocketShoppingDefaultCover;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>BusinessSetUpSecondPage(data:mdata)));
                    },
                    child: new Text('Yes'),
                  ),
                ],
              ),
          ));
            }
          }
          else{
            setState(() {
              _autovalidator=true;
            });
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text('Next',style: TextStyle(color: Colors.white),)
        ],),
      ),
    );
    return FutureBuilder<List<String>>(
    future: CategoryData().getAll(),
    builder: (context,AsyncSnapshot<List<String>>snapshot) {
      if(snapshot.hasData){psProvider.of(context).value['category']=snapshot.data;}
     return Scaffold(
          backgroundColor: Colors.white,

          appBar: PreferredSize(
            preferredSize: Size.fromHeight(MediaQuery
                .of(context)
                .size
                .height * 0.1), // here the desired height
            child: AppBar(
              centerTitle: true,
              elevation: 0.0,
              backgroundColor: Colors.white,
              leading: IconButton(

                icon: Icon(Icons.arrow_back_ios, color: PRIMARYCOLOR,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                "Business Setup", style: TextStyle(color: PRIMARYCOLOR),),

              automaticallyImplyLeading: false,
            ),
          ),

          body: CustomScrollView(
              slivers: <Widget>[ SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.02,),
                      psCard(
                        color: widget.color,
                        title: widget.data != null ? "New Branch for " +
                            widget.data['businessName'] : 'New Business',
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            //offset: Offset(1.0, 0), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                        child: Form(
                            key: _formKey,
                            autovalidate: _autovalidator,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: name,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: address,
                                  ),
                                  widget.data != null ?
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: branchUnique,
                                  ) : Container(),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text((widget.data != null
                                                ? "Category: Note.you can not change business category"
                                                : "Select Business Category "),
                                              style: TextStyle(
                                                  color: Colors.black54),)),

                                        category
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: Column(
                                      children: <Widget>[
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              "Will you offer delivery service",
                                              style: TextStyle(
                                                  color: Colors.black54),)),

                                        deliver
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: description,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide( //                   <--- left side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: Column(
                                      children: <Widget>[
                                        Text("Business Cover Photo",
                                          style: TextStyle(
                                              color: Colors.black54),),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceAround,
                                          children: <Widget>[
                                            Center(
                                              child: FlatButton(
                                                onPressed: () {
                                                  getItemImageFromLib();
                                                },
                                                child: Column(
                                                  children: <Widget>[
                                                    Icon(Icons.file_upload,
                                                      color: Colors.black54,
                                                      size: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .height * 0.05,),
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
                                          ],
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(top: 10),
                                          child: croppedFile != null ? Image
                                              .file(croppedFile,
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.3,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.4,
                                            //scale: 2,
                                            fit: BoxFit.scaleDown,
                                          ) : FadeInImage.memoryNetwork(
                                            placeholder: kTransparentImage,
                                            image: widget.data != null
                                                ? widget.data['businessPhoto']
                                                : PocketShoppingDefaultCover,
                                            fit: BoxFit.cover,
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.3,
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .height * 0.4,

                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.02),
                                    child: addProduct,
                                  ),

                                ]
                            )
                        ),
                      ),


                    ],
                  )

              ),
              ]
          )
      );
    }
    );
  }
}
