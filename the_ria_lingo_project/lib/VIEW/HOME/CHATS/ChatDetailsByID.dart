import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/CHATS/Messagebubbles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatDetails extends StatefulWidget {
  final String chatId;
  final String firstName;
  final String lastName;
  final String profilepicture;

  const ChatDetails(
      {Key? key,
      required this.chatId,
      required this.firstName,
      required this.lastName,
      required this.profilepicture})
      : super(key: key);

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final TextEditingController chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final StreamController<List<Map<String, dynamic>>> _messagesController =
      StreamController.broadcast();
  List<Map<String, dynamic>> messages = [];
  String userName = "Client";
  bool isSending = false;
  String interpreterId = '';
  String clientId = '';
  late IO.Socket socket;
  String typingStatus = 'Online';
  Timer? _messageFetchTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messagesController.close();
    socket.dispose();
    _messageFetchTimer?.cancel();
    chatController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    await _loadMessages();
    await _initializeSocket();
  }

  Future<void> _initializeSocket() async {
    try {
      socket = IO.io(
        'https://rialingo-backend-41f23014baee.herokuapp.com',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        },
      );

      socket.on('connect', (_) {
        print('connected');
        socket.emit('joinRoom', {'chatId': widget.chatId});
      });

      socket.on('messageReceived', (data) async {
        try {
          print('Message received: $data');
          if (data is Map<String, dynamic>) {
            final senderId = data['sender'];
            final senderName = data['senderName'] ?? '';
            final newMessage = {
              'isMe': senderId == interpreterId,
              'text': data['content'] ?? '',
              'time': data['createdAt'] ?? '',
              'updatedAt': data['updatedAt'] ?? '',
              'senderName': senderName,
              'profileUrl': '',
            };

            setState(() {
              messages.add(newMessage);
            });
            _messagesController.add(messages);
            _scrollToBottom();
          } else {
            print('Error: data is not a Map<String, dynamic>: $data');
          }
        } catch (e, stacktrace) {
          print('Error processing messageReceived event: $e');
          print(stacktrace);
        }
      });

      socket.on('typing', (data) {
        if (data['chatId'] == widget.chatId) {
          setState(() {
            typingStatus = '${data['userName']} is typing...';
          });
        }
      });

      socket.on('stopTyping', (data) {
        if (data['chatId'] == widget.chatId) {
          setState(() {
            typingStatus = 'Online';
          });
        }
      });

      socket.on('disconnect', (_) {
        print('disconnected');
      });

      socket.on('connect_error', (error) {
        print('Connection error: $error');
      });

      socket.connect();
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://rialingo-backend-41f23014baee.herokuapp.com/chats/${widget.chatId}/messages'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesData = data['data'] as List;

        final currentUserId = prefs.getString('user_id');

        if (messagesData.isNotEmpty) {
          final firstMessageSender = messagesData[0]['sender']['_id'];
          if (firstMessageSender == currentUserId) {
            interpreterId = currentUserId!;
            if (messagesData[0].containsKey('receiver') &&
                messagesData[0]['receiver'] != null) {
              clientId = messagesData[0]['receiver']['_id'];
            }
          } else {
            clientId = firstMessageSender;
            interpreterId = currentUserId!;
          }
        }

        setState(() {
          messages = messagesData.map((message) {
            final sender = message['sender'] ?? {};
            final senderId = sender['_id'] ?? '';
            final senderName =
                '${sender['firstName'] ?? ''} ${sender['lastName'] ?? ''}';
            if (senderId == clientId) {
              userName = senderName;
            }
            return {
              'isMe': senderId == interpreterId,
              'text': message['content'] ?? '',
              'time': message['createdAt'] ?? '',
              'updatedAt': message['updatedAt'] ?? '',
              'senderName': senderName,
              'profileUrl': '',
            };
          }).toList();
        });

        _messagesController.add(messages);
        _scrollToBottom();
      } else {
        print('Failed to load messages: ${response.body}');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String formatTime(String time) {
    final dateTime = DateTime.parse(time);
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<void> sendMessage() async {
    final url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/chats/${widget.chatId}/messages';
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print('Access token not found');
      setState(() {
        isSending = false;
      });
      return;
    }

    final messageContent = chatController.text;
    chatController.clear(); // Clear the text field immediately

    // Add message locally for instant display
    final newMessage = {
      'isMe': true, // Ensure this message is shown on the right side
      'text': messageContent,
      'time': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'senderName': 'Me', // Customize as needed
      'profileUrl': '',
    };

    setState(() {
      messages.add(newMessage);
      _messagesController.add(messages);
      _scrollToBottom();
    });

    final requestBody = {"content": messageContent};

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      setState(() {
        isSending = false;
      });
      // Optionally update messages from the server response if needed
    } else {
      setState(() {
        isSending = false;
      });
      print('${response.body}');
    }

    socket.emit('message', {
      'senderId': interpreterId,
      'content': requestBody['content'],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  void _handleTyping(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final userFirstName = prefs.getString('user_first_name');
    final userLastName = prefs.getString('user_last_name');

    if (userId == null || userFirstName == null || userLastName == null) {
      return;
    }
    final userName = '$userFirstName $userLastName';
    if (value.isNotEmpty) {
      socket.emit('startTyping', {
        'userId': userId,
        'chatId': widget.chatId,
        'userName': userName,
      });
    } else {
      socket.emit('stopTyping', {'chatId': widget.chatId});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.profilepicture.isNotEmpty
                  ? NetworkImage(
                      'https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/${widget.profilepicture}')
                  : const AssetImage('assets/users12.png')
                      as ImageProvider<Object>?,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.firstName} ${widget.lastName}',
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  typingStatus,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _messagesController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.purple,
                      size: 50,
                    ),
                  );
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return MessageBubble(
                      isMe: message['isMe'],
                      text: message['text'],
                      time: formatTime(message['time']),
                      senderName: message['senderName'],
                      profileUrl: '',
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController,
                    onChanged: _handleTyping,
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: isSending
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.purple,
                          size: 24,
                        )
                      : const Icon(Icons.send),
                  onPressed: () {
                    if (!isSending) {
                      setState(() {
                        isSending = true;
                      });
                      sendMessage();
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
