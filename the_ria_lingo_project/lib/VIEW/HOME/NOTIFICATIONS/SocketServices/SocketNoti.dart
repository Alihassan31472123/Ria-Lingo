import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/CALLS_BY_AGORA/Calls_.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_FIND/Jobs_options.dart';

class SocketService {
  late IO.Socket _socket;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final StreamController<List<Map<String, dynamic>>>
      _notificationStreamController = StreamController.broadcast();
  final List<Map<String, dynamic>> _notificationList = [];
  BuildContext? context; // Make context nullable

  // Constructor without context
  SocketService() {
    _initializeNotifications();
  }

  // Setter to initialize context when available
  void setContext(BuildContext context) {
    this.context = context;
  }

  Stream<List<Map<String, dynamic>>> get notificationStream =>
      _notificationStreamController.stream;

  Future<void> _initializeNotifications() async {
    print('Initializing notifications');
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        print('Notification clicked with payload: $payload');
        if (payload != null) {
          final Map<String, dynamic> data = jsonDecode(payload);
          await Navigator.push(
            context!,
            MaterialPageRoute<void>(builder: (context) => JobsOptions()),
          );
        }
      },
      notificationCategories: [
        DarwinNotificationCategory(
          'demoCategory',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('join_action', 'Accept'),
            DarwinNotificationAction.plain(
              'decline_action',
              'Decline',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
                DarwinNotificationActionOption.foreground,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ],
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        print(
            'Notification clicked with payload: ${notificationResponse.payload}');
        if (notificationResponse.payload != null) {
          final payload = jsonDecode(notificationResponse.payload!);
          if (notificationResponse.actionId == 'join_action') {}
        }
      },
    ).catchError((e) {
      print('Error initializing notifications: $e');
    });

    await _requestNotificationPermissions();
    await _initializeSocket();
    print('Notifications initialized');
  }

  Future<void> _requestNotificationPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request().catchError((e) {
        print('Error requesting notification permissions: $e');
      });
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }
      if (status.isGranted) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }
  }

  Future<void> _initializeSocket() async {
    try {
      final userId = await _getUserId();
      _socket = IO.io(
        'https://rialingo-backend-41f23014baee.herokuapp.com',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': true,
        },
      );

      _socket.on('connect', (_) {
        print('Connected to socket');
        _socket.emit('user-connected', userId);
      });

      _socket.on('new-notification', (notificationData) {
        print('Noti Event run $notificationData');
        try {
          if (notificationData is Map<String, dynamic>) {
            final from = notificationData['from'] ?? {};
            final senderName =
                '${from['firstName'] ?? ''} ${from['lastName'] ?? ''}';
            final newNotification = {
              '_id': notificationData['_id'],
              'description': notificationData['description'] ?? '',
              'title': notificationData['title'] ?? '',
              'redirectTo': notificationData['redirectTo'] ?? '',
              'notificationType': notificationData['notificationType'] ?? '',
              'from': senderName,
              'profileUrl': from['profileUrl'] ?? '',
              'createdAt': notificationData['createdAt'] ?? '',
              'updatedAt': notificationData['updatedAt'] ?? '',
              'isRead': notificationData['isRead'] ?? false,
            };

            _notificationList.add(newNotification);
            _notificationStreamController.add(_notificationList);

            // Show notification with actions only if notificationType is "start_call"
            bool showActions =
                notificationData['notificationType'] == 'start_call';
            _showLocalNotification(newNotification, showActions: showActions);
          }
        } catch (e) {
          print('Error handling new notification: $e');
        }
      });
      _socket.on('disconnect', (_) {
        print('Disconnected from socket');
      });

      _socket.on('connect_error', (error) {
        print('Connection error: $error');
      });
    } catch (e) {
      print('Error initializing socket: $e');
    }
  }

  Future<void> _showLocalNotification(Map<String, dynamic> notification,
      {bool showActions = false}) async {
    const String channelId = 'high_importance_channel';
    const String channelName = 'High Importance Notifications';
    const String channelDescription =
        'This channel is used for important notifications.';

    // Define actions only if showActions is true
    List<AndroidNotificationAction>? androidActions;
    if (showActions) {
      androidActions = [
        const AndroidNotificationAction('join_action', 'Accept'),
        const AndroidNotificationAction('decline_action', 'Decline'),
      ];
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      actions: androidActions,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      categoryIdentifier: 'demoCategory',
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      notification['from'],
      notification['title'],
      platformChannelSpecifics,
      payload: jsonEncode(notification),
    );
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  Future<void> updateUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
    if (_socket.connected) {
      _socket.emit('user-disconnected', userId);
    }
    await _initializeSocket(); 
  }

  void dispose() {
    _notificationStreamController.close();
    _disconnectSocket();
  }

  Future<void> _disconnectSocket() async {
    final userId = await _getUserId();
    if (_socket.connected) {
      _socket.emit('user-disconnected', userId);
      _socket.dispose();
    }
  }
}
