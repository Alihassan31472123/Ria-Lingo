import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final String userPhone;
  final String userAddress;
  final String userCountry;
  final String userState;
  final String userCity;
  final String firstName;
  final String LastName;
  final String email;

  const EditProfile({
    required this.firstName,
    required this.LastName,
    required this.email,
    required this.userPhone,
    required this.userAddress,
    required this.userCountry,
    required this.userState,
    required this.userCity,
    super.key,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();
  final TextEditingController phone = TextEditingController();

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

  Future<void> UpdateProfile(BuildContext context) async {
    _showLoadingDialog(context); // Show loading dialog
    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/users/updateProfile';

    // Retrieve bearer token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    // Check if token is available
    if (accessToken == null) {
      // Handle case where token is not available
      print('Access token not found');
      return;
    }

    final requestBody = <String, dynamic>{
      "firstName": firstname.text, // Extract text from TextEditingController
      "lastName": lastname.text, // Extract text from TextEditingController
      "phone": phone.text, // Extract text from TextEditingController
      "address":
          addressController.text, // Extract text from TextEditingController
      "country":
          countryController.text, // Extract text from TextEditingController
      "state": stateController.text, // Extract text from TextEditingController
      "city": cityController.text, // Extract text from TextEditingController
    };

    final response = await http.patch(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken', // Add bearer token to headers
      },
      body: jsonEncode(requestBody),
    );
    Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

    if (response.statusCode == 200) {
      // Update successful
      print('Profile Updated');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile Updated'),
          backgroundColor: Colors.green,
        ),
      );

      // Save updated profile information to SharedPreferences
      await prefs.setString('firstName', firstname.text);
      await prefs.setString('lastName', lastname.text);
      await prefs.setString('phone', phone.text);
      await prefs.setString('address', addressController.text);
      await prefs.setString('country', countryController.text);
      await prefs.setString('state', stateController.text);
      await prefs.setString('city', cityController.text);

      Navigator.pop(context);
    } else if (response.statusCode == 400) {
      // User already exists
      print('Please input required fields: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please input required fields'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Update failed for other reasons
      print('Update failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Call a separate method to load data asynchronously
    loadDataFromSharedPreferences();
  }

  Future<void> loadDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname.text = prefs.getString('firstName') ?? widget.firstName;
      lastname.text = prefs.getString('lastName') ?? widget.LastName;
      phone.text = prefs.getString('phone') ?? widget.userPhone;
      addressController.text = prefs.getString('address') ?? widget.userAddress;
      countryController.text = prefs.getString('country') ?? widget.userCountry;
      stateController.text = prefs.getString('state') ?? widget.userState;
      cityController.text = prefs.getString('city') ?? widget.userCity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 30),
              child: Row(
                children: [
                  Text(
                    'First Name*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: firstname,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'Last Name*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: lastname,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'Email Address',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.email,
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'Phone*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: phone,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'Address*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: addressController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'Country*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: countryController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'State*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: stateController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    'City*',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 1,
                    color: Colors.white,
                    offset: Offset(1, 1)),
              ]),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: TextField(
                controller: cityController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: GestureDetector(
                onTap: () {
                  UpdateProfile(context);
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: purple.value,
                  ),
                  child: const Center(
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
