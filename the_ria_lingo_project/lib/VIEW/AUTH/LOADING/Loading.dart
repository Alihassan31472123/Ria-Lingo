import 'package:flutter/material.dart';

class Loading {
  static Future<void> show(BuildContext context) async {
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
}
