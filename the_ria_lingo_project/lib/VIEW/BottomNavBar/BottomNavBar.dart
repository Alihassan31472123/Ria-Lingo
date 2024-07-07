import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/NOTIFICATIONS/NotificationPage.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/NOTIFICATIONS/StateNotifierNotifications.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:the_ria_lingo_app/VIEW/BottomNavBar/Logout_Confirmation.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/CHATS/ChatScreen.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/Dashboard.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/PROFILE/Profile.dart';

class BottomNavBar extends ConsumerStatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends ConsumerState<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const LogoutConfirm();
        },
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  List<Widget Function(BuildContext)> get _widgetOptions {
    return <Widget Function(BuildContext)>[
      (BuildContext context) => const Dashboard(),
      (BuildContext context) => Profile(context: context),
      (BuildContext context) => ChatScreen(),
      (BuildContext context) => NotificationsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final notificationCount = ref.watch(notificationCountProvider);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _widgetOptions.elementAt(_selectedIndex)(context),
        bottomNavigationBar: Material(
          elevation: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50.0),
                topRight: Radius.circular(50.0),
              ),
              child: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.account_circle),
                    label: 'Profile',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.chat),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (notificationCount > 0)
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                              child: Text(
                                '$notificationCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    label: 'Notifications',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.power_settings_new),
                    label: 'Logout',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: purple.value,
                unselectedItemColor: Colors.grey,
                onTap: _onItemTapped,
                iconSize: 30,
                selectedFontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
