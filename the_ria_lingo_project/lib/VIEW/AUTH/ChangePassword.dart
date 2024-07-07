import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/LOADING/Loading.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> changePassword(BuildContext context) async {
    // Ensure old and new passwords are not empty
    if (oldController.text.isEmpty ||
        newController.text.isEmpty ||
        confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all password fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if new password and confirm password match
    if (newController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New password and confirm password do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Continue with API call
    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/users/changePassword';

    // Show loading indicator
    Loading.show(context);

    // Retrieve bearer token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    // Check if token is available
    if (accessToken == null) {
      // Handle case where token is not available
      print('Access token not found');
      Navigator.of(context, rootNavigator: true)
          .pop(); // Dismiss loading indicator
      return;
    }

    final requestBody = <String, String>{
      'oldPassword': oldController.text,
      'newPassword': newController.text,
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken', // Add bearer token to headers
      },
      body: jsonEncode(requestBody),
    );

    Navigator.of(context, rootNavigator: true)
        .pop(); // Dismiss loading indicator

    if (response.statusCode == 200) {
      // Password changed successfully
      print('Password changed successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your password has been changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      // Old password is incorrect
      final jsonResponse = jsonDecode(response.body);
      final errorMessage = jsonResponse['message'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Handle other status codes
      print('Error changing password: ${response.statusCode}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while changing your password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 70,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Change Password',
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
                'Your new password must be different',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: contentGrey.value,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'from previous used password',
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
                'Old Password',
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
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: oldController,
              obscureText: !_oldPasswordVisible,
              decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  prefixIconColor: purple.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _oldPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _oldPasswordVisible = !_oldPasswordVisible;
                      });
                    },
                  )),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              const SizedBox(width: 20),
              Text(
                'New Password',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: tileBlack.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: newController,
              obscureText: !_newPasswordVisible,
              decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  prefixIconColor: purple.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _newPasswordVisible = !_newPasswordVisible;
                      });
                    },
                  )),
            ),
          ),
          const SizedBox(height: 20.0),
          Row(
            children: [
              const SizedBox(width: 20),
              Text(
                'Confirm Password',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: tileBlack.value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: confirmController,
              obscureText: !_confirmPasswordVisible,
              decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  prefixIconColor: purple.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      });
                    },
                  )),
            ),
          ),
          const SizedBox(height: 20),
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
                onPressed: () => changePassword(context),
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
