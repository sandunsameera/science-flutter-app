import 'package:bus_tracker/models/reservations.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Reservations extends StatefulWidget {
  Map<String, dynamic> data;
  double la;
  double lo;
  List<Reservation> reservations;
  List<Marker> allMarkers;
  Reservations(this.data, this.la, this.lo, this.reservations, this.allMarkers);
  @override
  _ReservationsState createState() => _ReservationsState();
}

class _ReservationsState extends State<Reservations> {
  final databaseReference = FirebaseDatabase.instance.reference();
  final UserService userService = new UserService();
  GoogleMapController _controller;
  QuerySnapshot user;
  Map<String, dynamic> userdata;
  List<Reservation> reservations = [];
  List<Marker> allMarkers = [];
  List<LatLng> latlng = List();
  void onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
    });
  }

  // void readDataforTimeTable() {
  //   databaseReference
  //       .child('reservations')
  //       .once()
  //       .then((DataSnapshot snapshot) {
  //     var keys = snapshot.value.keys;
  //     var value = snapshot.value;
  //     reservations.clear();
  //     for (var key in keys) {
  //       if (value[key]['route'] == widget.data['route']) {
  //         Reservation reservation = new Reservation(
  //           value[key]['date'],
  //           value[key]['route'],
  //           value[key]['username'],
  //           value[key]['time'],
  //           value[key]['latitude'],
  //           value[key]['longitude'],
  //         );
  //         print(reservation.longitude);
  //         reservations.add(reservation);
  //       }
  //     }

  //     setState(() {
  //       print(reservations.length);
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    print(widget.allMarkers.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reservations"),
      ),
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        _reservationList(),
        SizedBox(height: 16),
        Divider(thickness: 2),
        SizedBox(height: 16),
        _googleMap(),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _reservationList() {
    return widget.reservations != null
        ? Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: widget.reservations.length,
              itemBuilder: (context, int index) {
                return Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Card(
                    child: Container(
                      child: Column(
                        children: [
                          ListTile(
                            leading: Text("Username :"),
                            trailing: Text(
                                widget.reservations[index].username != null
                                    ? widget.reservations[index].username
                                    : "loading",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            leading: Text("Date :"),
                            trailing: Text(
                                widget.reservations[index].date != null
                                    ? widget.reservations[index].date
                                    : "loading",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            leading: Text("Time :"),
                            trailing: Text(
                                widget.reservations[index].time != null
                                    ? widget.reservations[index].time
                                    : "loading",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _googleMap() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.3,
      child: GoogleMap(
        markers: Set.from(widget.allMarkers),
        initialCameraPosition:
            CameraPosition(target: LatLng(widget.la, widget.lo), zoom: 14),
        mapType: MapType.normal,
      ),
    );
  }
}
