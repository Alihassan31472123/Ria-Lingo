import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../VIEW/HOME/CHATS/ChatServices.dart';

// Define a state provider for chat list
// Provider to manage chat data
final chatListProvider = FutureProvider<List<dynamic>>((ref) async {
  return await ChatService().fetchChats();
});

// Define a state provider for notifications
// final notificationsProvider = FutureProvider<List<dynamic>>((ref) async {
//   return await fetchNotifications();
// });
