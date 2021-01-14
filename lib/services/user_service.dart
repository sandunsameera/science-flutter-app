import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {
  Future<void> saveUsers(Map<String, dynamic> data);
  Future<void> getUser(String uid);
  Future<void> saveUserLocation(id, data);
  Future getBuses();
  Future getBusById(id);
  Future getByRoute(route);
  Future getByActive(isactive);
  Future updateUser(id, data);
}

class UserService implements BaseAuth {
  final CollectionReference _usersref =
      FirebaseFirestore.instance.collection("users");

  @override
  Future<void> saveUsers(data) {
    try {
      FirebaseFirestore.instance.collection("users").add(data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future getUser(String uid) async {
    try {
      return await FirebaseFirestore.instance
          .collection("users")
          .where("uid", isEqualTo: uid)
          .get()
          .catchError((e) {
        print(e);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> saveUserLocation(id, data) {
    try {
      FirebaseFirestore.instance.collection("locations").doc(id).set(data);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future getBuses() async {
    try {
      return await FirebaseFirestore.instance
          .collection("locations")
          .snapshots();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future getBusById(id) async {
    try {
      return await FirebaseFirestore.instance
          .collection("locations")
          .where("uid", isEqualTo: id)
          .snapshots();
    } catch (e) {
      print(e);
    }
  }

  @override
  Future getByRoute(route) async {
    try {
      return await FirebaseFirestore.instance
          .collection("locations")
          .where("route", isEqualTo: route)
          .where("status", isEqualTo: true)
          .snapshots();
    } catch (e) {}
  }

  @override
  Future getByActive(isactive) async {
    try {
      return await FirebaseFirestore.instance
          .collection('locations')
          .where('status', isEqualTo: isactive)
          .snapshots();
    } catch (e) {}
  }

  @override
  Future updateUser(id, data) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update(data);
    } catch (e) {
      print(e);
    }
  }
}
