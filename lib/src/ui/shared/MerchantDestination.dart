import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:pocketshopping/src/ui/package_ui.dart';


const double CAMERA_ZOOM = 9;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 30;
const LatLng SOURCE_LOCATION = LatLng(9.0866644, 7.4592741);
const LatLng DEST_LOCATION = LatLng(9.0866644, 7.4472742);


class MerchantDestination extends StatefulWidget {

  @override
  State<MerchantDestination> createState() => _MerchantDestinationState();
}



class _MerchantDestinationState extends State<MerchantDestination> {
  int _polylineCount = 1;
  Map<PolylineId, Polyline> _polylines = <PolylineId, Polyline>{};
  GoogleMapController _controller;
  Set<Marker> _markers = {};
  BitmapDescriptor pinLocationIcon;

  @override
  void initState() {
    pinLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  GoogleMapPolyline _googleMapPolyline =
  new GoogleMapPolyline(apiKey: "AIzaSyDWhKPubZYbSnuCUcOHyYptuQsXQYRDdSc");

  //Polyline patterns
  List<List<PatternItem>> patterns = <List<PatternItem>>[
    <PatternItem>[], //line
    <PatternItem>[PatternItem.dash(30.0), PatternItem.gap(20.0)], //dash
    <PatternItem>[PatternItem.dot, PatternItem.gap(10.0)], //dot
    <PatternItem>[
      //dash-dot
      PatternItem.dash(30.0),
      PatternItem.gap(20.0),
      PatternItem.dot,
      PatternItem.gap(20.0)
    ],
  ];

  LatLng _mapInitLocation = LatLng(9.0866644, 7.4592741);

  LatLng _originLocation = LatLng(9.0866644, 7.4592741);
  LatLng _destinationLocation = LatLng(9.0866644, 7.4472742);

  bool _loading = false;

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _markers.add(
          Marker(
              markerId: MarkerId('<MARKER_ID>'),
              position: _mapInitLocation,
              icon: pinLocationIcon
          ));
    });
  }

  //Get polyline with Location (latitude and longitude)
  _getPolylinesWithLocation() async {
    //_setLoadingMenu(true);
    List<LatLng> _coordinates =
    await _googleMapPolyline.getCoordinatesWithLocation(
        origin: _originLocation,
        destination: _destinationLocation,
        mode: RouteMode.driving);

    setState(() {
      _polylines.clear();
    });
    _addPolyline(_coordinates);
    //_setLoadingMenu(false);
  }

  //Get polyline with Address
  _getPolylinesWithAddress() async {
    _setLoadingMenu(true);
    List<LatLng> _coordinates =
    await _googleMapPolyline.getPolylineCoordinatesWithAddress(
        origin: '55 Kingston Ave, Brooklyn, NY 11213, USA',
        destination: '8007 Cypress Ave, Glendale, NY 11385, USA',
        mode: RouteMode.driving);

    setState(() {
      _polylines.clear();
    });
    _addPolyline(_coordinates);
    _setLoadingMenu(false);
  }

  _addPolyline(List<LatLng> _coordinates) {
    PolylineId id = PolylineId("poly$_polylineCount");
    Polyline polyline = Polyline(
        polylineId: id,
        patterns: patterns[0],
        color: Colors.blueAccent,
        points: _coordinates,
        width: 5,
        onTap: () {});

    setState(() {
      _polylines[id] = polyline;
      _polylineCount++;
    });
  }

  _setLoadingMenu(bool _status) {
    setState(() {
      _loading = _status;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getPolylinesWithLocation();
    return MaterialApp(
     // darkTheme: ThemeData(brightness: Brightness.dark),
      home: Scaffold(
        body:  GoogleMap(
                      markers: _markers,
                      onMapCreated: _onMapCreated,
                      polylines: Set<Polyline>.of(_polylines.values),
                      initialCameraPosition: CameraPosition(
                        target: _mapInitLocation,
                        zoom: 15,
                      ),
                    ),
                       floatingActionButton: FloatingActionButton.extended(
                       backgroundColor: PRIMARYCOLOR,
                       onPressed: (){Navigator.pop(context);},
                        label: Text('Back'),
                        icon: Icon(Icons.arrow_back),
        ),
                  ),

      debugShowCheckedModeBanner: false,
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
