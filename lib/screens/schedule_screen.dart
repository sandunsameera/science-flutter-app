import 'package:bus_tracker/models/time_table.dart';
import 'package:bus_tracker/widgets/text_form_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TextEditingController _route = new TextEditingController();
  TextEditingController _start = new TextEditingController();

  final databaseReference = FirebaseDatabase.instance.reference();
  List<Timetable> timetableList = [];
  List<String> destinations = [];
  bool isRouteSearch = false;
  bool isAllSearched = false;

  void readDataforRoute() {
    databaseReference.child('route').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var value = snapshot.value;
      destinations.clear();

      for (var key in keys) {
        print(value[key]['destination1Ob']['stationName']);
        print(value[key]['destination2Ob']['stationName']);

        if (value[key]['routeNumber'] == _route.text) {
          setState(() {
            destinations.add(value[key]['destination1Ob']['stationName']);
            destinations.add(value[key]['destination2Ob']['stationName']);
          });
          print(destinations.length);
        }
      }
    });
  }

  void readDataforTimeTable() {
    databaseReference.child('timeTable').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var value = snapshot.value;
      timetableList.clear();
      print(_dropDownValue);
      for (var key in keys) {
        print(value[key]['route']['destination1']);
        if (value[key]['route']['routeNumber'] == _route.text &&
            value[key]['startingStation'] == _dropDownValue) {
          print(value[key]['route']['destination1Ob']['stationName']);
          print(value[key]['route']['destination2Ob']['stationName']);
          Timetable timetable = new Timetable(value[key]['departureTime'],
              value[key]['routeNumber'], value[key]['departureTime']);
          timetableList.add(timetable);
        }
      }

      setState(() {
        print(_start.text);
        print(timetableList.length);
      });
    });
  }

  String _dropDownValue;

  @override
  void initState() {
    super.initState();
    readDataforRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 40),
          _searchBar(),
          SizedBox(height: 40),
          _tableList()
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            child: LabelTextField(
              isreadonly: isRouteSearch,
              textEditingController: _route,
              hintText: "Bus route",
              keyboardType: TextInputType.number,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: DropdownButton(
              hint: _dropDownValue == null
                  ? Text('Start station')
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
                    isRouteSearch ? readDataforTimeTable() : null;
                  },
                );
              },
            ),
          ),
          Container(
            child: !isRouteSearch
                ? _searchButtonForRoute()
                : _searchButtonForTime(),
          ),
        ],
      ),
    );
  }

  Widget _searchButtonForRoute() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () {
          setState(() {
            isRouteSearch = true;
          });
          readDataforRoute();
        },
        child: Text(
          "Search",
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.purple[900],
      ),
    );
  }

  void reset() {
    setState(() {
      isRouteSearch = false;
      isAllSearched = false;
      _dropDownValue = null;
      timetableList.clear();
    });
  }

  Widget _searchButtonForTime() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () {
          setState(() {
            isAllSearched = true;
          });
          !isAllSearched ? readDataforTimeTable() : reset();
        },
        child: Text(
          isAllSearched ? "Search" : "Clear",
          style: TextStyle(color: Colors.white),
        ),
        color: Colors.purple[900],
      ),
    );
  }

  Widget _tableList() {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: timetableList.length,
        itemBuilder: (context, int index) {
          return Column(
            children: [
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Card(
                  child: Container(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Text("Start Station:"),
                          trailing: Text(
                            _dropDownValue,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(height: 16),
                        ListTile(
                          leading: Text("Depature time:"),
                          trailing: Text(timetableList[index].depatureTime +
                              " (In 24 hours time)",style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }
}
