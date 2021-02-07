import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<User> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
   currentUser();
  Future<void> signOut();
  Future<void> forgotPassword(String email);
}

class Auth implements BaseAuth {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Future<String> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      User user = (await auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      return user.uid;
    } catch (e) {
      print(e);
    }
  }

  @override
   currentUser() async {
    try {
      User user = await auth.currentUser;
      return user.uid;
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> signOut() {
    return auth.signOut();
  }

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      User user = (await auth.signInWithEmailAndPassword(
              email: email, password: password))
          .user;
      assert(user != null);
      assert(await user.getIdToken() != null);
      final User currntUser = await auth.currentUser;
      return currntUser;
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }
}
