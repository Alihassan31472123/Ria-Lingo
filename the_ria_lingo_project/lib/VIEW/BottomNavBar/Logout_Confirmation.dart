
import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/Login.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutConfirm extends StatefulWidget {
  const LogoutConfirm({super.key});

  @override
  _LogoutConfirmState createState() => _LogoutConfirmState();
}

class _LogoutConfirmState extends State<LogoutConfirm> {
  bool _loggingOut = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 5,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: const Text(
        'Log out',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: !_loggingOut
          ? const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Are you sure you want to log out?',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(purple.value),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logging Out...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
      actions: !_loggingOut
          ? [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Close dialog without logging out
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: purple.value,
                  elevation: 5,
                ),
                onPressed: () {
                  setState(() {
                    _loggingOut = true; // Start logging out
                  });
                  _logout(); // Perform logout action here
                },
                child: const Text('Log out'),
              ),
            ]
          : [],
    );
  }

  Future<void> _logout() async {
    // Simulate logout action
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_first_name');
    await prefs.remove('user_last_name');
    await prefs.remove('user_role');
    await prefs.remove('user_email');
    await prefs.remove('user_profile_url');
    await prefs.remove('user_phone');
    await prefs.remove('user_address');
    await prefs.remove('user_country');
    await prefs.remove('user_state');
    await prefs.remove('user_city');
    await prefs.remove('user_join_date');
    await prefs.remove('user_status');
    await prefs.remove('user_created_at');
    await prefs.remove('user_updated_at');
    await prefs.remove('access_token');
    await prefs.remove('access_token_expiry');
    await prefs.remove('refresh_token');
    await prefs.remove('refresh_token_expiry');
    print('Specific values removed from SharedPreferences.');

    // Close dialog
    Navigator.of(context).pop();

    // Navigate to login screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }
}
