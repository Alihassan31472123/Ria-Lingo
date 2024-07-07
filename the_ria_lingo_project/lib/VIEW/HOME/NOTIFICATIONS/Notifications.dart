// // ignore_for_file: unused_result

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:ria_interpreter_app/PROVIDERS/Providers.dart';
// import 'package:ria_interpreter_app/VIEW/HOME/NOTIFICATIONS/Notification_Services.dart';
// import 'package:ria_interpreter_app/VIEW/HOME/NOTIFICATIONS/StateNotifierNotifications.dart';

// class Notifications extends ConsumerStatefulWidget {
//   const Notifications({super.key});

//   @override
//   _NotificationsState createState() => _NotificationsState();
// }

// class _NotificationsState extends ConsumerState<Notifications> {
//   bool _isMarkingAsRead = false;
//   List<dynamic> _notifications = [];
//   int _notificationCount = 0;

//   String _formatDate(String dateTimeStr) {
//     final DateTime dateTime = DateTime.parse(dateTimeStr);
//     return DateFormat('MMMM dd, yyyy – hh:mm a').format(dateTime);
//   }

//   Future<void> _markAsRead(int index) async {
//     setState(() {
//       _isMarkingAsRead = true;
//     });

//     final notificationId = _notifications[index]['_id'];
//     try {
//       await markNotificationAsRead(notificationId);
//       setState(() {
//         _notifications[index]['isRead'] = true;
//         _notificationCount = _notifications
//             .where((notification) => notification['isRead'] == false)
//             .length;
//       });
//       ref.read(notificationCountProvider.notifier).setCount(_notificationCount);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text('Notification Readed'),
//           duration: const Duration(seconds: 5),
//           action: SnackBarAction(
//             label: 'Dismiss',
//             onPressed: () {
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             },
//           ),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       print('Failed to mark notification as read: $e');
//     } finally {
//       setState(() {
//         _isMarkingAsRead = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notificationsAsyncValue = ref.watch(notificationsProvider);
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         surfaceTintColor: Colors.white,
//         centerTitle: true,
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           notificationsAsyncValue.when(
//             data: (notifications) {
//               Future.microtask(() {
//                 _notifications = notifications;
//                 int unreadCount =
//                     notifications.where((n) => !n['isRead']).length;
//                 ref
//                     .read(notificationCountProvider.notifier)
//                     .setCount(unreadCount);
//               });

//               return notifications.isEmpty
//                   ? const Center(
//                       child: Text(
//                         'No Notification Received',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     )
//                   : RefreshIndicator(
//                       onRefresh: () async {
//                         ref.refresh(notificationsProvider);
//                       },
//                       child: ListView.builder(
//                         itemCount: notifications.length,
//                         itemBuilder: (context, index) {
//                           final notification = notifications[index];
//                           final fromUser = notification['from'];
//                           final formattedDate =
//                               _formatDate(notification['createdAt']);

//                           return ListTile(
//                             leading: CircleAvatar(
//                               backgroundImage: NetworkImage(
//                                 'https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/${fromUser['profileUrl']}',
//                               ),
//                             ),
//                             title: Text(
//                               '${fromUser['firstName']} ${fromUser['lastName']} ${notification['title']}',
//                             ),
//                             subtitle: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 if (notification['description'].isNotEmpty)
//                                   Text(notification['description']),
//                                 Text(
//                                   formattedDate,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             trailing: notification['isRead'] == false
//                                 ? const Icon(Icons.circle,
//                                     color: Colors.red, size: 10)
//                                 : null,
//                             onTap: () => _markAsRead(index),
//                           );
//                         },
//                       ),
//                     );
//             },
//             loading: () => Center(
//               child: LoadingAnimationWidget.staggeredDotsWave(
//                 color: Colors.purple,
//                 size: 50,
//               ),
//             ),
//             error: (error, stack) => Center(child: Text('Error: $error')),
//           ),
//           if (_isMarkingAsRead)
//             Container(
//               color: Colors.black.withOpacity(0.1),
//               child: Center(
//                 child: LoadingAnimationWidget.staggeredDotsWave(
//                   color: Colors.purple,
//                   size: 50,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
