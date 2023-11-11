import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Required for FirebaseAuth
import 'package:http/http.dart' as http; // Add this line for HTTP requests

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final String _cloudFunctionEndpoint =
      'https://us-central1-ai-app-v1.cloudfunctions.net/chat'; // Replace with your endpoint URL

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_messageController.text.trim().isNotEmpty && user != null) {
      final messageText = _messageController.text.trim();

      // Send user message to Firestore
      await FirebaseFirestore.instance.collection('messages').add({
        'text': messageText,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
      });

      // Call your Cloud Function to get AI response
      final aiResponse = await _getAIResponse(messageText);

      // Optionally, send AI response to Firestore or update your UI directly
      // ...

      _messageController.clear();
    }
  }

  Future<String> _getAIResponse(String message) async {
    try {
      final response = await http.post(
        Uri.parse(_cloudFunctionEndpoint),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'prompt': message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to call Cloud Function');
      }
    } catch (e) {
      print(e);
      throw Exception('Failed to load AI response');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth
        .instance.currentUser; // Define user here for use in the builder

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshot) {
                if (chatSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final chatDocs = chatSnapshot.data?.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: chatDocs?.length ?? 0,
                  itemBuilder: (ctx, index) => MessageBubble(
                    message: chatDocs![index]['text'],
                    isMe: chatDocs[index]['userId'] == user?.uid,
                    key: ValueKey(chatDocs[index].id),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final Key key;

  MessageBubble({required this.message, required this.isMe, required this.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[300]
                : Theme.of(context)
                    .colorScheme
                    .secondary, // Updated to use colorScheme.secondary
            borderRadius: BorderRadius.circular(12),
          ),
          width: 140,
          padding: EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 16,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 8,
          ),
          child: Text(
            message,
            style: TextStyle(color: isMe ? Colors.black : Colors.white),
          ),
        ),
      ],
    );
  }
}
