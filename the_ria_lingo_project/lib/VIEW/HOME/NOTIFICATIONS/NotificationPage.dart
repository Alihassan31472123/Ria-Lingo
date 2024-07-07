import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final StreamController<List<Map<String, dynamic>>>
      _notificationStreamController = StreamController.broadcast();
  List<Map<String, dynamic>> _notificationList = [];
  bool _isOffline = false;
  StreamSubscription<InternetConnectionStatus>? _listener;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _loadNotifications();

    _listener = InternetConnectionChecker().onStatusChange.listen((status) {
      final isOffline = status == InternetConnectionStatus.disconnected;
      setState(() {
        _isOffline = isOffline;
      });

      if (!isOffline) {
        _loadNotifications();
      }
    });
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isOffline = !isConnected;
    });
  }

  Future<void> _loadNotifications() async {
  await _checkConnectivity();

  if (_isOffline) {
    print('No internet connection');
    return;
  }

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('No access token found');
      return;
    }

    final response = await http.get(
      Uri.parse('https://rialingo-backend-41f23014baee.herokuapp.com/notifications?page=1&pageSize=30'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print(response.body);
      final dataInfo = jsonDecode(response.body);
      final notificationsData = dataInfo['data'] as List;

      if (mounted) {
        setState(() {
          _notificationList = notificationsData.map((notificationInfo) {
            final from = notificationInfo['from'] ?? {};
            final senderFirstName = from['firstName'] ?? '';
            final senderLastName = from['lastName'] ?? '';
            final senderName = '$senderFirstName $senderLastName';
            final documentTitle = notificationInfo['document']?['title'] ?? '';

            return {
              '_id': notificationInfo['_id'],
              'description': notificationInfo['description'] ?? '',
              'title': notificationInfo['title'] ?? '',
              'redirectTo': notificationInfo['redirectTo'] ?? '',
              'notificationType': notificationInfo['notificationType'] ?? '',
              'from': senderName,
              'profileUrl': from['profileUrl'] ?? '',
              'createdAt': notificationInfo['createdAt'] ?? '',
              'updatedAt': notificationInfo['updatedAt'] ?? '',
              'isRead': notificationInfo['isRead'] ?? false,
              'documentTitle': documentTitle,
            };
          }).toList();
        });
        _notificationStreamController.add(_notificationList);
      }
    } else {
      print('Failed to load notifications: ${response.body}');
    }
  } catch (e) {
    print('Error fetching notifications: $e');
    // Handle error as needed, such as showing a snackbar or retry option
  }
}

  Future<void> _markNotificationAsRead(String notificationId) async {
    final token = await _getAccessToken();
    if (token == null) {
      _showSnackbar('No access token found');
      return;
    }

    final response = await http.patch(
      Uri.parse(
          'https://rialingo-backend-41f23014baee.herokuapp.com/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'isRead': true}),
    );

    if (response.statusCode == 200) {
      setState(() {
        final notification = _notificationList.firstWhere(
            (notification) => notification['_id'] == notificationId);
        notification['isRead'] = true;
      });
      _showSnackbar('Notification marked as read');
    } else {
      _showSnackbar('Failed to mark notification as read');
    }
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.black,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
   String truncateText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      words = words.sublist(0, wordLimit);
      return words.join(' ') + '...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isOffline)
            Center(
              child: ElevatedButton(
                onPressed: _loadNotifications,
                child: const Text('Reconnect Internet'),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _notificationStreamController.stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.purple,
                      size: 50,
                    ),
                  );
                }
                final notificationList = snapshot.data!;
                return RefreshIndicator(
                    onRefresh: _loadNotifications,
                    child: ListView.builder(
  itemCount: notificationList.length,
  itemBuilder: (context, index) {
    final notification = notificationList[index];
    final createdAt = DateTime.parse(notification['createdAt']);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);
    final senderName = notification['from'];
    final jobTitle = notification['title'];
    final documentTitle = notification['documentTitle'];

    return ListTile(
      leading: notification['profileUrl'].isNotEmpty
          ? CircleAvatar(
              backgroundImage: NetworkImage(
                "https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/${notification['profileUrl']}"),
            )
          : const CircleAvatar(
              backgroundImage: AssetImage('assets/avatar.jpg'),
            ),
      title: Row(
       
        children: [
          Text(senderName),
          SizedBox(width: 5,),
           Text('-'),
           SizedBox(width: 5,),
         Flexible(child: Text(truncateText(documentTitle, 9))),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(jobTitle),
          Text('$formattedDate'),
        ],
      ),
      trailing: notification['isRead']
          ? null
          : const Icon(
              Icons.circle,
              color: Colors.purple,
              size: 10,
            ),
      onTap: () async {
        await _markNotificationAsRead(notification['_id']);
      },
    );
  },
)
 
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
