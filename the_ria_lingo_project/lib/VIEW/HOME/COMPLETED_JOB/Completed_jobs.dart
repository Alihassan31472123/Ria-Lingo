import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/COMPLETED_JOB/CompletedDetails.dart';
import 'package:the_ria_lingo_app/constants/ImagePath.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedJobs extends StatefulWidget {
  const CompletedJobs({super.key});

  @override
  _CompletedJobsState createState() => _CompletedJobsState();
}

class _CompletedJobsState extends State<CompletedJobs> {
  late Future<Map<String, dynamic>> jobCompleted;

  @override
  void initState() {
    super.initState();
    jobCompleted = fetchJobCompleted();
  }

  Future<Map<String, dynamic>> fetchJobCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      const url =
          'https://rialingo-backend-41f23014baee.herokuapp.com/jobContracts?page=1&pageSize=10&status=completed';
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

  Future<void> _refereshCompleted() async {
    setState(() {
      jobCompleted = fetchJobCompleted();
    });
  }

  String _calculateTimeLeft(String startDate, String startTime) {
    // Parse the input date and time into a DateTime object
    DateTime jobDateTime = DateTime.parse('$startDate $startTime');

    // Calculate the difference between the jobDateTime and the current time
    Duration difference = jobDateTime.difference(DateTime.now());

    // Calculate days, hours, and minutes left
    int daysLeft = difference.inDays;
    int hoursLeft = difference.inHours.remainder(24);
    int minutesLeft = difference.inMinutes.remainder(60);

    // Format the result as "Xd Xh Xm left"
    return "${daysLeft}d ${hoursLeft}h ${minutesLeft}m left";
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
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Completed Jobs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refereshCompleted,
        child: FutureBuilder(
          future: jobCompleted,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CardPageSkeleton(
                totalLines: 5,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<dynamic> jobContracts1 = snapshot.data?['data'] ?? [];
              if (jobContracts1.isEmpty) {
                return const Center(
                    child: Text('You don’t have any completed jobs!'));
              } else {
                return ListView.builder(
                  itemCount: jobContracts1.length,
                  itemBuilder: (context, index) {
                    final jobPosts = jobContracts1[index]['job'];
                    final client = jobContracts1[index]['client'];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 440,
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
                                  horizontal: 16, vertical: 8),
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
                                  Text(
                                    jobPosts['jobType']['name'],
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
                                    'Services Type:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    jobPosts['serviceType']['name'],
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
                                    'Call Type:',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    jobPosts['callType'],
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
                                    jobContracts1[index]['status'],
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
                                              'JobCompleteID: ${jobContracts1[index]['_id']}');
                                          print(
                                              'JobCompletedService: ${jobPosts['serviceType']['name']}');
                                          print(
                                              'JobCompStatus: ${jobContracts1[index]['status']}');

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CompletedDetails(
                                                JobCompleteID:
                                                    jobContracts1[index]['_id'],
                                                JobCompletedService:
                                                    jobPosts['serviceType']
                                                        ['name'],
                                                JobCompStatus:
                                                    jobContracts1[index]
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
