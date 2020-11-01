import 'dart:async';

import 'package:bus_tracker/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final String uid;
  final double myla;
  final double mylo;
  final double la;
  final double lo;

  const MapView({Key key, this.uid, this.myla, this.mylo, this.la, this.lo})
      : super(key: key);

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  UserService _userService = new UserService();
  GoogleMapController _controller;

  List<Marker> allMarkers = [];
  List<LatLng> latlng = List();
  final Set<Polyline> _polyline = {};

  double myla;
  double mylo;

  Stream busdata;
  bool find = false;

  _getBus() {
    _userService.getBusById(widget.uid).then((value) {
      setState(() {
        busdata = value;
      });
    });
  }

  void addMarker() {
    latlng.add(LatLng(widget.la, widget.lo));
    allMarkers.add(Marker(
      markerId: MarkerId('busLoc'),
      draggable: true,
      onTap: () {
        print('Marker Tapped');
      },
      position: LatLng(widget.la, widget.lo),
    ));

    _polyline.add(Polyline(
      color: Colors.blue,
      visible: true,
      points: latlng,
      polylineId: PolylineId("distance"),
    ));
  }

  @override
  void initState() {
    print(widget.myla);
    _getBus();
    super.initState();
    allMarkers.add(Marker(
        markerId: MarkerId('myloc'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(widget.myla, widget.mylo)));

    latlng.add(LatLng(widget.myla, widget.mylo));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: find == false
          ? FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  find = !find;
                });
                addMarker();
              },
              label: Text("Find bus"))
          : null,
      body: _body(),
    );
  }

  Widget _body() {
    return Center(
      child: GoogleMap(
        polylines: _polyline,
        markers: Set.from(allMarkers),
        initialCameraPosition:
            CameraPosition(target: LatLng(widget.myla, widget.mylo), zoom: 14),
        mapType: MapType.normal,
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }
}
