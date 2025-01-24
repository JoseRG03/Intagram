import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("User 1"),
            subtitle: Text("Last message..."),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("User 2"),
            subtitle: Text("Last message..."),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to a new message screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
