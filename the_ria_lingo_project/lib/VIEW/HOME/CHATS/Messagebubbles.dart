import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final String time;
  final String senderName;
  final String profileUrl;

  const MessageBubble({
    Key? key,
    required this.isMe,
    required this.text,
    required this.time,
    required this.senderName,
    required this.profileUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) Text(senderName, style: TextStyle(fontWeight: FontWeight.bold)),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
            elevation: 5,
            color: isMe ? Colors.purple : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(
                      color: isMe ? Colors.white70 : Colors.black45,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
