import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedDetails extends ConsumerWidget {
  final String JobCompleteID;
  final String JobCompletedService;
  final String JobCompStatus;

  const CompletedDetails(
      {super.key, required this.JobCompleteID,
      required this.JobCompletedService,
      required this.JobCompStatus});

  String _formatDate(String dateString) {
    // Parse the date string
    DateTime dateTime = DateTime.parse(dateString);
    // Format the date to display only the date portion
    String formattedDate =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  String _truncateDescription(String description) {
    List<String> words = description.split(' ');
    // Truncate each word to the first 5 characters
    List<String> truncatedWords =
        words.map((word) => word.substring(0, min(10, word.length))).toList();
    // Join the truncated words back into a single string
    String truncatedDescription = truncatedWords.join(' ');
    return truncatedDescription;
  }

  String _truncateTranslation(String from, String to) {
    // Truncate the "from" and "to" strings to the first 5 characters separately
    String truncatedFrom = from.substring(0, min(5, from.length));
    String truncatedTo = to.substring(0, min(5, to.length));
    // Combine the truncated strings
    return '$truncatedFrom to $truncatedTo';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobDetailsFuture =
        ref.watch(jobCompletedProvider(JobCompleteID).future);

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
          'Completed Jobs Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: jobDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jobcompletedDetail = snapshot.data?['jobContract'];
            if (jobcompletedDetail == null) {
              return const Center(child: Text('No data available'));
            }

            final jobDetails1 = jobcompletedDetail['job'] ?? {};
            final clientDetails1 = jobDetails1['postedBy'] ?? {};
            //final interpreterDetails1 = jobcompletedDetail['interpreter'] ?? {};
            final proposalDetails1 = jobcompletedDetail['proposal'] ?? {};
            final clientProfileStats1 =
                snapshot.data?['clientProfileStats'] ?? {};
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 10, left: 10),
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              color: purple.value,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 5),
                                  child: Text(
                                    jobDetails1['title'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'Posted by: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '${clientDetails1['firstName'] ?? 'N/A'} ${clientDetails1['lastName'] ?? ''}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 100,
                            width: 307,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderaroundColor.value,
                                width: 2,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 10),
                                      Text(
                                        'Price',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: purple.value,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        '\$${jobDetails1['charges'] ?? 'N/A'}',
                                        style: TextStyle(
                                          color: tileBlack.value,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${jobDetails1['chargeType'].replaceAll('per_', '/')}',
                                        style: TextStyle(
                                          color: tileBlack.value,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(width: 10),
                                      Text(
                                        'Posted At:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: purple.value,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Text(
                                        DateManner(
                                            jobDetails1['createdAt'] ?? 'N/A'),
                                        style: TextStyle(
                                          color: tileBlack.value,
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
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _calculateTimeLeft(
                                  jobDetails1['startDate'] ?? 'N/A',
                                  jobDetails1['startTime'] ?? 'N/A',
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Job Type:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                jobDetails1['jobType']?['name'] ?? 'N/A',
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                jobDetails1['serviceType']?['name'] ?? 'N/A',
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  jobDetails1['translationFrom']?['name'] ??
                                      'N/A',
                                  jobDetails1['translationTo']?['name'] ??
                                      'N/A',
                                ),
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Call Type:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                jobDetails1['callType'] ?? 'N/A',
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Call Date:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateManner(jobDetails1['startDate'] ?? 'N/A'),
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Call Start Time:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                formatTime(jobDetails1['startTime'] ?? 'N/A'),
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Call End Time:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                formatTime(jobDetails1['endTime'] ?? 'N/A'),
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
                              horizontal: 30, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status:',
                                style: TextStyle(
                                  color: tileBlack.value,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                JobCompStatus,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: Center(
                            child: SizedBox(
                              height: 40,
                              width: 250,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  backgroundColor: purple.value,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Already Applied',
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
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: circleGrey.value,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: purple.value,
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10, top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Proposal Details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              proposalDetails1['description'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: tileBlack.value,
                              ),
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
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: circleGrey.value,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: purple.value,
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10, top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reviews',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  jobDetails1['clientRating'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: tileBlack.value,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              jobDetails1['description'] ?? 'N/A',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: tileBlack.value,
                              ),
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
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: circleGrey.value,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 42,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: purple.value,
                                  borderRadius: BorderRadius.circular(6)),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 10, top: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About the client',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Name',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${clientDetails1['firstName'] ?? 'N/A'} ${clientDetails1['lastName'] ?? ''}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${clientDetails1['status'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Spent',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    '${clientProfileStats1['totalHours']}',
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
                                  horizontal: 30, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Member Since',
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDate(
                                        jobDetails1['createdAt'] ?? 'N/A'),
                                    style: TextStyle(
                                      color: tileBlack.value,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRatingStars(int? rating) {
    if (rating != null && rating >= 1 && rating <= 5) {
      // Build stars based on the rating value
      List<Widget> stars = List.generate(rating, (index) {
        return Icon(
          Icons.star,
          color: Colorgreen.value,
          size: 24,
        );
      });

      return Row(
        children: stars,
      );
    } else {
      // Show N/A if rating is null or out of range
      return Text(
        'N/A',
        style: TextStyle(
          color: tileBlack.value,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }
}

final jobCompletedProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
        (ref, JobCompleteID) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    final url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/jobContracts/$JobCompleteID';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print(responseBody); // Log the response body
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to fetch job details: ${response.statusCode}');
    }
  } else {
    throw Exception('Bearer token not found.');
  }
});
