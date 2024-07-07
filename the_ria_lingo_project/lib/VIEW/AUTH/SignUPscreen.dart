import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/Login.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          const SizedBox(
            height: 90,
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
          const SizedBox(height: 50.0),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              Text(
                'Full Name',
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
              decoration: InputDecoration(
                  hintText: 'User Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  prefixIcon: const Icon(Icons.account_circle),
                  prefixIconColor: purple.value),
            ),
          ),
          const SizedBox(height: 10.0),
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
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                    hintText: 'info@iconictek.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: const Icon(Icons.mail_outline),
                    prefixIconColor: purple.value),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
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
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                    hintText: '********',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    prefixIconColor: purple.value),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
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
              decoration: InputDecoration(
                  hintText: '********',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  prefixIconColor: purple.value),
            ),
          ),
          const SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // Text color
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
                onPressed: () {},
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don’t have an account?',
                style: TextStyle(
                    fontSize: 14,
                    color: tileBlack.value,
                    fontWeight: FontWeight.w400),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()));
                },
                child: const Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.purple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
