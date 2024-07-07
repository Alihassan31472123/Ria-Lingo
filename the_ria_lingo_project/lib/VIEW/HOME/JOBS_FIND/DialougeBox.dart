import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JobProposalDialog extends StatefulWidget {
  final String jobID;
  final VoidCallback onProposalSubmitted;

  const JobProposalDialog({
    super.key,
    required this.jobID,
    required this.onProposalSubmitted,
  });

  @override
  State<JobProposalDialog> createState() => _JobProposalDialogState();
}

class _JobProposalDialogState extends State<JobProposalDialog> {
  

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    backgroundColor: Colors.white,
   );
  }
}
