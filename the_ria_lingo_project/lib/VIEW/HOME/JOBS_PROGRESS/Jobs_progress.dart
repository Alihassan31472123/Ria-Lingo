import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_PROGRESS/Job_Contract.dart';
import 'package:the_ria_lingo_app/constants/ImagePath.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Jobprogress extends StatefulWidget {
  const Jobprogress({super.key});

  @override
  _JobprogressState createState() => _JobprogressState();
}

class _JobprogressState extends State<Jobprogress> {
  late Future<Map<String, dynamic>> jobProgressData;

  @override
  void initState() {
    super.initState();
    jobProgressData = fetchJobProgress();
  }

  Future<Map<String, dynamic>> fetchJobProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      const url =
          'https://rialingo-backend-41f23014baee.herokuapp.com/jobContracts?page=1&pageSize=10&status=in_progress';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = response.body;
        return jsonDecode(responseBody);
      } else {
        throw Exception(
            'Failed to fetch job contracts: ${response.statusCode}');
      }
    } else {
      throw Exception('Bearer token not found.');
    }
  }

  Future<void> _refreshJobProgress() async {
    setState(() {
      jobProgressData = fetchJobProgress();
    });
  }

  String _calculateTimeLeft(String startDate, String startTime) {
    try {
      // Try to parse the date and time using different formats
      DateTime jobDateTime;
      if (startDate.contains('/')) {
        jobDateTime =
            DateFormat("yyyy/MM/dd HH:mm").parse('$startDate $startTime');
      } else {
        jobDateTime =
            DateFormat("yyyy-MM-dd HH:mm").parse('$startDate $startTime');
      }

      // Calculate the difference between the jobDateTime and the current time
      Duration difference = jobDateTime.difference(DateTime.now());

      // Check if the job time has already passed
      if (difference.isNegative) {
        return "Time finished";
      }

      // Calculate days, hours, and minutes left
      int daysLeft = difference.inDays;
      int hoursLeft = difference.inHours.remainder(24);
      int minutesLeft = difference.inMinutes.remainder(60);

      // Format the result as "Xd Xh Xm left"
      return "${daysLeft}d ${hoursLeft}h ${minutesLeft}m left";
    } catch (e) {
      print('Error parsing date and time: $e');
      return "Invalid date/time format";
    }
  }

    String truncateText(String text, int wordLimit) {
    List<String> words = text.split(' ');
    if (words.length > wordLimit) {
      words = words.sublist(0, wordLimit);
      return words.join(' ') + '...';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Jobs Progress',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobProgress,
        child: FutureBuilder(
          future: jobProgressData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CardListSkeleton(
                isCircularImage: true,
                isBottomLinesActive: true,
                length: 10,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<dynamic> jobContracts = snapshot.data?['data'] ?? [];
              if (jobContracts.isEmpty) {
                return const Center(
                    child: Text('You don’t have any jobs in progress!'));
              } else {
                return ListView.builder(
                  itemCount: jobContracts.length,
                  itemBuilder: (context, index) {
                    final jobPosts = jobContracts[index]['job'];
                    final client = jobContracts[index]['client'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 470,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(25),
                                      child: Image.network(
                                        client != null
                                            ? '${ImagePath.baseUrl}${client['profileUrl']}'
                                            : 'assets/users12.png',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/users12.png',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '${client['firstName']} ${client['lastName']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    jobPosts['title'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Job Type:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      truncateText(jobPosts['jobType']['name'],10),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Services Type:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      truncateText(jobPosts['serviceType']['name'],10),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Call Type:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    truncateText(jobPosts['callType'],10),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Call Date',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    DateManner(jobPosts['startDate']),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Call Start Time:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    formatTime(jobPosts['startTime']),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Status',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    jobContracts[index]['status']
                                        .replaceAll('_', ' '),
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                height: 60,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: tileBlack.value,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Text(
                                          'Action',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colorgreen.value,
                                        ),
                                        onPressed: () {
                                          print(
                                              'JobContractID: ${jobContracts[index]['_id']}');
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => JobContract(
                                                JobContractID:
                                                    jobContracts[index]['_id'],
                                                jobstatusinprogress:
                                                    jobContracts[index]
                                                        ['status'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'View',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _calculateTimeLeft(
                                      jobPosts['startDate'],
                                      jobPosts['startTime'],
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }

  String DateManner(String dateStr) {
    // Replace slashes with dashes
    dateStr = dateStr.replaceAll('/', '-');
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String formatTime(String time) {
    // Parse the string into a DateTime object
    DateTime parsedTime = DateFormat("HH:mm").parse(time);

    // Format the DateTime object to a string with AM/PM
    return DateFormat("h:mm a").format(parsedTime);
  }
}
