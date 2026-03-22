import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register + Save Username in Firestore
  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = userCredential.user!.uid;

    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "username": username,
      "email": email,
      "createdAt": DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Get Username from Firestore
  Future<String?> getUsername() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection("users").doc(user.uid).get();
    return doc.data()?["username"];
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
