import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all users except the current user
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final querySnapshot = await _firestore
        .collection('users')
        .where('id', isNotEqualTo: currentUser.uid)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Include document ID
      return data;
    }).toList();
  }

  /// Send a message to another user
  Future<void> sendMessage(String recipientId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final chatId = _getChatId(currentUser.uid, recipientId);

    // Add message to the chat
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': currentUser.uid,
      'recipientId': recipientId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Retrieve chat messages between the current user and another user
  Stream<List<Map<String, dynamic>>> getChatMessages(String recipientId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final chatId = _getChatId(currentUser.uid, recipientId);

    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    });
  }

  /// Generate a consistent chat ID for a conversation between two users
  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return sortedIds.join('_');
  }
}
