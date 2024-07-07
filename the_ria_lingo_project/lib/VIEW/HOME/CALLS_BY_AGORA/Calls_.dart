import 'dart:async';
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_ria_lingo_app/constants/app_ID.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Calls extends StatefulWidget {
  final String callChannelID;
  const Calls({
    super.key,
    required this.callChannelID,
  });

  @override
  State<Calls> createState() => _CallsState();
}

class _CallsState extends State<Calls> {
  final List<int> _remoteUids = [];
  final Map<int, bool> _remoteUserVideoStatus = {};
  final Map<int, bool> _remoteUserAudioStatus = {};
  bool _localUserJoined = false;
  bool _muted = false;
  bool _cameraOff = false;
  late RtcEngine _engine;
  late AgoraRtmClient _rtmClient;
  late AgoraRtmChannel _rtmChannel;
  String? firstName;
  String? lastName;
  String? profileUrl;
  int? startTime;
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  Map<int, String> _remoteUsernames = {};

  @override
  void initState() {
    super.initState();
    initAgora();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    print("Loading user data...");
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('user_first_name') ?? 'First';
      lastName = prefs.getString('user_last_name') ?? 'Last';
      profileUrl = prefs.getString('user_profile_url') ?? 'default_profile.png';
    });
    print("User data loaded: $firstName $lastName, profile URL: $profileUrl");
  }

  Future<String?> _getUserId() async {
    print("Getting user ID from SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');
    print("User ID: $userId");
    return userId;
  }

  Future<void> initAgora() async {
    print("Requesting permissions...");
    await [Permission.microphone, Permission.camera].request();
    print("Permissions granted.");

    print("Initializing Agora RTC Engine...");
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    print("Agora RTC Engine initialized.");

    print("Initializing Agora RTM Client...");
    _rtmClient = await AgoraRtmClient.createInstance(appId);
    _rtmClient.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print("Message received from $peerId: ${message.text}");
    };
    _rtmClient.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _rtmClient.logout();
        print('Logout.');
      }
    };
    print("Agora RTM Client initialized.");

    print("Logging into Agora RTM...");
    try {
      await _rtmClient.login(null, 'YOUR_USER_ID');
      print("Logged into Agora RTM.");
    } catch (e) {
      print("Failed to login to Agora RTM: $e");
    }

    print("Creating and joining RTM channel ${widget.callChannelID}...");
    _rtmChannel = (await _rtmClient.createChannel(widget.callChannelID))!;
    _rtmChannel.onMemberJoined = (AgoraRtmMember member) async {
      print("Member joined: ${member.userId}");
      await _fetchChannelAttributes(int.parse(member.userId));
    };
    _rtmChannel.onAttributesUpdated =
        (List<AgoraRtmChannelAttribute> attributes) {
      print("Channel attributes updated: $attributes");
      _handleAttributesUpdated(attributes);
    };

    await _rtmChannel.join();
    print("RTM channel joined successfully.");

    await _fetchChannelAttributes();
    print("Channel attributes fetched.");

    print("Initializing Socket...");
    final IO.Socket socket = IO.io(
        'https://rialingo-backend-41f23014baee.herokuapp.com',
        IO.OptionBuilder().setTransports(['websocket']).build());
    print("Socket initialized.");

    socket.onConnect((_) {
      print('Connected to socket server');
    });

    socket.on('callEnded', (res) {
      print('Call ended: $res');
      // Automatically end the call when this event runs
      if (res['success'] == true) {
        _endCallAndLeaveChannel();
      }
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
    });

    // Get the user ID from SharedPreferences
    String? userId = await _getUserId();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          print("Local user ${connection.localUid} joined");
          debugPrint("Local user ${connection.localUid} joined");

          String username = '$firstName $lastName';
          Map<String, String> attributes = {
            '${connection.localUid}': json.encode({
              'isUser': true,
              'uid': connection.localUid,
              'username': username,
            }),
          };

          // Emit joinMeetingRoom event
          if (userId != null) {
            print("Emitting joinMeetingRoom event...");
            socket.emitWithAck('joinMeetingRoom', {
              'jobContractId': widget.callChannelID,
              'userId': userId,
              'uid': connection.localUid.toString(), },
            );
            print("joinMeetingRoom event emitted.");
          }

          try {
            await _rtmClient.setChannelAttributes(
              widget.callChannelID,
              attributes.entries
                  .map((e) => AgoraRtmChannelAttribute(e.key, e.value))
                  .toList(),
              true,
            );
            print("Channel attributes updated successfully.");
          } catch (e) {
            print("Failed to update channel attributes: $e");
          }

          setState(() {
            _localUserJoined = true;
            startTime = DateTime.now().millisecondsSinceEpoch;
            _startTimer();
          });
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) async {
          print("Remote user $remoteUid joined");

          await Future.delayed(Duration(seconds: 1));
          await _fetchChannelAttributes(remoteUid);

          setState(() {
            _remoteUids.add(remoteUid);
          });
        },
        onUserMuteVideo: (RtcConnection connection, int remoteUid, bool muted) {
          setState(() {
            _remoteUserVideoStatus[remoteUid] = !muted;
          });
        },
        onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
          setState(() {
            _remoteUserAudioStatus[remoteUid] = !muted;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) async {
          print("Remote user $remoteUid left channel");
          debugPrint("Remote user $remoteUid left channel");

          try {
            await _rtmClient.deleteChannelAttributesByKeys(
              widget.callChannelID,
              [remoteUid.toString()],
              true,
            );
            print("Removed user $remoteUid from attributes.");
          } catch (e) {
            print("Failed to remove user $remoteUid from attributes: $e");
          }

          setState(() {
            _remoteUids.remove(remoteUid);
            _remoteUserVideoStatus.remove(remoteUid);
            _remoteUserAudioStatus.remove(remoteUid);
            _remoteUsernames.remove(remoteUid);
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) async {
          print("Local user left the channel");
          _rejoinChannel();
        },
      ),
    );

    print("Setting client role to broadcaster...");
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    print("Client role set to broadcaster.");

    print("Enabling video...");
    await _engine.enableVideo();
    print("Video enabled.");

    print("Starting preview...");
    await _engine.startPreview();
    print("Preview started.");

    print("Joining RTC channel ${widget.callChannelID}...");
    await _engine.joinChannel(
      token: "",
      channelId: widget.callChannelID,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    print("RTC channel joined successfully.");
  }

  Future<void> _endCallAndLeaveChannel() async {
    print("Ending call and leaving channel...");
    _stopTimer();
    await _engine.leaveChannel();
    Navigator.pop(context);
    _showReviewDialog(context);
    print("Call ended and channel left.");
  }

  Future<void> _fetchChannelAttributes([int? specificUid]) async {
    try {
      print('Fetching channel attributes');
      List<AgoraRtmChannelAttribute> fetchedAttributes =
          await _rtmClient.getChannelAttributes(widget.callChannelID) ?? [];

      for (var attribute in fetchedAttributes) {
        print("Attribute: ${attribute.key} - ${attribute.value}");
        try {
          var value = json.decode(attribute.value);
          if (specificUid == null || value['uid'] == specificUid) {
            if (value['uid'] != null && value['username'] != null) {
              setState(() {
                _remoteUsernames[value['uid']] = value['username'];
              });
            }
          }
          if (attribute.key == 'startTime') {
            print("Setting startTime: ${attribute.value}");
            setState(() {
              startTime = int.tryParse(attribute.value) ??
                  DateTime.now().millisecondsSinceEpoch;
            });
          }
        } catch (e) {
          print("Error decoding attribute value: $e");
        }
      }

      if (startTime != null) {
        int currentTime = DateTime.now().millisecondsSinceEpoch;
        int durationInSeconds = ((currentTime - startTime!) / 1000).floor();
        print('Call duration: $durationInSeconds seconds');
      }
    } catch (e) {
      print("Failed to fetch channel attributes: $e");
    }
  }

  void _handleAttributesUpdated(List<AgoraRtmChannelAttribute> attributes) {
    for (var attribute in attributes) {
      print("Attribute updated: ${attribute.key} - ${attribute.value}");
      if (attribute.key == 'startTime') {
        print("Updating startTime from attributes: ${attribute.value}");
        setState(() {
          startTime = int.tryParse(attribute.value) ??
              DateTime.now().millisecondsSinceEpoch;
        });
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (mounted) {
        setState(() {
          int currentTime = DateTime.now().millisecondsSinceEpoch;
          _elapsed = Duration(
              seconds:
                  ((currentTime - (startTime ?? currentTime)) / 1000).floor());
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _rejoinChannel() async {
    print("Rejoining RTC channel ${widget.callChannelID}...");

    await _engine.leaveChannel();
    await _engine.joinChannel(
      token: "",
      channelId: widget.callChannelID,
      uid: 0,
      options: const ChannelMediaOptions(),
    );

    // Fetch channel attributes after rejoining to get the details of already joined remote users
    await _fetchChannelAttributes();
  }

  @override
  void dispose() {
    _dispose();
    _stopTimer();
    super.dispose();
  }

  Future<void> _dispose() async {
    await _engine.leaveChannel();
    await _engine.release();
    await _rtmChannel.leave();
    _rtmClient.destroy();
    _timer?.cancel();
    await _rtmClient.setChannelAttributes(
      widget.callChannelID,
      [],
      true,
    );
  }

  int _rating = 0;
  TextEditingController _reviewController = TextEditingController();

  void _showReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text('Ria Lingo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please submit a review'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                    ),
                    color: Colors.amber,
                    onPressed: () {
                      setState(() {
                        _rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: 'Write a review',
                  ),
                  maxLines: 3),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                surfaceTintColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _endCallAndLeaveChannel();
              },
              child: Text(
                'Later',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                surfaceTintColor: Colors.purple,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                print('Rating: $_rating');
                print('Review: ${_reviewController.text}');
                Navigator.of(context).pop();
                _endCallAndLeaveChannel(); // Assuming you have this method implemented
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onCallEnd(BuildContext context) async {
    print("Ending call and leaving channel...");
    _stopTimer();
    await _engine.leaveChannel();
    Navigator.pop(context);

    print("Call ended and channel left.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _videoView(),
              ),
              _toolbar(),
            ],
          ),
          if (!_localUserJoined)
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 100,
              ),
            ),
          if (_localUserJoined)
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.red),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      _formatDuration(_elapsed),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _videoView() {
    List<Widget> views = [];
    if (_localUserJoined && !_cameraOff) {
      views.add(_buildLocalView());
    } else if (_cameraOff) {
      views.add(_buildProfileView());
    }
    for (int uid in _remoteUids) {
      views.add(_buildRemoteView(uid));
    }
    return Column(
      children: views,
    );
  }

  Widget _buildLocalView() {
    return Expanded(
      child: Stack(
        children: [
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Text(
              'You ($firstName $lastName)',
              style: const TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView() {
    return Expanded(
      child: Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: NetworkImage(
                'https://pub-006088b579004a638bd977f54a8cf45f.r2.dev/$profileUrl',
              ),
            ),
            Positioned(
              bottom: 16,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'You($firstName $lastName)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteView(int uid) {
    bool isRemoteUserVideoEnabled = _remoteUserVideoStatus[uid] ?? true;
    bool isRemoteUserAudioEnabled =
        _remoteUserAudioStatus[uid] ?? true; // Add this line
    String username = _remoteUsernames[uid] ?? 'Client Joined';

    return Expanded(
      child: Stack(
        children: [
          if (isRemoteUserVideoEnabled)
            AgoraVideoView(
              key: ValueKey(uid),
              controller: VideoViewController.remote(
                rtcEngine: _engine,
                canvas: VideoCanvas(uid: uid),
                connection: RtcConnection(channelId: widget.callChannelID),
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/users12.png'),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Row(
              children: [
                Text(
                  username,
                  style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  isRemoteUserAudioEnabled ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolbar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: _onToggleMute,
            icon: Icon(
              _muted ? Icons.mic_off : Icons.mic,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => _onCallEnd(context),
            icon: const Icon(
              Icons.call_end,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: _onToggleCamera,
            icon: Icon(
              _cameraOff ? Icons.videocam_off : Icons.videocam,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _onSwitchCamera,
            icon: const Icon(
              Icons.switch_camera,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      _muted = !_muted;
    });
    _engine.muteLocalAudioStream(_muted);
    print("Microphone ${_muted ? 'muted' : 'unmuted'}");
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
    print("Switched camera");
  }

  void _onToggleCamera() {
    setState(() {
      _cameraOff = !_cameraOff;
    });
    _engine.muteLocalVideoStream(_cameraOff);
    print("Camera ${_cameraOff ? 'off' : 'on'}");
  }
}
