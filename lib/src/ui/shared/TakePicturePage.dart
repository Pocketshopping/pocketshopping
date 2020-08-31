import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class TakePicturePage extends StatefulWidget {
  final CameraDescription camera;
  final Color fabColor;

  TakePicturePage({@required this.camera, this.fabColor});

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  CameraController _cameraController;
  Future<void> _initializeCameraControllerFuture;
  bool isFirst;


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;

      final path =
          (await getTemporaryDirectory()).path + '${DateTime.now()}.png';

      await _cameraController.takePicture(path);

      Navigator.pop(context, path);
    } catch (e) {
      //print(e);
    }
  }



  @override
  void initState() {
    isFirst = true;
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeCameraControllerFuture = _cameraController.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FutureBuilder(
          future: _initializeCameraControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _cameraController.value.aspectRatio,
                child: CameraPreview(_cameraController),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: Get.height * 0.04),
              child: FloatingActionButton(
                heroTag: "capture",
                onPressed: () {
                  _takePicture(context);
                },
                backgroundColor:
                    widget.fabColor != null ? widget.fabColor : Colors.black54,
                tooltip: 'capture',
                child: Icon(
                  Icons.camera,
                  size: Get.height * 0.05,
                ),
              ),
            )),
        Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only( bottom: Get.height * 0.04,left: Get.height * 0.04),
              child: FloatingActionButton(
                heroTag: "rotate",
                onPressed: () async{
                  final cameras = await availableCameras();
                  //print(cameras);
                  if(cameras.length > 1){
                    if(isFirst){

                      final camera = cameras.last;
                      _cameraController = CameraController(
                        camera,
                        ResolutionPreset.high,
                        enableAudio: false,
                      );
                      _initializeCameraControllerFuture = _cameraController.initialize();
                      isFirst = false;
                    }
                    else{
                      final camera = cameras.first;
                      _cameraController = CameraController(
                        camera,
                        ResolutionPreset.high,
                        enableAudio: false,
                      );
                      _initializeCameraControllerFuture = _cameraController.initialize();
                      isFirst=true;
                    }

                    setState(() {});
                  }
                },
                backgroundColor: Colors.black54.withOpacity(0.4),
                tooltip: 'change',
                child: Icon(
                  Icons.camera_front,
                  size: Get.height * 0.05,
                ),
              ),
            )),
      ],
    );
  }
}
