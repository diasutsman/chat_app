import 'package:chat_app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

late User loggedInUser;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'CHAT_SCREEN';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late DateTime now;
  late String formattedDate;
  late String messageText;

  getCurrentUser() {
    try {
      final user = _auth.currentUser;
      loggedInUser = user as User;
      print(loggedInUser.email);
    } catch (e) {
      rethrow;
    }
  }

  /**
   * untuk mengolah data 1 kali
   * ketika halaman pertama kali dibuka akan mengolah initState
   * dan akan mengecek
   */

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.forum),
        centerTitle: true,
        title: Text('Chat Screen'),
        backgroundColor: Colors.lightBlueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessageStream(),
          Container(
            decoration: kMessageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: TextStyle(color: Colors.black),
                    onChanged: (newValue) {
                      messageText = newValue;
                    },
                    decoration: kMessageTextFieldDecoration,
                  ),
                ),
                TextButton(
                  child: Text(
                    'Send',
                    style: kSendButtonTextStyle,
                  ),
                  onPressed: () {
                    // memberitahu bahwa objek telah berubah nilainya
                    setState(() {
                      now = DateTime.now();
                      formattedDate = DateFormat('kk:mm:ss').format(now);
                    });
                    messageController.clear();
                    _firestore.collection('messages').add({
                      'text': messageText.trim(),
                      'sender': loggedInUser.email?.trim(),
                      'time': formattedDate.trim()
                    });
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

class MessageStream extends StatelessWidget {
  const MessageStream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages) {
          final messageText = message['text'];
          final messageSender = message['sender'];

          final currentUserEmail = loggedInUser.email;

          final messageBubble = MessageBubble(
              sender: messageSender,
              text: messageText,
              isMe: currentUserEmail == messageSender);
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            reverse: true,
            children: messageBubbles,
          ),
        );
      },
      stream: _firestore
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  const MessageBubble({
    Key? key,
    required this.sender,
    required this.text,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
          SizedBox(
            height: 5,
          ),
          Material(
            borderRadius: BorderRadius.only(
              // jika pesan dari saya, maka border radius atas kanan akan lancip
              // jika tidak, maka border radius atas kiri akan lancip
              topLeft: isMe ? Radius.circular(30) : Radius.circular(0),
              topRight: isMe ? Radius.circular(0) : Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            elevation: 5,
            color: isMe ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              child: Text(
                text,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.lightBlue,
                    fontSize: 15),
              ),
            ),
          )
        ],
      ),
    );
  }
}
