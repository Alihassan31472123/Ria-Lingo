import 'dart:async';
import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/VIEW/BottomNavBar/BottomNavBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/Login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkTokenAndNavigate();
  }

  Future<void> _checkTokenAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    // Simulating a delay for the splash screen display
    await Future.delayed(const Duration(seconds: 3));

    if (accessToken != null && accessToken.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const BottomNavBar()), // Navigate to BottomNavbar screen
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const SignInScreen()), // Navigate to Login screen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // Replace 'assets/logo.png' with your logo image path
        child: Image.asset('assets/Group.png'),
      ),
    );
  }
}
