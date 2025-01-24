import 'package:flutter/material.dart';

import '../../../../controllers/chat-controller.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatController chatController;
  final String recipientId;
  final String recipientName;

  const ChatDetailPage({
    required this.chatController,
    required this.recipientId,
    required this.recipientName,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  String? currentId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getInitialData();
  }

  void getInitialData() async {
    String? userId = await widget.chatController.getCurrentUserId();

    setState(() {
      currentId = userId;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.recipientName}"),
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.chatController.getChatMessages(widget.recipientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No messages yet"));
                }

                final messages = snapshot.data!;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByCurrentUser = message['senderId'] == currentId;

                    return Align(
                      alignment: isSentByCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isSentByCurrentUser
                              ? Colors.blue[100]
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(message['message'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      await widget.chatController
                          .sendMessage(widget.recipientId, message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
