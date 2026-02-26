import 'dart:developer' as console;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:health_research/pages/dashboard.dart';

class TherapyVideoCall extends StatefulWidget {
  final String sessionId;
  final String token;
  final bool isDoctor;

  const TherapyVideoCall({
    Key? key,
    required this.sessionId,
    required this.token,
    required this.isDoctor,
  }) : super(key: key);

  @override
  State<TherapyVideoCall> createState() => _TherapyVideoCallState();
}

class _TherapyVideoCallState extends State<TherapyVideoCall> {
  late RtcEngine _engine;

  int? remoteUid;
  bool localJoined = false;
  bool muted = false;
  bool cameraOff = false;

  final String appId = "b62636e82bae4d77a10929859b2d798f";

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    await _engine.enableVideo();
    await _engine.startPreview();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          setState(() => localJoined = true);
        },
        onUserJoined: (connection, uid, elapsed) {
          setState(() => remoteUid = uid);
        },
        onUserOffline: (connection, uid, reason) {
          setState(() => remoteUid = null);
        },
      ),
    );

    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.sessionId,
      uid: 0,
      options: ChannelMediaOptions(
        clientRoleType: widget.isDoctor
            ? ClientRoleType.clientRoleBroadcaster
            : ClientRoleType.clientRoleAudience,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  // ---------------- LEAVE CALL ----------------
  Future<void> leaveCall() async {
    await _engine.leaveChannel();
    await _engine.release();

    console.log("Session Ended");

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Dashboard()),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// REMOTE VIDEO
          Center(child: _remoteVideo()),

          /// LOCAL VIDEO
          Positioned(
            top: 40,
            left: 20,
            child: SizedBox(
              width: 120,
              height: 160,
              child: localJoined
                  ? _localPreview()
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),

          /// CONTROLS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circleButton(
                  icon: muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => muted = !muted);
                    _engine.muteLocalAudioStream(muted);
                  },
                ),
                _circleButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: leaveCall,
                ),
                _circleButton(
                  icon: cameraOff ? Icons.videocam_off : Icons.videocam,
                  color: cameraOff ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => cameraOff = !cameraOff);
                    _engine.muteLocalVideoStream(cameraOff);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ---------------- LOCAL VIDEO ----------------
  Widget _localPreview() {
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  // ---------------- REMOTE VIDEO ----------------
  Widget _remoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: widget.sessionId),
        ),
      );
    } else {
      return const Text(
        "Waiting for therapist to join...",
        style: TextStyle(color: Colors.white, fontSize: 18),
      );
    }
  }

  // ---------------- BUTTON ----------------
  Widget _circleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}
