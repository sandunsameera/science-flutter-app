import 'package:bus_tracker/screens/auth/register_screen.dart';
import 'package:bus_tracker/screens/bus_screens/home_screen.dart';
import 'package:bus_tracker/screens/home_screen.dart';
import 'package:bus_tracker/services/auth_service.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:bus_tracker/widgets/text_form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();

  Auth _auth = new Auth();
  UserService _userService = new UserService();
  QuerySnapshot user;

  Future<void> login() async {
    try {
      (await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _email.text, password: _password.text))
          .user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        _appname(),
        Spacer(),
        _loginform(),
        Spacer(),
        _loginButton(),
        _registerLabel(),
      ],
    );
  }

  Widget _loginButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
        child: RaisedButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.purple[900],
          onPressed: () {
            if (_formKey.currentState.validate()) {
              login().then((value) {
                _userService
                    .getUser(FirebaseAuth.instance.currentUser.uid)
                    .then((value) {
                  user = value;
                  if (user.docs[0].data()['type'] == "user") {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusHomeScreen()));
                  }
                });
              });
            }
          },
          child: Text(
            "Log In",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _registerLabel() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 32, right: 32, bottom: 32),
        child: Row(
          children: <Widget>[
            Text("Dont have account?"),
            Spacer(),
            RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              color: Colors.teal[600],
              child: Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _loginform() {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(left: 32, right: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              LabelTextField(
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
                textEditingController: _email,
                hintText: "Email",
              ),
              SizedBox(height: 32),
              LabelTextField(
                isObscure: true,
                validator: (v) {
                  if (v.isEmpty) {
                    return 'Password is required or length invalid';
                  } else if (_password.text.length < 6) {
                    return 'password is too short !! use minimum 6 characters';
                  }
                  return null;
                },
                textEditingController: _password,
                hintText: "Password",
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appname() {
    return Text(
      "Bus Tracker",
      style: TextStyle(fontSize: 35, color: Colors.purple[900]),
    );
  }
}
