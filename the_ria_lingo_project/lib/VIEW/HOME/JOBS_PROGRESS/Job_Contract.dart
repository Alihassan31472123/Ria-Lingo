import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_ria_lingo_app/VIEW/HOME/CALLS_BY_AGORA/Calls_.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class JobContract extends StatelessWidget {
  final String JobContractID;
  final String jobstatusinprogress;

  const JobContract({
    Key? key,
    required this.JobContractID,
    required this.jobstatusinprogress,
  }) : super(key: key);

  Future<Map<String, dynamic>> fetchJobContractDetails(
      String jobContractID) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken != null) {
      final url =
          'https://rialingo-backend-41f23014baee.herokuapp.com/jobContracts/$jobContractID';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        return jsonDecode(responseBody);
      } else {
        throw Exception('Failed to fetch job details: ${response.statusCode}');
      }
    } else {
      throw Exception('Bearer token not found.');
    }
  }

  String _truncateDescription(String description) {
    List<String> words = description.split(' ');
    List<String> truncatedWords =
        words.map((word) => word.substring(0, min(10, word.length))).toList();
    String truncatedDescription = truncatedWords.join(' ');
    return truncatedDescription;
  }

  String _truncateTranslation(String from, String to) {
    String truncatedFrom = from.substring(0, min(5, from.length));
    String truncatedTo = to.substring(0, min(5, to.length));
    return '$truncatedFrom to $truncatedTo';
  }

  String _calculateTimeLeft(String startDate, String startTime) {
    DateTime jobDateTime = DateTime.parse('$startDate $startTime');
    Duration difference = jobDateTime.difference(DateTime.now());
    int daysLeft = difference.inDays;
    int hoursLeft = difference.inHours.remainder(24);
    int minutesLeft = difference.inMinutes.remainder(60);
    return "${daysLeft}d ${hoursLeft}h ${minutesLeft}m left";
  }

  String dateManner(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat('MMMM dd, yyyy').format(date);
  }

  String formatTime(String time) {
    DateTime parsedTime = DateFormat("HH:mm").parse(time);
    return DateFormat("h:mm a").format(parsedTime);
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
          child: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: const Text(
          'Job Contract',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchJobContractDetails(JobContractID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.purple,
                size: 50,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jobContract = snapshot.data?['jobContract'];
            if (jobContract == null) {
              return const Center(child: Text('No data available'));
            }
            final callDetails = jobContract['callDetails'] ?? {};
            final isCallActive = callDetails['isCallActive'] ?? false;
            final jobDetails = jobContract['job'] ?? {};
            final clientDetails = jobDetails['postedBy'] ?? {};
            final interpreterDetails = jobContract['interpreter'] ?? {};
            final proposalDetails = jobContract['proposal'] ?? {};
            final clientProfileStats =
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
                                    jobDetails['title'] ?? 'N/A',
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
                                        '${clientDetails['firstName'] ?? 'N/A'} ${clientDetails['lastName'] ?? ''}',
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
                                        '\$${jobDetails['charges'] ?? 'N/A'}',
                                        style: TextStyle(
                                          color: tileBlack.value,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${jobDetails['chargeType'].replaceAll('per_', '/')}',
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
                                        dateManner(jobDetails['createdAt']),
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
                                  jobDetails['startDate'] ?? 'N/A',
                                  jobDetails['startTime'] ?? 'N/A',
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
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  truncateText(
                                      jobDetails['jobType']?['name'] ?? 'N/A',
                                      10),
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
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: Text(
                                  truncateText(
                                      jobDetails['serviceType']?['name'] ??
                                          'N/A',
                                      10),
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
                                  jobDetails['translationFrom']?['name'] ??
                                      'N/A',
                                  jobDetails['translationTo']?['name'] ?? 'N/A',
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
                                jobDetails['callType'] ?? 'N/A',
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
                                dateManner(jobDetails['startDate'] ?? 'N/A'),
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
                                formatTime(jobDetails['startTime'] ?? 'N/A'),
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
                                formatTime(jobDetails['endTime'] ?? 'N/A'),
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
                                jobstatusinprogress.replaceAll('_', ' '),
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
                              proposalDetails['description'] ?? 'N/A',
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
                                  jobDetails['clientRating'] ?? 'N/A',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: tileBlack.value,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              jobDetails['description'] ?? 'N/A',
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
                                    '${clientDetails['firstName'] ?? 'N/A'} ${clientDetails['lastName'] ?? ''}',
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
                                    '${clientDetails['status'] ?? 'N/A'}',
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
                                    '${clientProfileStats['totalHours']}',
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
                                    dateManner(
                                        jobDetails['createdAt'] ?? 'N/A'),
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
                const SizedBox(
                  height: 10,
                ),
            
              Align(
  alignment: Alignment.center,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Padding(
                padding: EdgeInsets.only(left: 10, top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
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
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 40,
                width: 120,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: isCallActive ? purple.value : Colors.grey,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: isCallActive
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Calls(
                                callChannelID: JobContractID,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Center(
                    child: Text(
                      'Join Call',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  ),
),
     const SizedBox(height: 20),
              ],
            );
          }
        },
      ),
    );
  }
}
