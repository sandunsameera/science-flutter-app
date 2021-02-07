import 'package:bus_tracker/models/reservations.dart';
import 'package:bus_tracker/screens/bus_screens/reservations.dart';
import 'package:bus_tracker/screens/bus_screens/share_location_screen.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../profile_screen.dart';

class BusHomeScreen extends StatefulWidget {
  @override
  _BusHomeScreenState createState() => _BusHomeScreenState();
}

class _BusHomeScreenState extends State<BusHomeScreen> {
  int selectedPos = 0;
  double bottomNavBarHeight = 60;
  UserService userService = new UserService();
  QuerySnapshot user;
  Map<String, dynamic> userdata;
  double la;
  double lo;
  List<Marker> allMarkers = [];
  DateTime now = new DateTime.now();

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.person, "Profile", Colors.blue,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    new TabItem(Icons.map, "Map", Colors.orange,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    new TabItem(Icons.book_online, "Reservations", Colors.green,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  ]);

  getUserDetails() async {
    await userService
        .getUser(FirebaseAuth.instance.currentUser.uid)
        .then((value) {
      setState(() {
        user = value;
        userdata = user.docs[0].data();
      });
    }).whenComplete(() {
      readDataforTimeTable();
    });
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      la = position.latitude;
      lo = position.longitude;
    });
  }

  CircularBottomNavigationController _navigationController;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Reservation> reservations = [];

  Future readDataforTimeTable() async {
    await databaseReference
        .child('reservations')
        .once()
        .then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var value = snapshot.value;
      reservations.clear();
      for (var key in keys) {
        if (value[key]['route'] == userdata['route'] &&
            value[key]['date'] ==
                (now.year.toString() +
                        "/" +
                        now.month.toString() +
                        "/" +
                        now.day.toString())
                    .toString()) {
          Reservation reservation = new Reservation(
            value[key]['date'],
            value[key]['route'],
            value[key]['username'],
            value[key]['time'],
            value[key]['latitude'],
            value[key]['longitute'],
          );
          reservations.add(reservation);
          allMarkers.add(Marker(
              markerId: MarkerId('myloc'),
              draggable: false,
              onTap: () {
                print('Marker Tapped');
              },
              position: LatLng(reservation.latitude, reservation.longitude)));
        }
      }
      setState(() {
        print(reservations.length.toString() + "dsd");
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this._getCurrentLocation().whenComplete(() {
      getUserDetails();
    });
    _navigationController = new CircularBottomNavigationController(selectedPos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Padding(
            child: bodyContainer(),
            padding: EdgeInsets.only(bottom: bottomNavBarHeight),
          ),
          Align(alignment: Alignment.bottomCenter, child: bottomNav())
        ],
      ),
    );
  }

  Widget bodyContainer() {
    Widget slogan;
    switch (selectedPos) {
      case 0:
        slogan = ProfileScreen();
        break;
      case 1:
        slogan = ShareLocation();
        break;
      case 2:
        slogan = Reservations(userdata, la, lo, reservations, allMarkers);
        break;
    }

    return slogan;
  }

  Widget bottomNav() {
    return CircularBottomNavigation(
      tabItems,
      controller: _navigationController,
      barHeight: bottomNavBarHeight,
      barBackgroundColor: Colors.purple[900],
      animationDuration: Duration(milliseconds: 300),
      selectedCallback: (int selectedPos) {
        setState(() {
          this.selectedPos = selectedPos;
          print(_navigationController.value);
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _navigationController.dispose();
  }
}
