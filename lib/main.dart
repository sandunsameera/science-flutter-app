import 'package:bus_tracker/screens/auth/loginscreen.dart';
import 'package:bus_tracker/screens/bus_screens/home_screen.dart';
import 'package:bus_tracker/screens/home_screen.dart';
import 'package:bus_tracker/services/auth_service.dart';
import 'package:bus_tracker/services/login_service.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart' hide Action;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) =>
              context.read<AuthenticationService>().authStateChanges,
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  @override
  _AuthenticationWrapperState createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  UserService userService = new UserService();
  Auth auth = new Auth();
  var user;
  Map<String, dynamic> userdata;

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  getUserDetails() async {
    if (FirebaseAuth.instance.currentUser != null) {
      userService.getUser(FirebaseAuth.instance.currentUser.uid).then((value) {
        setState(() {
          user = value;
          userdata = user.docs[0].data();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if (firebaseUser != null) {
      if (userdata == null) {
        print(null);
      } else {
        if (userdata['type'] == "bus owner") {
          return BusHomeScreen();
        } else {
          return HomeScreen();
        }
      }
    }
    return LoginScreen();
  }
}
