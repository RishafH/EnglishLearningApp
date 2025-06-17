import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Register with email, password and username
  Future<User?> register(String email, String password, String username) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCred.user;

      if (user != null) {
        // Save additional user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // 🔐 Login
  Future<User?> login(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 🔐 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 🔍 Get current user
  User? get currentUser => _auth.currentUser;
}
