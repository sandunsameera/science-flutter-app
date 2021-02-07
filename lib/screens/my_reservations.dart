import 'package:bus_tracker/models/reservations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MyReservations extends StatefulWidget {
  @override
  _MyReservationsState createState() => _MyReservationsState();
}

class _MyReservationsState extends State<MyReservations> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<Reservation> reservations = [];
  String uid;

  getCurrentUser() async {
    final user = await _auth.currentUser;
    setState(() {
      uid = user.uid;
    });

    readDataforReservations();
  }

  void readDataforReservations() {
    databaseReference
        .child('reservations')
        .once()
        .then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var value = snapshot.value;
      reservations.clear();

      for (var key in keys) {
        if (value[key]['id'] == uid) {
          setState(() {
            Reservation reservation = new Reservation(
                value[key]['date'],
                value[key]['route'],
                value[key]['username'],
                value[key]['time'],
                value[key]['latitute'],
                value[key]['longitude']);
            reservations.add(reservation);
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return reservations.length != 0
        ? ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, int index) {
              return Container(
                padding: EdgeInsets.only(left: 32, right: 32, top: 16),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Text("Route :"),
                        trailing: Text(reservations[index].route),
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Text("Date :"),
                        trailing: Text(reservations[index].date),
                      ),
                      SizedBox(height: 16),
                      ListTile(
                        leading: Text("Time :"),
                        trailing: Text(reservations[index].time),
                      )
                    ],
                  ),
                ),
              );
            },
          )
        : Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
