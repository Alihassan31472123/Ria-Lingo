import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationCountNotifier extends StateNotifier<int> {
  NotificationCountNotifier() : super(0);

  void setCount(int count) {
    state = count;
  }
}

final notificationCountProvider = StateNotifierProvider<NotificationCountNotifier, int>((ref) {
  return NotificationCountNotifier();
});
