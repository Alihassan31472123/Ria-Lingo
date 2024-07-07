import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Notification service functions
Future<String?> _getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('access_token');
}

Future<List<dynamic>> fetchNotifications() async {
  final token = await _getAccessToken();
  if (token == null) {
    throw Exception('No access token found');
  }

  final response = await http.get(
    Uri.parse('https://rialingo-backend-41f23014baee.herokuapp.com/notifications?page=1&pageSize=30'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'];
  } else {
    throw Exception('Failed to load notifications');
  }
}

 Future<void> markNotificationAsRead(String notificationId) async {
  final token = await _getAccessToken();
  if (token == null) {
    throw Exception('No access token found');
  }

  final response = await http.patch(
    Uri.parse('https://rialingo-backend-41f23014baee.herokuapp.com/notifications/$notificationId/read'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({'isRead': true}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to mark notification as read');
  }
}
