import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intec_social_app/controllers/user-controller.dart';

class PostsController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image to Firebase Storage and returns the URL.
  Future<String?> uploadImage(File imageFile) async {
    try {
      // Get current user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Create a unique file name for the image
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Reference to the location in Firebase Storage
      final ref = _storage.ref().child('feed_images/$userId/$fileName');

      // Upload the file
      await ref.putFile(imageFile);

      // Get the download URL
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  /// Saves the post data to the Firestore `feed` collection.
  Future<void> savePost(String imageUrl) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await _firestore.collection('feed').add({
        'userId': userId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving post: $e");
      rethrow;
    }
  }

  /// Fetch all posts from the `feed` collection
  Stream<List<Map<String, dynamic>>> getPosts() {
    return _firestore.collection('feed').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for likes/comments
        return data;
      }).toList();
    });
  }

  /// Get user details by userId
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists ? userDoc.data() : null;
  }

  /// Like a post
  Future<void> likePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final postRef = _firestore.collection('feed').doc(postId);

    // Atomically add userId to the `likes` array
    await postRef.update({
      'likes': FieldValue.arrayUnion([userId]),
    });
  }

  /// Unlike a post
  Future<void> unlikePost(String postId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final postRef = _firestore.collection('feed').doc(postId);

    // Atomically remove userId from the `likes` array
    await postRef.update({
      'likes': FieldValue.arrayRemove([userId]),
    });
  }

  /// Add a comment to a post
  Future<void> addComment(String postId, String comment) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception("User not logged in");

    final commentsRef = _firestore.collection('feed').doc(postId).collection('comments');

    await commentsRef.add({
      'userId': userId,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Get comments for a specific post
  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    final commentsRef = _firestore.collection('feed').doc(postId).collection('comments').orderBy('timestamp', descending: true);

    return commentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    });
  }


  /// Saves the story data to the Firestore `stories` collection.
  Future<void> saveStory(String imageUrl) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User ID not found");

      await _firestore.collection('stories').add({
        'userId': userId,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving story: $e");
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStories() async {
    try {
      final querySnapshot = await _firestore
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID for reference
        return data;
      }).toList();
    } catch (e) {
      print("Error fetching stories: $e");
      rethrow;
    }
  }
}
