import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/ForgetPassword.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/Register.dart';
import 'package:the_ria_lingo_app/VIEW/BottomNavBar/BottomNavBar.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/NOTIFICATIONS/SocketServices/SocketNoti.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_ria_lingo_app/main.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _showLoadingDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          surfaceTintColor: Colors.white,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Please wait..."),
              SizedBox(
                width: 30,
              ),
              CircularProgressIndicator(
                color: Colors.black,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> Login(BuildContext context, WidgetRef ref) async {
    // Check internet connection
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No internet connection'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validation checks for required fields
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _showLoadingDialog(context); // Show loading dialog

    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/auth/login';

    final requestBody = <String, dynamic>{
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );

    Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

    if (response.statusCode == 201) {
      // Login successful
      print('Login successful');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Store user data and tokens in SharedPreferences
      final responseData = jsonDecode(response.body);
      await _saveUserData(responseData['user']);
      await _saveTokens(responseData['tokens']);

      // Update user ID in the socket service
      final socketService = ref.read(socketServiceProvider);
      socketService.updateUserId(responseData['user']['_id']);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomNavBar(),
        ),
      );
    } else if (response.statusCode == 400) {
      // Invalid credentials
      print('Invalid credentials');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid credentials'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Other error
      print('Login failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          body: ListView(
            children: <Widget>[
              const SizedBox(
                height: 130,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Please login or signup our app',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: contentGrey.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 70.0),
              Row(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: tileBlack.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: 'Enter Your Email',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.mail_outline),
                          prefixIconColor: purple.value),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  const SizedBox(width: 20),
                  Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: tileBlack.value,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        hintText: 'Enter Your Password',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        prefixIconColor: purple.value,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5.0),
             
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Forgetpassword()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Forget Password'),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 55,
                  width: 250,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: purple.value,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    onPressed: () {
                      Login(context, ref);
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Don\'t have an account?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: contentGrey.value,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyForm()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: purple.value,
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userData['_id']);
    await prefs.setString('user_first_name', userData['firstName']);
    await prefs.setString('user_last_name', userData['lastName']);
    await prefs.setString('user_role', userData['role']);
    await prefs.setString('user_email', userData['email']);
    await prefs.setString('user_profile_url', userData['profileUrl']);
    await prefs.setString('user_phone', userData['phone']);
    await prefs.setString('user_address', userData['address'] ?? '');
    await prefs.setString('user_country', userData['country'] ?? '');
    await prefs.setString('user_state', userData['state'] ?? '');
    await prefs.setString('user_city', userData['city'] ?? '');
    await prefs.setString('user_join_date', userData['joinDate']);
    await prefs.setString('user_status', userData['status']);
    await prefs.setString('user_created_at', userData['createdAt']);
    await prefs.setString('user_updated_at', userData['updatedAt']);
  }

  Future<void> _saveTokens(Map<String, dynamic> tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens['access']['token']);
    await prefs.setString('access_token_expiry', tokens['access']['expiresAt']);
    await prefs.setString('refresh_token', tokens['refresh']['token']);
    await prefs.setString(
        'refresh_token_expiry', tokens['refresh']['expiresAt']);
  }

}
