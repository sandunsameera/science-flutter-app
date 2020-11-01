import 'dart:io';

import 'package:bus_tracker/services/auth_service.dart';
import 'package:bus_tracker/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Auth auth = new Auth();
  UserService userService = new UserService();

  QuerySnapshot user;
  Map<String, dynamic> userdata;
  String url;
  File _image;
  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadFile() async {
    Toast.show("Please wait until image uploads", context);
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().toString()}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete
        .whenComplete(
      () => storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          url = fileURL;
        });
      }),
    )
        .whenComplete(() {
      Map<String, dynamic> data = {'image': url};

      userService.updateUser(user.docs[0].id, data);
      print('File Uploaded');
    });
  }

  getUserDetails() async {
    userService.getUser(FirebaseAuth.instance.currentUser.uid).then((value) {
      setState(() {
        user = value;
        userdata = user.docs[0].data();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    this.getUserDetails();
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        _profilePicture(),
        SizedBox(height: 8),
        _mainDetails(),
        Spacer(),
        _otherDetaile(),
        Spacer(),
        Spacer(),
        Spacer(),
        _image != null ? _updateImage() : SizedBox(),
        SizedBox(height: 32),
      ],
    );
  }

  Widget _profilePicture() {
    return user != null &&
            (userdata['image'] != null || userdata['image'] == '')
        ? Row(
            children: <Widget>[
              Spacer(),
              GestureDetector(
                onTap: () {
                  getImage();
                },
                child: _image != null
                    ? CircleAvatar(
                        backgroundImage: FileImage(_image),
                        minRadius: 60,
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(userdata['image']),
                        minRadius: 60,
                      ),
              ),
              Spacer(),
            ],
          )
        : Row(
            children: <Widget>[
              Spacer(),
              CircleAvatar(
                minRadius: 60,
              ),
              Spacer(),
            ],
          );
  }

  Widget _mainDetails() {
    return Container(
        padding: EdgeInsets.only(left: 32, right: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            user != null && userdata['name'] != null
                ? Text(userdata['name'])
                : Text("Still loading"),
            user != null && userdata['email'] != null
                ? Text(userdata['email'])
                : Text("Still loading"),
          ],
        ));
  }

  Widget _otherDetaile() {
    return Container(
        padding: EdgeInsets.only(left: 32, right: 32),
        child: Card(
          elevation: 30,
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: <Widget>[
                      Text("Name :"),
                      Spacer(),
                      user != null && userdata['name'] != null
                          ? Text(userdata['name'])
                          : Text("Still loading"),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: <Widget>[
                      Text("Email :"),
                      Spacer(),
                      user != null && userdata['email'] != null
                          ? Text(userdata['email'])
                          : Text("Still loading"),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: <Widget>[
                      Text("Phone :"),
                      Spacer(),
                      user != null && userdata['phone'] != null
                          ? Text(userdata['phone'])
                          : Text("Still loading"),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    children: <Widget>[
                      Text("Type :"),
                      Spacer(),
                      user != null && userdata['type'] != null
                          ? Text(userdata['type'])
                          : Text("Still loading"),
                    ],
                  ),
                ),
                SizedBox(height: 32),
             userdata!=null&&  userdata['type'] != null &&  userdata['type'] == "bus owner"
                    ? Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Row(
                          children: <Widget>[
                            Text("Route :"),
                            Spacer(),
                            user != null && userdata['route'] != null
                                ? Text(userdata['route'])
                                : Text("Still loading"),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 32),
               userdata!=null&& userdata['type'] != null && userdata['type'] == "bus owner"
                    ? Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Row(
                          children: <Widget>[
                            Text("Number :"),
                            Spacer(),
                            user != null && userdata['number'] != null
                                ? Text(userdata['number'])
                                : Text("Still loading"),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ));
  }

  Widget _updateImage() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(left: 32, right: 32),
      child: RaisedButton(
        color: Colors.purple[900],
        onPressed: () {
          uploadFile().then((value) {
            Toast.show("Profile picture updated", context);
            setState(() {
              _image = null;
            });
          });
        },
        child: Text("Update profile picture",
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
