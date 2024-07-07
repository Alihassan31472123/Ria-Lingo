
// Service to fetch chat data
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final Dio _dio = Dio();

  Future<List<dynamic>> fetchChats() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await _dio.get(
      'https://rialingo-backend-41f23014baee.herokuapp.com/chats/all',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return response.data['data'];
    } else {
      throw Exception('Failed to load chats');
    }
  }
}