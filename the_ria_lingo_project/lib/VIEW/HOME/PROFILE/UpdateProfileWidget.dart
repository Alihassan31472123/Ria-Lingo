import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late Future<String> _profileUrlFuture;

  @override
  void initState() {
    super.initState();
    _profileUrlFuture = _getProfileUrl();
  }

  Future<String> _getProfileUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? profileUrl = prefs.getString('user_profile_url');
    if (profileUrl != null && profileUrl.isNotEmpty) {
      // Check if the profile URL is a complete URL
      if (profileUrl.startsWith('http')) {
        print('Profile URL available: $profileUrl');
        return profileUrl;
      } else {
        // If not a complete URL, prepend the host part
        String baseUrl = 'https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/';
        String completeUrl = baseUrl + profileUrl;
        print('Profile URL available: $completeUrl');
        return completeUrl;
      }
      
    } else {
      print('Profile URL not available');
      return '';
    }
  }

  File? _imageFile;
  bool _uploadingProfilePicture = false;

  Future<void> _uploadProfilePicture(BuildContext context) async {
    setState(() {
      _uploadingProfilePicture = true;
    });

    final url = Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/users/updateProfilePicture');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('Access token not found');
      }

      var request = http.MultipartRequest('PATCH', url)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files
            .add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);

        // Update the profile URL in SharedPreferences
        String updatedProfileUrl = decodedResponse['completeUrl'];
        prefs.setString('user_profile_url', updatedProfileUrl);

        // Show snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text('Profile Picture Updated'),
          ),
        );
        print('Successful profile picture upload: $decodedResponse');

        setState(() {
          _profileUrlFuture = Future.value(updatedProfileUrl);
        });
      } else {
        print('Error uploading profile picture: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
    } finally {
      setState(() {
        _uploadingProfilePicture = false;
      });
    }
  }

  Future<void> _getImageAndUpload() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      await _uploadProfilePicture(context);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _profileUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If loading profile URL, show loading indicator
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          // If error fetching profile URL, show error message
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          String profileUrl = snapshot.data ?? '';

          return Stack(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(5),
                height: 160,
                width: 160,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Show profile picture
                    CircleAvatar(
                      radius: 85,
                      backgroundColor: Colors.purple,
                      backgroundImage: profileUrl.isNotEmpty
                          ? NetworkImage(profileUrl)
                          : const AssetImage('assets/users12.png')
                              as ImageProvider<Object>?,
                    ),
                    // Show loading indicator if uploading profile picture
                    if (_uploadingProfilePicture)
                      const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        size: 18,
                      ),
                      onPressed: () {
                        _getImageAndUpload();
                      },
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
