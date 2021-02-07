import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class ReserveSeats extends StatefulWidget {
  String time;
  String busRoute;
  double la;
  double lo;
  ReserveSeats({Key key, this.busRoute, this.la, this.lo, this.time})
      : super(key: key);

  @override
  _ReserveSeatsState createState() => _ReserveSeatsState();
}

class _ReserveSeatsState extends State<ReserveSeats> {
  DateTime now = new DateTime.now();
  DateTime today = new DateTime.now();
  GoogleMapController _controller;
  final dbRef = FirebaseDatabase.instance.reference();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TimeOfDay initialTime;

  List<Marker> allMarkers = [];
  List<LatLng> latlng = List();
  final Set<Polyline> _polyline = {};
  String uid;
  String username;

  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  getCurrentUser() async {
    final user = await _auth.currentUser;
    setState(() {
      uid = user.uid;
      int idx = user.email.indexOf("@");
      username = user.email.substring(0, idx);
    });
    print('User ID:  ' + uid);
    // writeData();
  }

  // _timePicker() async {
  //   TimeOfDay pickedTime = await showTimePicker(
  //     context: context,
  //     initialTime: new TimeOfDay.now(),
  //     builder: (BuildContext context, Widget child) {
  //       return Directionality(
  //         textDirection: TextDirection.rtl,
  //         child: child,
  //       );
  //     },
  //   );
  //   setState(() {
  //     initialTime = pickedTime;
  //   });
  // }

  void writeData() {
    dbRef
        .child("reservations")
        .child(uid +
            now.year.toString() +
            now.month.toString() +
            now.day.toString() +
            widget.busRoute)
        .set({
      'id': uid,
      'date': now.year.toString() +
          "/" +
          now.month.toString() +
          "/" +
          now.day.toString(),
      'latitude': widget.la,
      'longitute': widget.lo,
      'route': widget.busRoute,
      'username': username,
      'time': widget.time,
    });
    print("done");
  }

  @override
  void initState() {
    super.initState();
    allMarkers.add(Marker(
        onDragEnd: ((newPosition) {
          setState(() {
            widget.la = newPosition.latitude;
            widget.lo = newPosition.longitude;
            print(widget.la + widget.lo);
          });
        }),
        markerId: MarkerId('myloc'),
        draggable: true,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(widget.la, widget.lo)));

    latlng.add(LatLng(widget.la, widget.lo));

    getCurrentUser();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Seat Reservation For " + widget.busRoute),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      child: ListView(
        children: [
          SizedBox(height: 32),
          Row(
            children: [
              SizedBox(width: 16),
              Text("Pick Date:"),
              Spacer(),
              _datePicker(),
            ],
          ),
          SizedBox(height: 32),
          _pickLocation(),
          SizedBox(height: 32),
          _reserveSeatButton(),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _datePicker() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: 100,
      child: CupertinoDatePicker(
        minimumDate: DateTime(today.year, today.month, today.day),
        maximumDate: DateTime(today.year, today.month, today.day + 6),
        mode: CupertinoDatePickerMode.date,
        initialDateTime: DateTime(today.year, today.month, today.day),
        onDateTimeChanged: (DateTime newDateTime) {
          setState(() {
            now = newDateTime;
          });
        },
      ),
    );
  }

  Widget _pickLocation() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: GoogleMap(
        polylines: _polyline,
        markers: Set.from(allMarkers),
        initialCameraPosition:
            CameraPosition(target: LatLng(widget.la, widget.lo), zoom: 14),
        mapType: MapType.normal,
      ),
    );
  }

  Widget _reserveSeatButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 32, right: 32),
      child: RaisedButton(
        color: Colors.teal,
        child: Text(
          "Reserve seat",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () {
          initialTime != null
              ? writeData()
              : Toast.show("Please choose a Time", context);
        },
      ),
    );
  }

  // Widget _pickTime() {
  //   return Container(
  //     width: MediaQuery.of(context).size.width,
  //     padding: EdgeInsets.only(left: 32, right: 32),
  //     child: RaisedButton(
  //       color: Colors.purple[900],
  //       onPressed: () {
  //         _timePicker();
  //       },
  //       child: Text(
  //         "Pick Time",
  //         style: TextStyle(color: Colors.white),
  //       ),
  //     ),
  //   );
  // }
}
