import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<int> registerUser(String name, String lastname, String phone,
      String email, String password) async {
    try {

      print("Credentials: $name, $lastname, $phone, $email, $password");

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      _firebaseFirestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name.trim(),
        'lastName': lastname.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password.trim()
      });

      Fluttertoast.showToast(msg: 'Account Created Successfully!');

      return 0;
    } catch (err) {
      Fluttertoast.showToast(msg: 'Error: $err');

      return 1;
    }
  }

  Future<UserCredential?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);


      Fluttertoast.showToast(msg: 'Welcome!');

      return userCredential;
    } catch (err) {
      Fluttertoast.showToast(msg: 'Error: $err');

      return null;
    }
  }
}
