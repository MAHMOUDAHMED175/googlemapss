import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googlemapss/models/place_model.dart';
import 'package:googlemapss/utils/location_servics.dart';
import 'package:location/location.dart';

class CustomCamera extends StatefulWidget {
  const CustomCamera({super.key});

  @override
  State<CustomCamera> createState() => _CustomCameraState();
}

class _CustomCameraState extends State<CustomCamera> {
  late CameraPosition cameraPosition;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polyLine = {};
  Set<Polygon> polygone = {};
  Set<Circle> circles = {};
  late LocationServices locationServices;

  @override
  void initState() {
    cameraPosition = const CameraPosition(
      target: LatLng(29.303055680049336, 31.249581210889513),
      zoom: 14.4746,
    );
    initPolyLines();
    initMarkers();
    initPolygone();
    initCircles();
    updateLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.hybrid,
          // polygons: polygone,
          // circles: circles,
          zoomControlsEnabled: false,
          // polylines: polyLine,
          markers: markers,
          onMapCreated: (controller) {
            mapController = controller;
            initMapStyle();
          },
          initialCameraPosition: cameraPosition,
          // cameraTargetBounds: CameraTargetBounds(LatLngBounds(southwest: const LatLng(48.15562583664057, 11.495521226826666), northeast: const LatLng(48.16083111260223, 11.508562923688702))),
        ),
        Positioned(
          right: 20,
          left: 20,
          bottom: 20,
          child: ElevatedButton(
              onPressed: () {
                mapController!.animateCamera(CameraUpdate.newLatLng(
                  const LatLng(29.296455085587237, 31.22029389014172),
                ));
              },
              child: const Text("change to new location")),
        ),
      ],
    );
  }

  void initMapStyle() async {
    var mapStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_styles/night_map_style.json');

    // ignore: deprecated_member_use
    mapController!.setMapStyle(mapStyle);
  }

  void initMarkers() async {
    // ignore: deprecated_member_use
    var iconMarker = BitmapDescriptor.fromBytes(
        await getImageFromRawData('assets/images/icons8-marker-50.png', 100));
    var myMarkers = places.map((e) {
      return Marker(
          icon: iconMarker,
          markerId: MarkerId(e.id.toString()),
          position: e.latLng);
    });
    markers.addAll(myMarkers);
    setState(() {});
  }

  initPolyLines() {
    var polyline1 = const Polyline(
      color: Colors.yellow,
      startCap: Cap.roundCap,
      geodesic: true,
      width: 5,
      points: [
        LatLng(29.37545040072106, 31.06781061694132),
        LatLng(29.140121760987412, 31.184454818485882),
      ],
      polylineId: PolylineId("2"),
    );
    var polyline2 = const Polyline(
      color: Colors.redAccent,
      startCap: Cap.roundCap,
      jointType: JointType.bevel,
      endCap: Cap.roundCap,
      patterns: [PatternItem.dot],
      geodesic: true,
      width: 5,
      points: [
        LatLng(31.23421656831209, 29.950389241391225),
        LatLng(29.303055680049336, 31.249581210889513),
      ],
      polylineId: PolylineId("1"),
    );
    polyLine.add(polyline1);
    polyLine.add(polyline2);
  }

  Future<Uint8List> getImageFromRawData(String image, double width) async {
    var bytes = await rootBundle.load(image);
    var imageCodec = await ui.instantiateImageCodec(
      bytes.buffer.asUint8List(),
      targetWidth: width.toInt(),
    );
    var imageFrameInfo = await imageCodec.getNextFrame();
    var imageBytes =
        await imageFrameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return imageBytes!.buffer.asUint8List();
  }

  void initPolygone() {
    var polygone1 = Polygon(
        polygonId: const PolygonId('1'),
        fillColor: Colors.blue.withOpacity(0.2),
        strokeWidth: 2,
        strokeColor: Colors.redAccent,
        points: const [
          LatLng(31.23421656831209, 29.950389241391225),
          LatLng(29.303055680049336, 31.249581210889513),
          LatLng(29.296455085587237, 31.22029389014172),
          LatLng(31.23421656831209, 29.950389241391225),
        ]);
    polygone.add(polygone1);
  }

  void initCircles() async {
    var circle1 = Circle(
      fillColor: Colors.deepOrange.withOpacity(0.4),
      strokeWidth: 2,
      strokeColor: Colors.deepOrange,
      center: const LatLng(29.303055680049336, 31.249581210889513),
      radius: 10000,
      circleId: const CircleId("1"),
    );

    circles.add(circle1);
  }

  bool isCameraPositionFirstRun = true;

  void updateLocation() async {
    await locationServices.checkAndRquestLocationServices();
    bool hasPermission =
        await locationServices.checkAndRquestPermissionServices();
    if (hasPermission) {
      locationServices.getLocatioin((locationData) {
        var myMarker = Marker(
            markerId: const MarkerId("e.id.toString()"),
            position: LatLng(locationData.latitude!, locationData.longitude!));
        markers.add(myMarker);
        setState(() {});

        if (isCameraPositionFirstRun) {
         var cameraPosition = CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 17,
        );

        mapController
            ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

          isCameraPositionFirstRun= false;
        } else {
   mapController
            ?.animateCamera(CameraUpdate.newLatLng( LatLng(locationData.latitude!, locationData.longitude!)));

          
        }
       
      });
    }
  }
}
