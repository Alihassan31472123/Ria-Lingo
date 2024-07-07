import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/ChangePassword.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/PROFILE/Edit_profile.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/PROFILE/UpdateProfileWidget.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/WALLET/Wallet.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final userProfileProvider = FutureProvider<User>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userName = prefs.getString('user_first_name') ?? '';
  final userLastName = prefs.getString('user_last_name') ?? '';
  final userRole = prefs.getString('user_role') ?? '';
  final userEmail = prefs.getString('user_email') ?? '';
  final userProfileUrl = prefs.getString('user_profile_url') ?? '';
  final userPhone = prefs.getString('user_phone') ?? '';
  final userAddress = prefs.getString('user_address') ?? '';
  final userCountry = prefs.getString('user_country') ?? '';
  final userState = prefs.getString('user_state') ?? '';
  final userCity = prefs.getString('user_city') ?? '';
  final userJoinDate = prefs.getString('user_join_date') ?? '';
  final userStatus = prefs.getString('user_status') ?? '';
  final userCreatedAt = prefs.getString('user_created_at') ?? '';
  final userUpdatedAt = prefs.getString('user_updated_at') ?? '';
  DateTime joinDateTime = DateTime.parse(userJoinDate);
  String formattedJoinDate = DateFormat('yyyy-MM-dd').format(joinDateTime);

  return User(
    userName: userName,
    userLastName: userLastName,
    userRole: userRole,
    userEmail: userEmail,
    userProfileUrl: userProfileUrl,
    userPhone: userPhone,
    userAddress: userAddress,
    userCountry: userCountry,
    userState: userState,
    userCity: userCity,
    userJoinDate: formattedJoinDate,
    userStatus: userStatus,
    userCreatedAt: userCreatedAt,
    userUpdatedAt: userUpdatedAt,
  );
});

class User {
  final String userName;
  final String userLastName;
  final String userRole;
  final String userEmail;
  final String userProfileUrl;
  final String userPhone;
  final String userAddress;
  final String userCountry;
  final String userState;
  final String userCity;
  final String userJoinDate;
  final String userStatus;
  final String userCreatedAt;
  final String userUpdatedAt;

  User({
    required this.userName,
    required this.userLastName,
    required this.userRole,
    required this.userEmail,
    required this.userProfileUrl,
    required this.userPhone,
    required this.userAddress,
    required this.userCountry,
    required this.userState,
    required this.userCity,
    required this.userJoinDate,
    required this.userStatus,
    required this.userCreatedAt,
    required this.userUpdatedAt,
  });
}

class Profile extends ConsumerWidget {
  final BuildContext context;

  const Profile({super.key, required this.context});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    return userProfileAsync.when(
      loading: () => _buildLoading(),
      error: (error, stackTrace) => _buildError(error),
      data: (user) => _buildProfile(user),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildError(dynamic error) {
    return Center(
      child: Text('Error: $error'),
    );
  }

  Widget _buildProfile(User user) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 10,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProfileWidget(),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                user.userLastName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Container(
              height: 230,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: borderaroundColor.value,
                  width: 1,
                ), // Add black border
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status',
                          style: TextStyle(
                            color: Color(0xFF626262),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          height: 37,
                          width: 100,
                          decoration: BoxDecoration(
                            color: user.userStatus == 'active'
                                ? Colorgreen.value
                                : Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              user.userStatus == 'active'
                                  ? 'Active'
                                  : 'Inactive',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 70),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Earnings',
                          style: TextStyle(
                            color: Color(0xFF626262),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '\$0',
                          style: TextStyle(
                            color: Color(0xFF626262),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 30, right: 70),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jobs Done',
                          style: TextStyle(
                            color: Color(0xFF626262),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '0',
                          style: TextStyle(
                            color: Color(0xFF626262),
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        'Member Since',
                        style: TextStyle(
                          color: Color(0xFF626262),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        user.userJoinDate,
                        style: const TextStyle(
                          color: Color(0xFF626262),
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(
                          firstName: user.userName,
                          LastName: user.userLastName,
                          email: user.userEmail,
                          userPhone: user.userPhone,
                          userAddress: user.userAddress,
                          userCountry: user.userCountry,
                          userState: user.userState,
                          userCity: user.userCity,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 50,
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Wallet()),
                    );
                  },
                  child: const Text(
                    'Wallet',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
            child: Center(
              child: SizedBox(
                height: 50,
                width: 308,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePassword()));
                  },
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
          ),
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
            child: Center(
              child: SizedBox(
                height: 50,
                width: 308,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    _launchURL('https://www.rialingo.com/contact-us');
                  },
                  child: const Text(
                    'Account Deletion',
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
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
            child: Center(
              child: SizedBox(
                height: 50,
                width: 308,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: purple.value,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    _launchURL('https://www.rialingo.com/contact-us');
                  },
                  child: const Text(
                    'Privacy Policy',
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
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }
}
