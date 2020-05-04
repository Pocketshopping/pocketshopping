import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pocketshopping/src/user/package_user.dart';
import 'package:pocketshopping/src/validators.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';
import 'package:pocketshopping/src/admin/package_admin.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  StreamSubscription _countSubscription;

  @override
  ProductState get initialState => ProductState.empty();

  @override
  Stream<ProductState> mapEventToState(
    ProductEvent event,
  ) async* {
    if (event is PriceChanged) {
      yield* _mapPriceChangedToState(event.price);
    } else if (event is CategoryChanged) {
      yield* _mapCategoryChangedToState(event.category);
    } else if (event is ImageFromGallery) {
      yield* _mapImageFromGalleryToState();
    } else if (event is ImageFromCamera) {
      yield* _mapImageFromCameraToState(event.image);
    } else if (event is CaptureBarCode) {
      yield* _mapCaptureBarCodeToState();
    } else if (event is NameChanged) {
      yield* _mapNameChangedToState(event.name);
    } else if (event is ProductCount) {
      yield* _mapProductCountToState(event.mID);
    } else if (event is ProductCountUpdate) {
      yield* _mapProductCountUpdateToState(event.count);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.name, event.price, event.category,
          event.description, event.unit, event.stock, event.user);
    }
  }

  Stream<ProductState> _mapProductCountUpdateToState(int count) async* {
    yield state.update(count: count);
  }

  Stream<ProductState> _mapProductCountToState(String mID) async* {
    _countSubscription?.cancel();
    _countSubscription = ProductRepo().getCount(mID).listen(
          (count) => add(ProductCountUpdate(count: count)),
        );
  }

  Stream<ProductState> _mapImageFromCameraToState(File image) async* {
    File temp = await cropImage(image);
    List<File> CroppedImage = List();
    CroppedImage.addAll(state.croppedImage);
    CroppedImage.add(temp);

    yield state.update(croppedImage: CroppedImage);
  }

  Stream<ProductState> _mapCaptureBarCodeToState() async* {
    String barcode = "";
    try {
      barcode = await BarcodeScanner.scan();
    } catch (_) {}

    yield state.update(barCode: barcode);
  }

  Stream<ProductState> _mapImageFromGalleryToState() async* {
    File pImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    File temp = await cropImage(pImage);
    List<File> CroppedImage = List();
    CroppedImage.addAll(state.croppedImage);
    CroppedImage.add(temp);

    yield state.update(croppedImage: CroppedImage);
  }

  Stream<ProductState> _mapPriceChangedToState(double price) async* {
    yield state.update(
      isPriceValid: Validators.isValidPrice(price),
    );
  }

  Stream<ProductState> _mapCategoryChangedToState(String category) async* {
    yield state.update(
      isCategoryValid: Validators.isValidName(category),
    );
  }

  Stream<ProductState> _mapNameChangedToState(String name) async* {
    yield state.update(
      isNameValid: Validators.isValidName(name),
    );
  }

  Stream<ProductState> _mapFormSubmittedToState(
    String name,
    double price,
    String category,
    String desc,
    String unit,
    String stock,
    Session user,
  ) async* {
    List<String> images = List();

    try {
      if (state.croppedImage.length > 0) {
        yield ProductState.loading(
            isUploading: true,
            croppedImage: state.croppedImage,
            barCode: state.barCode);
        images = await uploadMultipleImages(state.croppedImage);
      }
      yield ProductState.loading(
          isUploading: false,
          croppedImage: state.croppedImage,
          barCode: state.barCode);
      await ProductRepo().save(
        mID: user.merchant.mID,
        pUploader: user.user.fname,
        pCategory: category,
        pPrice: price,
        pName: name,
        pDesc: desc,
        pGroup: user.merchant.bCategory,
        pPhoto: images,
        pQRCode: state.barCode,
        pStockCount: int.tryParse(stock),
        pUnit: unit,
      );
      yield ProductState.success();
    } catch (_) {
      yield ProductState.failure(
          isUploading: false,
          croppedImage: state.croppedImage,
          barCode: state.barCode);
    }
  }

  Future<File> cropImage(File image) async {
    File temp;
    temp = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio3x2,
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Editor',
          toolbarColor: PRIMARYCOLOR,
          toolbarWidgetColor: WHITECOLOR,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        iosUiSettings: IOSUiSettings(minimumAspectRatio: 1.0));
    return temp;
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

  @override
  Future<void> close() {
    _countSubscription?.cancel();
    return super.close();
  }
}
