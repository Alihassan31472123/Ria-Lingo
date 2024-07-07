import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_FIND/Find_jobs_by_ID.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobsFind extends StatefulWidget {
  const JobsFind({super.key});

  @override
  _JobsFindState createState() => _JobsFindState();
}

class _JobsFindState extends State<JobsFind> {
  late Future<Map<String, dynamic>> jobPostsData;

  @override
  void initState() {
    super.initState();
    jobPostsData = fetchJobPosts();
  }

  Future<Map<String, dynamic>> fetchJobPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      final queryParams = {
        'page': '1',
        'pageSize': '10',
        'status': 'open',
      };

      final url = Uri(
        scheme: 'https',
        host: 'rialingo-backend-41f23014baee.herokuapp.com',
        path: '/jobPosts',
        queryParameters: queryParams,
      );

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        print(response.body);
        final responseBody = response.body;
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to fetch job posts: ${response.statusCode}');
      }
    } else {
      throw Exception('Bearer token not found.');
    }
  }

  Future<void> _refreshJobPosts() async {
    setState(() {
      jobPostsData = fetchJobPosts();
    });
  }

  String _formatDate(String dateString) {
    try {
      // Check and handle both date formats
      DateTime createdAt;
      if (dateString.contains('/')) {
        createdAt = DateFormat('yyyy/MM/dd').parse(dateString);
      } else {
        createdAt = DateFormat('yyyy-MM-dd').parse(dateString);
      }

      // Get the current date and time
      DateTime now = DateTime.now();

      // Calculate the difference
      Duration difference = now.difference(createdAt);

      // Extract days, hours, and minutes
      int days = difference.inDays;
      int hours = difference.inHours % 24;
      int minutes = difference.inMinutes % 60;

      // Format the difference as a string
      String elapsedTime = '';
      if (days > 0) elapsedTime += '${days}d ';
      if (hours > 0) elapsedTime += '${hours}h ';
      if (minutes > 0) elapsedTime += '${minutes}m ';

      // Add "ago" at the end
      elapsedTime += 'ago';

      return elapsedTime;
    } catch (e) {
      print('Error parsing date: $e');
      return "Invalid date format";
    }
  }

  String _truncateTranslation(String from, String to) {
    // Truncate the "from" and "to" strings to the first 5 characters separately
    String truncatedFrom = from.substring(0, min(5, from.length));
    String truncatedTo = to.substring(0, min(5, to.length));
    // Combine the truncated strings
    return '$truncatedFrom to $truncatedTo';
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
          'Posted Jobs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshJobPosts,
        child: FutureBuilder(
          future: jobPostsData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CardPageSkeleton(
                totalLines: 5,
              ));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final List<dynamic> jobPosts = snapshot.data?['data'] ?? [];
              if (jobPosts.isEmpty) {
                return const Center(child: Text('No job posts found!'));
              } else {
                return ListView.builder(
                  itemCount: jobPosts.length,
                  itemBuilder: (context, index) {
                    final job = jobPosts[index];
                    return Padding(
                      padding:
                          const EdgeInsets.only(top: 10, right: 15, left: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 152,
                                width: 307,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: purple.value,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, top: 8),
                                      child: Text(
                                        job['title'],
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: purple.value),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Posted by :',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: tileBlack.value),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          '${job['postedBy']['firstName']} ${job['postedBy']['lastName']}',
                                          style: TextStyle(
                                            color: tileBlack.value,
                                            fontSize: 19,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Price:',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: tileBlack.value),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          '\$${(job['charges'])}/',
                                          style: TextStyle(
                                            color: tileBlack.value,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${(job['chargeType'].replaceAll('per_', ''))}',
                                          style: TextStyle(
                                            color: tileBlack.value,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          'Posted At :',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: tileBlack.value),
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          _formatDate(job[
                                              'createdAt']), // Use _formatDate function to format the date
                                          style: TextStyle(
                                            color: tileBlack.value,
                                            fontSize: 17,
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
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Job Type:',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                 Flexible(
                                child: Text(
                                  truncateText(
                                       job['jobType']?['name'] ?? 'N/A',6),
                                  style: TextStyle(
                                    color: tileBlack.value,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
                                  Text(
                                    'Services Type:',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    job['serviceType']['name'],
                                    style: TextStyle(
                                      color: tileBlack.value,
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
                                  Text(
                                    'Conversion Type:',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _truncateTranslation(
                                        job['translationFrom']['name'],
                                        job['translationTo']['name']),
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                                  'Job Description:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: purple.value),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10, top: 10),
                              child: Column(
                                children: [
                                  Text(
                                    (job['description']),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _calculateTimeLeft(
                                      job['startDate'],
                                      job['startTime'],
                                    ),
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.black,
                                      backgroundColor: Colorgreen.value,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JobDetailsPage(
                                            jobId: job[
                                                '_id'], // Pass the JobID to JobDetailsPage
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
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
}
