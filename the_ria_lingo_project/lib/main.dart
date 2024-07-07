import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:the_ria_lingo_app/VIEW/SPLASH_SCREEN/SplashScreen.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/NOTIFICATIONS/SocketServices/SocketNoti.dart';
import 'package:shared_preferences/shared_preferences.dart';

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      print(
          'Notification clicked with payload: ${notificationResponse.payload}');
    },
  );
  await requestPermissions();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> requestPermissions() async {
  await [
    Permission.storage,
    Permission.phone,
    Permission.microphone,
    Permission.camera,
    Permission.notification,
  ].request();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  if (await Permission.notification.isPermanentlyDenied) {
    openAppSettings();
  }

  if (await Permission.notification.status.isLimited) {
    await Permission.notification.request();
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _checkAndRunSocketService(ref, context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ria Lingo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: purple.value),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {},
    );
  }

  Future<void> _checkAndRunSocketService(WidgetRef ref, BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (!isFirstRun) {
      final socketService = ref.read(socketServiceProvider);
      socketService.setContext(context);
    }

    await prefs.setBool('isFirstRun', false);
  }
}
