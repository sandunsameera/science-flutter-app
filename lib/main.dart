import 'package:bus_tracker/screens/auth/loginscreen.dart';
import 'package:bus_tracker/screens/bus_screens/home_screen.dart';
import 'package:bus_tracker/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _storage = FlutterSecureStorage();
  String token;
  String user;
  Widget slogan;

  void setkey() async {
    token = await _storage.read(key: 'token');
    user = await _storage.read(key: 'user');
  }

  @override
  void initState() {
    super.initState();
    setkey();

    if (token == null) {
      setState(() {
        slogan = LoginScreen();
      });
    } else if (user == "user") {
      setState(() {
        slogan = HomeScreen();
      });
    } else if (user == "bus") {
      setState(() {
        slogan = BusHomeScreen();
      });
    } else {
      setState(() {
        slogan = LoginScreen();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen());
  }
}
