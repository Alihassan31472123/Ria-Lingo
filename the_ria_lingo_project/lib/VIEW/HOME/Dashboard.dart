// ignore_for_file: unused_result

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/COMPLETED_JOB/Completed_jobs.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_FIND/Jobs_options.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_PROGRESS/Jobs_progress.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/WALLET/Wallet.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken != null) {
    const url = 'https://rialingo-backend-41f23014baee.herokuapp.com/stats';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final responseBody = response.body;
      print(responseBody); // Log the response body
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to fetch dashboard data: ${response.statusCode}');
    }
  } else {
    throw Exception('Bearer token not found.');
  }
});

class Dashboard extends ConsumerWidget {
  const Dashboard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Map<String, dynamic>> dashboardData =
        ref.watch(dashboardProvider);
    return Scaffold(
      
      backgroundColor: Colors.white,
      appBar: AppBar(
          surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: InternetConnectionChecker().hasConnection,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.purple,
                  size: 50,
                ),
              );
            }

            if (snapshot.hasData && snapshot.data == true) {
              // Internet connection available, show dashboard
              return dashboardData.when(
                data: (data) {
                  final totalJobs = data['stats']?['today']?['total'] ?? 0;
                  final completedJobs =
                      data['stats']?['today']?['completed'] ?? 0;
                  final inProgressJobs =
                      data['stats']?['today']?['inProgress'] ?? 0;

                  final double completionPercentage =
                      totalJobs > 0 ? (completedJobs / totalJobs) * 100 : 0;

                  return ListView(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 140,
                              width: 140,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: completionPercentage / 100,
                                    color: purple.value,
                                    backgroundColor: Colors.grey[300],
                                    strokeWidth: 8,
                                  ),
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${completionPercentage.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: purple.value,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total jobs today',
                                  style: TextStyle(
                                    color: contentGrey.value,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  totalJobs.toString(),
                                  style: TextStyle(
                                    color: purple.value,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  height: 35,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: circleGrey.value,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'In Progress',
                                            style: TextStyle(
                                              color: tileBlack.value,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            inProgressJobs.toString(),
                                            style: TextStyle(
                                              color: tileBlack.value,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 35,
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: circleGrey.value,
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Completed',
                                            style: TextStyle(
                                              color: tileBlack.value,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            completedJobs.toString(),
                                            style: TextStyle(
                                              color: tileBlack.value,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Ink(
                          child: Container(
                            padding: const EdgeInsets.only(right: 10),
                            height: 300,
                            width: 290,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: borderaroundColor.value,
                              ), // Add black border
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CompletedJobs()));
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  color: circleGrey.value,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                      'assets/jobscompletes.png'),
                                                ),
                                              ),
                                              Text(
                                                'Jobs Completed',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                data['stats']?['today']
                                                            ?['completed']
                                                        ?.toString() ??
                                                    '0',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Jobprogress()));
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  color: circleGrey.value,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                      'assets/progress.png'),
                                                ),
                                              ),
                                              Text(
                                                'Jobs in Progress',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                data['stats']?['today']
                                                            ?['inProgress']
                                                        ?.toString() ??
                                                    '0',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Wallet()));
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  color: circleGrey.value,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                      'assets/amount.png'),
                                                ),
                                              ),
                                              Text(
                                                'Total Amount Earned',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                (data['stats']?['totalAmount']
                                                            as num?)
                                                        ?.toStringAsFixed(2) ??
                                                    '0.00',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Wallet()));
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    child: Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, right: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                height: 45,
                                                width: 45,
                                                decoration: BoxDecoration(
                                                  color: circleGrey.value,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Image.asset(
                                                      'assets/transaction.png'),
                                                ),
                                              ),
                                              Text(
                                                'Recent Transactions',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                (data['recentTransactions'] !=
                                                            null &&
                                                        data['recentTransactions']
                                                            is List &&
                                                        data['recentTransactions']
                                                            .isNotEmpty)
                                                    ? (data['recentTransactions']
                                                                [0]['amount'] ??
                                                            0)
                                                        .toStringAsFixed(2)
                                                    : '0.00',
                                                style: TextStyle(
                                                  color: tileBlack.value,
                                                  fontSize: 19,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 20),
                        child: Center(
                          child: SizedBox(
                            height: 49,
                            width: 310,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.black,
                                backgroundColor: purple.value,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const JobsOptions()));
                              },
                              child: const Text(
                                'Jobs',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.purple,
                    size: 50,
                  ),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Bad Internet Connection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          ref.refresh(dashboardProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // No internet connection
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'No Internet Connection',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        ref.refresh(dashboardProvider);
                      },
                      child: const Text('Reconnect to Internet'),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
