import 'package:flutter/material.dart';

class Calls2 extends StatefulWidget {
  final String callChannelID;
  const Calls2({
    super.key,
    required this.callChannelID,
  });

  @override
  State<Calls2> createState() => _Calls2State();
}

class _Calls2State extends State<Calls2> {
  @override
  void initState() {
    super.initState();
    print('Meeting ID: ${widget.callChannelID}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Call Screen'),
      ),
      body: Center(
        child: Text('Call with Meeting ID: ${widget.callChannelID}'),
      ),
    );
  }
}
