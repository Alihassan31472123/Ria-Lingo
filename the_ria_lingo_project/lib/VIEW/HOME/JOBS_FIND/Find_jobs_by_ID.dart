import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loader_skeleton/loader_skeleton.dart';
import 'package:the_ria_lingo_app/VIEW/AUTH/LOADING/Loading.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JobDetailsPage extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsPage({super.key, required this.jobId});

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends ConsumerState<JobDetailsPage> {
  bool isApplyButtonEnabled = true;
  final TextEditingController descriptionController = TextEditingController();

  String _formatDate(String dateString) {
    DateTime createdAt = DateTime.parse(dateString);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAt);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;
    String elapsedTime = '';
    if (days > 0) elapsedTime += '${days}d ';
    if (hours > 0) elapsedTime += '${hours}h ';
    if (minutes > 0) elapsedTime += '${minutes}m ';
    elapsedTime += 'ago';
    return elapsedTime;
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

  Future<void> submitJobProposal(BuildContext context, String jobId) async {
    final url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/jobPosts/$jobId/proposals';

    // Save the ancestor context before starting the asynchronous operations
    final savedContext = context;

    // Show loading dialog
    Loading.show(savedContext);

    final prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print('Access token not found');
      if (mounted) {
        Navigator.of(savedContext, rootNavigator: true).pop();
      }
      return;
    }

    if (descriptionController.text.isEmpty) {
      print('Description is empty');
      if (mounted) {
        Navigator.of(savedContext, rootNavigator: true).pop();
        ScaffoldMessenger.of(savedContext).showSnackBar(
          const SnackBar(
            content: Text('Please enter a description.'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(savedContext).pop(); // Close the dialog
      }
      return;
    }

    final requestBody = <String, dynamic>{
      "description": descriptionController.text,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(requestBody),
    );

    // Check if the widget is still mounted before using the context
    if (mounted) {
      Navigator.of(savedContext, rootNavigator: true).pop();

      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          isApplyButtonEnabled = false;
        });
        await prefs.setBool(
            'proposal_submitted_$jobId', true); // Save the state
        ScaffoldMessenger.of(savedContext).showSnackBar(
          const SnackBar(
            content: Text('Proposal Submitted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(savedContext).pop(); // Close the dialog
      } else if (response.statusCode == 400) {
        setState(() {
          isApplyButtonEnabled = false;
        });
        await prefs.setBool(
            'proposal_submitted_$jobId', true); // Save the state
        print('Proposal already submitted ${response.body}');
        ScaffoldMessenger.of(savedContext).showSnackBar(
          const SnackBar(
            content: Text('Proposal already submitted'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(savedContext).pop(); // Close the dialog
      } else {
        setState(() {
          isApplyButtonEnabled = false;
        });
        await prefs.setBool(
            'proposal_submitted_$jobId', true); // Save the state
        print('${response.body}');
        ScaffoldMessenger.of(savedContext).showSnackBar(
          const SnackBar(
            content: Text('Proposal Submitted'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(savedContext).pop(); // Close the dialog
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkProposalStatus();
  }

  Future<void> _checkProposalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? proposalSubmitted =
        prefs.getBool('proposal_submitted_${widget.jobId}');
    if (proposalSubmitted == true) {
      setState(() {
        isApplyButtonEnabled = false;
      });
    }
  }

  void showSubmitProposalDialog(BuildContext context, String jobId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: const Text(
            'Send Job Request',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: '',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.purple,
              ),
              onPressed: () async {
                await submitJobProposal(context, jobId);
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
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
    final jobDetailsFuture = ref.watch(jobDetailsProvider(widget.jobId).future);
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
      body: FutureBuilder(
        future: jobDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CardPageSkeleton(
              totalLines: 5,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final jobDetails = snapshot.data!['jobDetails'];
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, right: 15, left: 15, bottom: 10),
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
                                  padding:
                                      const EdgeInsets.only(left: 8, top: 8),
                                  child: Text(
                                    jobDetails['title'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: purple.value),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      '${jobDetails['postedBy']['firstName']} ${jobDetails['postedBy']['lastName']}',
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      '\$${(jobDetails['charges'])}/',
                                      style: TextStyle(
                                        color: tileBlack.value,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${(jobDetails['chargeType'].replaceAll('per_', ''))}',
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
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                      _formatDate(jobDetails[
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
                              horizontal: 16, vertical: 8),
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
                                jobDetails['serviceType']['name'],
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
                                    jobDetails['translationFrom']['name'],
                                    jobDetails['translationTo']['name']),
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
                                (jobDetails['description']),
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
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _calculateTimeLeft(
                                  jobDetails['startDate'],
                                  jobDetails['startTime'],
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
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
                        jobDetails['callType'],
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
                        DateManner(jobDetails['startDate']),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
                        formatTime(jobDetails['startTime']),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
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
                        formatTime(jobDetails['endTime']),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        jobDetails['status'],
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
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor:
                          isApplyButtonEnabled ? Colors.purple : Colors.grey,
                    ),
                    onPressed: isApplyButtonEnabled
                        ? () {
                            showSubmitProposalDialog(context, widget.jobId);
                          }
                        : null,
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
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

final jobDetailsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, jobId) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    final url =
        'https://rialingo-backend-41f23014baee.herokuapp.com/jobPosts/$jobId';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode == 200) {
      final responseBody = response.body;
      print(responseBody);
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to fetch job details: ${response.statusCode}');
    }
  } else {
    throw Exception('Bearer token not found.');
  }
});
