import 'package:flutter/material.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/COMPLETED_JOB/Completed_jobs.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_FIND/Jobs_Find.dart';
import 'package:the_ria_lingo_app/VIEW/HOME/JOBS_PROGRESS/Jobs_progress.dart';
import 'package:the_ria_lingo_app/constants/colors.dart';

class JobsOptions extends StatelessWidget {
  const JobsOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        centerTitle: true,
        title: const Text(
          'Progress Jobs',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: circleGrey.value,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/jobscompletes.png',
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                ),
              ),
              title: const Text(
                'Find Work',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JobsFind()),
                );
              },
            ),
            ListTile(
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: circleGrey.value,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/progress.png',
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                ),
              ),
              title: const Text(
                'Jobs in Progress',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Jobprogress()),
                );
              },
            ),
            // ListTile(
            //   leading: Container(
            //     height: 45,
            //     width: 45,
            //     decoration: BoxDecoration(
            //       color: circleGrey.value,
            //       shape: BoxShape.circle,
            //     ),
            //     child: Image.asset(
            //       'assets/jobscompletes.png',
            //       width: 40, // Adjust the width as needed
            //       height: 40, // Adjust the height as needed
            //     ),
            //   ),
            //   title: const Text(
            //     'Job Details',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            //   ),
            //   onTap: () {
            //     // Add your onTap functionality here
            //     print('Tapped Job Details');
            //   },
            // ),

            ListTile(
              leading: Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: circleGrey.value,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/jobscompletes.png',
                  width: 40, // Adjust the width as needed
                  height: 40, // Adjust the height as needed
                ),
              ),
              title: const Text(
                'Job Completed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CompletedJobs()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
