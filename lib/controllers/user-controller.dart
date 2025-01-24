import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserController {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> getUserData() async {

    User? user = _auth.currentUser;

    final querySnapshot = await _firebaseFirestore.collection('users').doc(user?.uid ?? '').get();

    if (querySnapshot.exists) {
      return querySnapshot.data();
    } else {
      return null;
    }
  }

  Future<void> saveUserData({
    String? name,
    String? lastname,
    String? biography,
    String? phone,
    File? imageFile,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Prepare the update map
      Map<String, dynamic> updates = {};

      // Add fields to the update map only if they are not null
      if (name != null && name.isNotEmpty) updates['name'] = name;
      if (lastname != null && lastname.isNotEmpty) updates['lastname'] = lastname;
      if (biography != null && biography.isNotEmpty) updates['biography'] = biography;
      if (phone != null && phone.isNotEmpty) updates['phone'] = phone;

      // Upload image if provided and add its URL to updates
      if (imageFile != null) {
        final ref = _firebaseStorage.ref().child('user_images').child('${user.uid}.jpg');
        await ref.putFile(imageFile);
        final imageUrl = await ref.getDownloadURL();
        updates['image'] = imageUrl;
      }

      // Update Firestore document only with changed fields
      if (updates.isNotEmpty) {
        await _firebaseFirestore.collection('users').doc(user.uid).update(updates);
      }
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }
}