import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pocketshopping/src/authentication_bloc/authentication_bloc.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:recase/recase.dart';


class ProductForm extends StatefulWidget {
  ProductForm({
    this.session
  });
  final Session session;
  @override
  State<StatefulWidget> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController  = TextEditingController();
  final TextEditingController _descriptionController  = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _stockController = TextEditingController(text: '1');
  final TextEditingController _categoryController = TextEditingController();
  Session CurrentUser;
  ProductBloc _productBloc;


  bool get isPopulated => _nameController.text.isNotEmpty && _priceController.text.isNotEmpty
      && _categoryController.text.isNotEmpty;

  bool isRegisterButtonEnabled(ProductState state) {
    return state.isFormValid && isPopulated && !state.isSubmitting;
  }


  @override
  void initState() {
    super.initState();

    _productBloc = BlocProvider.of<ProductBloc>(context);
    _nameController.addListener(_onNameChanged);
    _priceController.addListener(_onPriceChanged);
    _categoryController.addListener(_onCategoryChanged);
    //print(widget.session.merchant.bName);
  }


  @override
  Widget build(BuildContext context) {
    double marginLR =  MediaQuery.of(context).size.width;
    return BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.isSubmitting) {
            if(state.isUploading) {
              print('uploading ${state.isUploading}');
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery
                            .of(context)
                            .size
                            .height * 0.1),
                        child: Center(
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('assets/images/cloud-upload.gif',
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.4,
                                  fit: BoxFit.cover,
                                ),
                                Text("Loading", style: TextStyle(
                                    fontSize: 16, color: Colors.black54),),
                              ],
                            )

                        ),
                      ),
                    ),
                    duration: Duration(days: 365),
                  ),
                );
            }
            else{
              Scaffold.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white,
                    content: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery
                            .of(context)
                            .size
                            .height * 0.1),
                        child: Center(
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset('assets/images/working.gif',
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width,
                                  height: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.4,
                                  fit: BoxFit.cover,
                                ),
                                Text("Loading", style: TextStyle(
                                    fontSize: 16, color: Colors.black54),),
                              ],
                            )

                        ),
                      ),
                    ),
                    duration: Duration(days: 365),
                  ),
                );
            }

          }
          if (state.isSuccess) {

            _nameController.clear();
            _unitController.clear();
            _descriptionController.clear();
            _categoryController.clear();
            _priceController.clear();
            _stockController.text='1';
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  backgroundColor: Colors.white,
                  content: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: MediaQuery
                          .of(context)
                          .size
                          .height,
                      child: Container(

                        color: Colors.white,
                        child:

                        Column(

                          children: [
                            Container(
                              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.height*0.05,
                                right: MediaQuery.of(context).size.height*0.05,
                              ),
                              child: Center(
                                  child:
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Image.asset('assets/images/completed.gif',
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height*0.4,
                                        fit: BoxFit.cover,
                                      ),
                                      Text("Product has been added",style: TextStyle(fontSize: 16,color: Colors.black54),),
                                      Container(height: 10,),
                                      Center(child:Text("Note. Adding more product will increase your visibility"
                                          "",style: TextStyle(fontSize: 14,color: Colors.black54),)),
                                      Container(height: 10,),
                                      FlatButton(
                                        onPressed: (){
                                          Scaffold.of(context).hideCurrentSnackBar();
                                        },
                                        color: PRIMARYCOLOR,
                                        child: Padding(
                                          padding:  EdgeInsets.all( MediaQuery.of(context).size.height*0.02),
                                          child: Text("New Product",style: TextStyle(color: Colors.white),),
                                        ),
                                      )
                                    ],
                                  )

                              ),
                            ),



                            // Progress bar

                          ],
                        ),
                      )
                  ),
                  duration: Duration(days: 365),
                ),
              );
          }
          if (state.isFailure) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Error Encountered adding product. Check your network connection and try again'),
                      Icon(Icons.error),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child:BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              return WillPopScope(
                  onWillPop: ()async{
                    if(state.isSubmitting)
                      return false;
                    else{
                      return true;
                    }
                  },
                  child:Scaffold(
                    backgroundColor: Colors.white,
                    body:

                    CustomScrollView(
                        slivers: <Widget>[
                    SliverList(
                    delegate: SliverChildListDelegate(
                        [

                          Container(
                            child: Center(
                              child: Text( '${state.count} Product(s)',
                                style: TextStyle(color: PRIMARYCOLOR, fontSize: 18),),
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
                                child: Text("Search For New Product",
                                  style: TextStyle(color: Colors.white),),
                              )
                          ),

                          Center(
                            child: Text("Or", style: TextStyle(fontSize: 18),),
                          ),

                    Container(
                        padding: EdgeInsets.only(left: marginLR*0.01, right: marginLR*0.01),
                        margin: EdgeInsets.only(top: marginLR*0.01),
                        child:Center(child:

                              psCard(
                                color: PRIMARYCOLOR,
                                title: 'New Product',
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    //offset: Offset(1.0, 0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                child:
                                Form(
                                    child:
                                    Column(
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
                                            child:  TextFormField(
                                              controller: _nameController,
                                              decoration: InputDecoration(
                                                labelText: 'Product Name',
                                                  hintText: 'Product Name',
                                                  border: InputBorder.none
                                              ),
                                              keyboardType: TextInputType.text,
                                              autocorrect: false,
                                              autovalidate: true,
                                              validator: (_) {
                                                return !state.isNameValid ? 'Invalid Name' : null;
                                              },
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
                                            child: TextFormField(
                                              controller: _priceController,
                                              decoration: InputDecoration(
                                                labelText: 'Product Price',
                                                  hintText: 'Product Price',
                                                  border: InputBorder.none
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: false,
                                              autovalidate: true,
                                              inputFormatters: <TextInputFormatter>[
                                                //WhitelistingTextInputFormatter.digitsOnly
                                              ],
                                              validator: (_) {
                                                return !state.isPriceValid ? 'Invalid Price' : null;
                                              },
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
                                              child: TypeAheadFormField(
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: this._categoryController,
                                  decoration: InputDecoration(
                                    labelText: 'Product Category',
                                    border: InputBorder.none,

                                  ),
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  autocorrect: true,
                                ),

                                suggestionsCallback: (pattern)async {
                                  List<String> data=List();
                                  if(pattern.isNotEmpty){
                                   data = await ProductRepo().getCategory(pattern.sentenceCase);
                                    return data;
                                  }
                                  else{
                                    return data;
                                  }

                                },
                                itemBuilder: (context,suggestion){
                                  return ListTile(
                                    title: Text(suggestion),
                                  );
                                },
                                transitionBuilder: (context,suggestionBox,controller){
                                  return suggestionBox;
                                },
                                onSuggestionSelected: (suggestion){
                                  this._categoryController.text=suggestion;
                                },
                                autovalidate: true,
                                validator: (_) {
                                  return !state.isCategoryValid ? 'Invalid Category' : null;
                                },
                                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                  constraints: BoxConstraints(
                                    maxHeight: MediaQuery.of(context).size.height*0.2,
                                  ),
                                ),
                                autoFlipDirection: true,
                                hideOnEmpty: true,

                              )
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
                                            child:  TextFormField(
                                              controller: _descriptionController,
                                              decoration: InputDecoration(
                                                  labelText: 'Product Description',
                                                  hintText: 'Product Description',
                                                  border: InputBorder.none
                                              ),
                                              keyboardType: TextInputType.text,
                                              autocorrect: false,
                                              autovalidate: false,
                                              maxLines: 3,

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
                                            child: TextFormField(
                                              controller: _stockController,
                                              decoration: InputDecoration(
                                                labelText: 'Product Stock Count',
                                                  hintText: 'Product Stock Count',
                                                  border: InputBorder.none
                                              ),
                                              keyboardType: TextInputType.number,
                                              autocorrect: false,
                                              inputFormatters: <TextInputFormatter>[
                                                WhitelistingTextInputFormatter.digitsOnly
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
                                              child: TypeAheadFormField(
                                                textFieldConfiguration: TextFieldConfiguration(
                                                  controller: _unitController,
                                                  decoration: InputDecoration(
                                                    labelText: 'Product Unit Type. i.e KG, Liter, Meter',
                                                    border: InputBorder.none,

                                                  ),
                                                  textInputAction: TextInputAction.done,
                                                  keyboardType: TextInputType.text,
                                                  autocorrect: true,
                                                ),

                                                suggestionsCallback: (pattern)async {
                                                  List<String> data=List();
                                                  if(pattern.isNotEmpty){
                                                    // data = await MerchantRepo().getCategory(pattern.sentenceCase);
                                                    return data;
                                                  }
                                                  else{
                                                    return data;
                                                  }

                                                },
                                                itemBuilder: (context,suggestion){
                                                  return ListTile(
                                                    title: Text(suggestion),
                                                  );
                                                },
                                                transitionBuilder: (context,suggestionBox,controller){
                                                  return suggestionBox;
                                                },
                                                onSuggestionSelected: (suggestion){
                                                  this._categoryController.text=suggestion;
                                                },
                                                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                                                  constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height*0.2,
                                                  ),
                                                ),
                                                autoFlipDirection: true,
                                                hideOnEmpty: true,

                                              )
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
                                            padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.02),
                                            child: Column(
                                              children: <Widget>[
                                                Text("Barcode/QRcode (Optional)",style: TextStyle(color: Colors.black54),),
                                                SizedBox(height: MediaQuery.of(context).size.height*0.02,),
                                                Center(
                                                  child: FlatButton(
                                                    onPressed: (){
                                                      _productBloc.add(CaptureBarCode());
                                                    },
                                                    child: Column(
                                                      children: <Widget>[
                                                        Icon(Icons.camera,
                                                          color: Colors.black54,
                                                          size: MediaQuery.of(context).size.height*0.08,),
                                                        FittedBox(
                                                          fit: BoxFit.contain,
                                                          child: Text("Scan BarCode/QRCode",
                                                              style: TextStyle(color: Colors.black54)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: state.barCode.isNotEmpty?Text('Product Code: ${state.barCode}'):Container(),
                                                )
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
                                                Text(
                                                    "Product Photo: ${state.croppedImage.length}/5",
                                                    style: TextStyle(
                                                        color: Colors.black54)),
                                                state.croppedImage.length < 5 ?
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceAround,
                                                  children: <Widget>[
                                                    Center(
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          _productBloc.add(ImageFromGallery());
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
                                                    Center(
                                                      child: FlatButton(
                                                        onPressed: () {
                                                          _showCamera();
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Icon(Icons.photo_camera,
                                                              color: Colors.black54,
                                                              size: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .height * 0.05,),
                                                            FittedBox(
                                                              fit: BoxFit.contain,
                                                              child: Text(
                                                                "Capture a Photo",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black54),),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ) : Container(),
                                                Container(
                                                    padding: EdgeInsets.only(top: 10),
                                                    child: state.croppedImage.isNotEmpty ? Wrap(
                                                        spacing: 5.0,
                                                        children: List<Widget>.generate(
                                                            state.croppedImage.length, (index) =>
                                                            Container(
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width * 0.4,
                                                              decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: Colors.grey
                                                                          .withOpacity(
                                                                          0.5))
                                                              ),
                                                              child: Column(

                                                                children: <Widget>[
                                                                  Align(
                                                                    alignment: Alignment
                                                                        .centerLeft,
                                                                    child: IconButton(
                                                                      onPressed: () {
                                                                        setState(() {
                                                                          state.croppedImage
                                                                              .remove(
                                                                              state.croppedImage[index]);
                                                                        });
                                                                      },
                                                                      alignment: Alignment
                                                                          .centerLeft,
                                                                      icon: Icon(
                                                                        Icons.delete,
                                                                        color: Colors
                                                                            .black54,),
                                                                    ),
                                                                  ),
                                                                  Image.file(
                                                                    state.croppedImage[index],
                                                                    fit: BoxFit.fill,
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                        ).toList()
                                                    ) :
                                                    Container()
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.02),
                                            child:Padding(
                                                padding: EdgeInsets.symmetric(vertical: marginLR*0.008,horizontal:marginLR*0.08 ),
                                                child: RaisedButton(
                                                  onPressed: isRegisterButtonEnabled(state)
                                                      ? _onFormSubmitted
                                                      : null,
                                                  padding: EdgeInsets.all(12),

                                                  color: Color.fromRGBO(0, 21, 64, 1),
                                                  child: Center(child: Text('Submit', style: TextStyle(color: Colors.white)),),
                                                )
                                            )
                                          ),

                                        ]
                                    )
                                ),
                              ),



                        )

                    ),
                ]
                  )
              )
              ]
              )
                  )

              );
            }
        )




    );
  }



  void _onCategoryChanged(){
    _productBloc.add(
      CategoryChanged(category: _categoryController.text),
    );
  }

  void _onPriceChanged() {
    _productBloc.add(
      PriceChanged(price: double.parse(_priceController.text)??0),
    );
  }

  void _onNameChanged() {
    _productBloc.add(
      NameChanged(name: _nameController.text),
    );
  }

  void _onFormSubmitted() {
    _productBloc.add(
      Submitted(
        name: _nameController.text,
        price: double.tryParse(_priceController.text),
        category: _categoryController.text,
        description: _descriptionController.text,
        stock: _stockController.text,
        unit: _unitController.text,
        user: widget.session,


      ),
    );
  }


  void _showCamera() async {

    final cameras = await availableCameras();

    final camera = cameras.first;

    dynamic camresult = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TakePicturePage(camera: camera, fabColor: PRIMARYCOLOR,)));
    File pImage = File(camresult);
    _productBloc.add(ImageFromCamera(image: pImage));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

}