import 'package:bus_tracker/screens/map_screen.dart';
import 'package:bus_tracker/screens/profile_screen.dart';
import 'package:bus_tracker/screens/time_table.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedPos = 0;

  double bottomNavBarHeight = 60;

  List<TabItem> tabItems = List.of([
    new TabItem(Icons.person, "Profile", Colors.blue,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    new TabItem(Icons.map, "Map", Colors.orange,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
    new TabItem(Icons.map, "Time Table", Colors.green,
        labelStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
  ]);

  CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
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
        slogan = MapScreen();
        break;

      case 2:
        slogan = TimeTable();
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
