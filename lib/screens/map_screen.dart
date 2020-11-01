import 'package:bus_tracker/screens/map_view.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:bus_tracker/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  TextEditingController _route = new TextEditingController();
  UserService _userService = new UserService();
  Stream busses;
  double la;
  double lo;
  bool isactive = true;

  QuerySnapshot user;
  String url;
  Map<String, dynamic> userdata;

  getUserDetails(uid) async {
    _userService.getUser(uid).then((value) {
      setState(() {
        user = value;
        userdata = user.docs[0].data();
      });
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

  @override
  void initState() {
    super.initState();
    _userService.getByActive(true).then((value) {
      setState(() {
        busses = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 52),
          _searchBar(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    return StreamBuilder<QuerySnapshot>(
      stream: busses,
      builder: (context, snapshots) {
        return snapshots.data != null
            ? ListView.builder(
                itemCount: snapshots.data.docs.length,
                itemBuilder: (context, int index) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(left: 16, right: 16, top: 32),
                      child: GestureDetector(
                        onTap: () {
                          _getCurrentLocation().whenComplete(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapView(
                                          myla: la,
                                          mylo: lo,
                                          la: snapshots.data.docs[index]['lat'],
                                          lo: snapshots.data.docs[index]
                                              ['long'],
                                          uid: snapshots.data.docs[index]
                                              ['uid'],
                                        )));
                          });
                        },
                        child: Card(
                            elevation: 10,
                            child: Padding(
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Column(
                                  children: <Widget>[
                                    SizedBox(height: 16),
                                    Row(
                                      children: <Widget>[
                                        SizedBox(height: 32),
                                        Text(
                                          snapshots.data.docs[index]['name'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.purple[900]),
                                        ),
                                        Spacer(),
                                        snapshots.data.docs[index]['status']
                                            ? CircleAvatar(
                                                minRadius: 10,
                                                backgroundColor: Colors.green,
                                              )
                                            : CircleAvatar(
                                                minRadius: 10,
                                                backgroundColor: Colors.grey,
                                              ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      children: <Widget>[
                                        Text("Bus route :"),
                                        Spacer(),
                                        Text(snapshots.data.docs[index]
                                            ['route']),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Divider(),
                                    Row(
                                      children: <Widget>[
                                        Text("Bus Number :"),
                                        Spacer(),
                                        Text(snapshots.data.docs[index]
                                            ['number']),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ))),
                      ));
                })
            : Center(
                child: Text("Still loading"),
              );
      },
    );
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Row(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: LabelTextField(
              textEditingController: _route,
              hintText: "Bus route",
              keyboardType: TextInputType.number,
            ),
          ),
          Spacer(),
          Container(
            child: RaisedButton(
              onPressed: () {
                _route.text != ""
                    ? _userService.getByRoute(_route.text).then((value) {
                        setState(() {
                          busses = value;
                        });
                      })
                    : null;
              },
              child: Text(
                "Search",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.purple[900],
            ),
          ),
        ],
      ),
    );
  }
}
