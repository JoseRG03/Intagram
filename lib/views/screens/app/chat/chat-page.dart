import 'package:flutter/material.dart';

import '../../../../controllers/chat-controller.dart';
import 'chat-detail-page.dart';

class ChatPage extends StatefulWidget {

  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Future<List<Map<String, dynamic>>> _usersFuture;
  final ChatController chatController = ChatController();

  @override
  void initState() {
    super.initState();
    _usersFuture = chatController.getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user['image'] ?? ''),
                  child: user['image'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(user['name'] ?? 'Unknown User'),
                subtitle: Text(user['email'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        chatController: chatController,
                        recipientId: user['id'],
                        recipientName: user['name'] ?? 'Unknown User',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
