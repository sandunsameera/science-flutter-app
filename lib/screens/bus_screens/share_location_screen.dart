import 'dart:async';

import 'package:bus_tracker/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class ShareLocation extends StatefulWidget {
  @override
  _ShareLocationState createState() => _ShareLocationState();
}

class _ShareLocationState extends State<ShareLocation> {
  Timer timer;
  bool availability = false;
  UserService _userService = new UserService();
  var userLocation;
  Position position;
  double la;
  double lo;
  QuerySnapshot user;
  Map<String, dynamic> userdata;
  List<String> destinations = [];
  String _dropDownValue;

  void _saveUserLocation(double lat, double long) async {
    String uid = FirebaseAuth.instance.currentUser.uid;
    _userService.getUser(uid).then((value) {
      setState(() {
        user = value;
        userdata = user.docs[0].data();
        destinations.add(userdata['dest1']);
        destinations.add(userdata['dest2']);
      });
    });
    Map<String, dynamic> data = {
      "uid": uid,
      "status": availability,
      "lat": lat,
      "long": long,
      "route": userdata['route'],
      "name": userdata['name'],
      'number': userdata['number'],
      'active dest': _dropDownValue != null ? _dropDownValue.toLowerCase() : "",
    };
    _userService.saveUserLocation(uid, data);
  }

  void _updateLocation(double lat, double long) {
    String uid = FirebaseAuth.instance.currentUser.uid;
    Map<String, dynamic> data = {
      "uid": uid,
      "status": availability,
      "lat": lat,
      "long": long
    };

    // _userService.updateLocation(id, data);
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      la = position.latitude;
      lo = position.longitude;
    });
  }

  @override
  void initState() {
    destinations.clear();
    timer = Timer.periodic(Duration(seconds: 15), (Timer t) {
      print("triggerd");
      _getCurrentLocation().whenComplete(() {
        _saveUserLocation(la, lo);
      });
    });
    super.initState();
    _saveUserLocation(la, lo);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: <Widget>[
        SizedBox(height: 32),
        _avilabilityRow(),
        destinations.length > 0
            ? Container(
                padding: EdgeInsets.only(left: 32, right: 32),
                width: MediaQuery.of(context).size.width,
                child: DropdownButton(
                  hint: _dropDownValue == null
                      ? Text('End Destination')
                      : Text(
                          _dropDownValue,
                          style: TextStyle(color: Colors.blue),
                        ),
                  isExpanded: true,
                  iconSize: 30.0,
                  style: TextStyle(color: Colors.blue),
                  items: destinations.map(
                    (val) {
                      return DropdownMenuItem<String>(
                        value: val,
                        child: Text(val),
                      );
                    },
                  ).toList(),
                  onChanged: (val) {
                    setState(
                      () {
                        _dropDownValue = val;
                        // isRouteSearch ? readDataforTimeTable() : null;
                      },
                    );
                  },
                ),
              )
            : SizedBox(),
        Spacer(),
        _shareText(),
        Spacer(),
        _start(),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _avilabilityRow() {
    return Container(
        padding: EdgeInsets.only(left: 32, right: 32),
        child: Row(
          children: <Widget>[
            Text("Availability :"),
            Spacer(),
            Switch(
                value: availability,
                onChanged: (v) {
                  _getCurrentLocation();
                  setState(() {
                    availability = v;
                    _saveUserLocation(position.latitude, position.longitude);
                  });
                })
          ],
        ));
  }

  Widget _shareText() {
    return Container(
      child: availability == true
          ? Text(
              "Your location is shared",
              style: TextStyle(fontSize: 25, color: Colors.purple[900]),
            )
          : Text("Your location sharing is off",
              style: TextStyle(fontSize: 25, color: Colors.purple[900])),
    );
  }

  Widget _start() {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 32, right: 32),
        child: availability == true
            ? RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.purple[900],
                child: Text(
                  "Start journey",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _dropDownValue != null
                    ? () {
                        print("dsnj");
                        _getCurrentLocation().whenComplete(() {
                          _saveUserLocation(la, lo);
                        });
                      }
                    : null,
              )
            : RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: Colors.purple[900],
                child: Text(
                  "Turn off availability",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  _getCurrentLocation().whenComplete(() {
                    _saveUserLocation(la, lo);
                  });
                }));
  }
}
