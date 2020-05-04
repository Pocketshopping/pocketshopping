import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: true,
    );

    _initializeCameraControllerFuture = _cameraController.initialize();
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
                  bottom: MediaQuery.of(context).size.height * 0.04),
              child: FloatingActionButton(
                onPressed: () {
                  _takePicture(context);
                },
                backgroundColor:
                    widget.fabColor != null ? widget.fabColor : Colors.black54,
                tooltip: 'Increment',
                child: Icon(
                  Icons.camera_alt,
                  size: MediaQuery.of(context).size.height * 0.05,
                ),
              ),
            )),
      ],
    );
  }
}
