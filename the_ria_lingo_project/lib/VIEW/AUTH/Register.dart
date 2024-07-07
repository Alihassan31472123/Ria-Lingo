import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/LOADING/Loading.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/Login.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? selectedExperience;
  String? selectedIndustry;
  String? selectedLanguage;
  String? selectedLanguageId;
  String? selectedLanguage2;
  String? selectedLanguageId2;

  // Define language maps here
  Map<String, String> nativeLanguageMap = {};
  Map<String, String> targetLanguageMap = {};

  @override
  void initState() {
    super.initState();
    fetchNativeLanguages();
    fetchTargetLanguages();
  }

  Future<void> fetchNativeLanguages() async {
    final response = await http.get(Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/languages/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> languages = data['data'];
      Map<String, String> map = {};
      for (var language in languages) {
        String id = language['_id'];
        String name = language['name'];
        map[name] = id;
      }

      setState(() {
        nativeLanguageMap = map;
      });
    } else {
      throw Exception('Failed to load native languages');
    }
  }

  Future<void> fetchTargetLanguages() async {
    final response = await http.get(Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/languages/all'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> languages = data['data'];
      Map<String, String> map = {};
      for (var language in languages) {
        String id = language['_id'];
        String name = language['name'];
        map[name] = id;
      }
      setState(() {
        targetLanguageMap = map;
      });
    } else {
      throw Exception('Failed to load target languages');
    }
  }

  String? selectedRole; // Initialize selectedRole as null

  List<DropdownMenuItem<String>> roleDropdownItems = [
    const DropdownMenuItem(
      value: 'translator',
      child: Text('Translator'),
    ),
    const DropdownMenuItem(
      value: 'interpreter',
      child: Text('Interpreter'),
    ),
  ];

  File? _imageFile;
  String? completeUrl;
  String? filePath;
  bool _uploadingProfilePicture = false;

  Future<void> _uploadProfilePicture(
      File imageFile, BuildContext context) async {
    setState(() {
      _uploadingProfilePicture = true;
    });

    final url = Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/files/uploadProfile');

    try {
      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);

        setState(() {
          completeUrl = decodedResponse['completeUrl'];
          filePath = decodedResponse['filePath'];
        });

        // Show snack bar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text('Profile uploaded'),
          ),
        );

        print('Successful profile picture upload: $decodedResponse');
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
        filePath = _imageFile!.path.split('/').last;
      });

      await _uploadProfilePicture(_imageFile!, context);
    }
  }

  final List<String> _certificateCompleteUrls = [];
  final List<String> _certificateFilePaths = [];
  File? _singleCertificateFile;
  String _singleCertificateStatus = 'Tap to Upload';

  Future<void> _register(BuildContext context) async {
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
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        selectedRole!.isEmpty ||
        selectedExperience!.isEmpty ||
        selectedIndustry!.isEmpty ||
        _phoneController.text.isEmpty ||
        selectedLanguageId!.isEmpty ||
        selectedLanguageId2!.isEmpty ||
        _certificateFilePaths.isEmpty ||
        _notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Loading.show(context);
    const url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/auth/register';

    final requestBody = <String, dynamic>{
      "profileUrl": filePath,
      "email": _emailController.text,
      "password": _passwordController.text,
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "role": 'interpreter',
      "type": selectedRole,
      "experience": selectedExperience,
      "industry": selectedIndustry,
      "phone": _phoneController.text,
      "nativeLanguage": selectedLanguageId,
      "targetLanguage": selectedLanguageId2,
      "certificates": _certificateFilePaths,
      "notes": _notesController.text.trim(),
    };

    print('API Request Body:');
    requestBody.forEach((key, value) {
      print('$key: $value');
    });

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestBody),
    );
    Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog

    if (response.statusCode == 201) {
      // Registration successful
      print('Registration successful');
      print('Response body: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SignInScreen()));
    } else if (response.statusCode == 400) {
      // User already exists
      print('User already exists: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter Correct Information'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Registration failed for other reasons
      print('Registration failed: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  //  API FOR UPLOADING CERTIFICATE

  // List to manage multiple certificates
  final List<File?> _certificateFiles = [];
  final List<String> _certificateUploadStatuses = [];

// Function to add a new certificate upload field
  void _addCertificateField() {
    setState(() {
      _certificateFiles.add(null);
      _certificateUploadStatuses.add('Tap to Upload');
    });
  }

  void _removeCertificateField(int index) {
    setState(() {
      _certificateFiles.removeAt(index);
      _certificateUploadStatuses.removeAt(index);
    });
  }

  // function single certificate upload
  Future<void> _chooseSingleCertificateFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _singleCertificateFile = File(pickedFile.path);
        _singleCertificateStatus = 'Uploading Certificate...';
      });

      await _uploadSingleCertificate();
    }
  }

  Future<void> _uploadSingleCertificate() async {
    if (_singleCertificateFile == null) return;

    setState(() {
      _singleCertificateStatus = 'Uploading...';
    });

    final url = Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/files/uploadCertificate');

    try {
      var request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath(
            'file', _singleCertificateFile!.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);

        setState(() {
          _certificateCompleteUrls.add(decodedResponse['completeUrl']);
          _certificateFilePaths.add(decodedResponse['filePath']);
          _singleCertificateStatus = 'Uploaded';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text('Certificate uploaded'),
          ),
        );
      } else {
        setState(() {
          _singleCertificateStatus = 'Upload Failed';
        });
      }
    } catch (e) {
      setState(() {
        _singleCertificateStatus = 'Upload Failed';
      });
    }
  }

  Future<void> _chooseCertificateFromGallery(int index) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _certificateFiles[index] = File(pickedFile.path);
        _certificateUploadStatuses[index] = 'Uploading Certificate...';
      });

      await _uploadCertificate(index);
    }
  }

  Future<void> _uploadCertificate(int index) async {
    File? certificateFile = _certificateFiles[index];
    if (certificateFile == null) return;

    setState(() {
      _certificateUploadStatuses[index] = 'Uploading...';
    });

    final url = Uri.parse(
        'https://rialingo-backend-41f23014baee.herokuapp.com/files/uploadCertificate');

    try {
      var request = http.MultipartRequest('POST', url)
        ..files.add(
            await http.MultipartFile.fromPath('file', certificateFile.path));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = await response.stream.bytesToString();
        var decodedResponse = jsonDecode(responseData);

        setState(() {
          _certificateCompleteUrls.add(decodedResponse['completeUrl']);
          _certificateFilePaths.add(decodedResponse['filePath']);
          _certificateUploadStatuses[index] = 'Uploaded';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            content: Text('Certificate uploaded'),
          ),
        );
      } else {
        setState(() {
          _certificateUploadStatuses[index] = 'Upload Failed';
        });
      }
    } catch (e) {
      setState(() {
        _certificateUploadStatuses[index] = 'Upload Failed';
      });
    }
  }

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Interpreter',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Register',
                      style: GoogleFonts.poppins(
                        color: purple.value,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(5),
                          height: 160,
                          width: 160,
                          decoration: BoxDecoration(
                            color: purple
                                .value, // Assuming purple is defined somewhere
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 85,
                            backgroundColor: Colors
                                .purple, // Assuming purple is defined somewhere
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!) as ImageProvider
                                : const AssetImage('assets/users12.png'),
                          ),
                        ),
                        if (_uploadingProfilePicture) // Show loading indicator if uploading
                          Positioned.fill(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              height: 160,
                              width: 160,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
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
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 18,
                              ),
                              onPressed: _getImageAndUpload,
                              color: Colors
                                  .purple, // Assuming purple is defined somewhere
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'First Name',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Last Name',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscureText,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'I want to become',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                iconDisabledColor: Colors.white,
                                iconEnabledColor: Colors.white,
                                value: selectedRole,
                                hint: const Text('Open Select Menu'),
                                onChanged: (value) {
                                  setState(() {
                                    selectedRole = value;
                                  });
                                },
                                items: roleDropdownItems,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Interpreting Experience',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                iconDisabledColor: Colors.white,
                                iconEnabledColor: Colors.white,
                                value: selectedExperience,
                                hint: const Text('None'),
                                onChanged: (value) {
                                  setState(() {
                                    selectedExperience = value;
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: '1',
                                    child: Text('1 year'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2',
                                    child: Text('2 years'),
                                  ),
                                  DropdownMenuItem(
                                    value: '2+',
                                    child: Text('2+ years'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Industries',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                iconDisabledColor: Colors.white,
                                iconEnabledColor: Colors.white,
                                value: selectedIndustry,
                                hint: const Text('Legal'),
                                onChanged: (value) {
                                  setState(() {
                                    selectedIndustry = value;
                                  });
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Legal',
                                    child: Text('Legal'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Medical',
                                    child: Text('Medical'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Educational',
                                    child: Text('Educational'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Global Meetings Conference',
                                    child: Text('Global Meetings Conference'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Sign Language Assistance',
                                    child: Text('Sign Language Assistance'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Employment',
                                    child: Text('Employment'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Special Event',
                                    child: Text('Special Event'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Other',
                                    child: Text('Other'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'In these languages',
                      style: GoogleFonts.poppins(
                        color: purple.value,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Native Language',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                iconDisabledColor: Colors.white,
                                iconEnabledColor: Colors.white,
                                value: selectedLanguage,
                                hint: const Text('Please Select'),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedLanguage = value;
                                    selectedLanguageId =
                                        nativeLanguageMap[value!];
                                  });
                                },
                                items: nativeLanguageMap.keys
                                    .map((String languageName) {
                                  return DropdownMenuItem<String>(
                                    value: languageName,
                                    child: Text(languageName),
                                  );
                                }).toList(),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Target Language',
                      style: TextStyle(
                        fontSize: 16.0,
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
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Container(
                      height: 50,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedLanguage2,
                                hint: const Text('Please Select'),
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedLanguage2 = value;
                                    selectedLanguageId2 =
                                        targetLanguageMap[value!];
                                  });
                                },
                                items: targetLanguageMap.keys
                                    .map((String languageName) {
                                  return DropdownMenuItem<String>(
                                    value: languageName,
                                    child: Text(languageName),
                                  );
                                }).toList(),
                                iconDisabledColor: Colors.white,
                                iconEnabledColor: Colors.white,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      'Upload Your certificates',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: tileBlack.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: 1,
                            color: contentGrey.value,
                          ),
                        ),
                        height: 60,
                        width: 100,
                        child: Center(
                          child: Image.asset('assets/docs.png'),
                        ),
                      ),
                      TextButton(
                        onPressed: _chooseSingleCertificateFromGallery,
                        child: Text(
                          _singleCertificateStatus,
                          style: TextStyle(
                            fontSize: 16,
                            color: purple.value,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.grey.shade300,
                          surfaceTintColor: Colors.grey.shade300,
                        ),
                        onPressed: _addCertificateField,
                        child: const Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                for (int index = 0; index < _certificateFiles.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              width: 1,
                              color: contentGrey.value,
                            ),
                          ),
                          height: 60,
                          width: 100,
                          child: Center(
                            child: Image.asset('assets/docs.png'),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _chooseCertificateFromGallery(index);
                          },
                          child: Text(
                            _certificateUploadStatuses[index],
                            style: TextStyle(
                              color: purple.value,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _removeCertificateField(index);
                          },
                          child: const Icon(
                            Icons.remove,
                            color: Colors.black,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      'Note :',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: tileBlack.value,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  width: 340,
                  height: 100, // Increased height for a larger text field
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(width: 2, color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Center(
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
                          _register(context);
                        },
                        child: const Text(
                          'Submit Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
