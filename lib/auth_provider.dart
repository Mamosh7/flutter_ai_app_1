import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _user;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listener for authentication changes such as user sign in and sign out
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Method to handle user sign in using email and password
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    }
    // Notify listeners in case of an error
    notifyListeners();
  }

  // Method to handle user registration using email and password
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
    }
    // Notify listeners in case of an error
    notifyListeners();
  }

  // Method to handle user sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Ensure to clean up the user and error message on sign out
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear the error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
