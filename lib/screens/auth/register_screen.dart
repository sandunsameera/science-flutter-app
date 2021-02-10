import 'package:bus_tracker/screens/bus_screens/home_screen.dart';
import 'package:bus_tracker/screens/home_screen.dart';
import 'package:bus_tracker/services/auth_service.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:bus_tracker/widgets/text_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:bus_tracker/models/route.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _username = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _route = new TextEditingController();
  TextEditingController _number = new TextEditingController();
  TextEditingController _dest1 = new TextEditingController();
  TextEditingController _dest2 = new TextEditingController();

  bool type = true;

  Auth _auth = new Auth();
  UserService _userService = new UserService();

  final databaseReference = FirebaseDatabase.instance.reference();
  List<Routerr> route = [];
  String _dropDownValue;
  String dest1;
  String dest2;

  void readDataforReservations() {
    databaseReference.child('route').once().then((DataSnapshot snapshot) {
      var keys = snapshot.value.keys;
      var value = snapshot.value;
      route.clear();
      for (var key in keys) {
        print(value[key]['destination1Ob']);
        setState(() {
          Routerr routerr = new Routerr(
              value[key]['destination1Ob']['stationName'],
              value[key]['destination2Ob']['stationName'],
              value[key]['routeNumber']);

          route.add(routerr);
        });
      }
    });
  }

  saveUserData(Map<String, dynamic> data) async {
    _userService.saveUsers(data);
    print("fuck");
  }

  @override
  void initState() {
    super.initState();
    readDataforReservations();
  }

  register() async {
    _auth
        .createUserWithEmailAndPassword(_email.text, _password.text)
        .then((value) async {
      final User user = FirebaseAuth.instance.currentUser;
      String uid = user.uid;
      Map<String, dynamic> data = {
        'uid': uid,
        "name": _username.text,
        "email": _email.text,
        "phone": _phone.text,
        "image": '',
        "type": type == true ? "user" : "bus owner",
      };

      Map<String, dynamic> databus = {
        'uid': uid,
        "name": _username.text,
        "email": _email.text,
        "phone": _phone.text,
        "image": '',
        "type": type == true ? "user" : "bus owner",
        "route": _dropDownValue,
        'dest1': dest1,
        'dest2': dest2,
        "number": _number.text,
      };
      type ? saveUserData(data) : saveUserData(databus);
      type
          ? Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()))
          : Navigator.push(context,
              MaterialPageRoute(builder: (context) => BusHomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        centerTitle: true,
        title: Text("Bus tracker"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: <Widget>[
        _registerform(),
        SizedBox(height: 50),
        _register(),
      ],
    );
  }

  Widget _registerform() {
    return Container(
      padding: EdgeInsets.only(left: 32, right: 32),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            SizedBox(height: 80),
            LabelTextField(
              hintText: "Name",
              textEditingController: _username,
              validator: (v) {
                if (v.isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            LabelTextField(
              keyboardType: TextInputType.emailAddress,
              hintText: "Email",
              textEditingController: _email,
              validator: (v) {
                if (v.isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            LabelTextField(
              isObscure: true,
              hintText: "Password",
              textEditingController: _password,
              validator: (v) {
                if (v.isEmpty) {
                  return 'Password is required';
                }
                if (_password.text.length < 6) {
                  return 'Password is too short';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            LabelTextField(
              keyboardType: TextInputType.phone,
              hintText: "Phone Number",
              textEditingController: _phone,
              validator: (v) {
                if (v.isEmpty) {
                  return 'Phone Number is required';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
            type == false
                ? LabelTextField(
                    keyboardType: TextInputType.text,
                    hintText: "Number plate",
                    textEditingController: _number,
                    validator: (v) {
                      if (v.isEmpty) {
                        return 'Number plate is required';
                      }
                      return null;
                    },
                  )
                : SizedBox(),
            SizedBox(height: 32),
            type == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButton(
                      hint: _dropDownValue == null
                          ? Text('Route')
                          : Text(
                              _dropDownValue,
                              style: TextStyle(color: Colors.blue),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: route.map(
                        (val) {
                          return DropdownMenuItem<String>(
                            value: val.route,
                            child: Text(val.route),
                          );
                        },
                      ).toList(),
                      onChanged: (val) {
                        setState(
                          () {
                            _dropDownValue = val;
                            print(val);

                            for (var route1 in route) {
                              if (route1.route == val) {
                                setState(() {
                                  dest1 = route1.destination1;
                                  dest2 = route1.destination2;
                                });
                              }
                            }
                          },
                        );
                      },
                    ),
                  )
                : SizedBox(),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlutterSwitch(
                  activeText: "user",
                  inactiveText: "bus owner",
                  value: type,
                  valueFontSize: 10.0,
                  width: 110,
                  borderRadius: 30.0,
                  showOnOff: true,
                  onToggle: (val) {
                    setState(() {
                      type = val;
                    });
                  },
                ),
                Container(
                    alignment: Alignment.centerRight,
                    child: type == true
                        ? Text(
                            "Login as user",
                          )
                        : Text(
                            "Login as bus owner",
                          )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _register() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: EdgeInsets.only(left: 32, right: 32, bottom: 16),
        child: RaisedButton(
          color: Colors.purple[900],
          child: Text(
            "Register",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              try {
                register();
              } catch (e) {
                print(e);
              }
            }
          },
        ),
      ),
    );
  }
}
