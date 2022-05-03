// import 'dart:async';

// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:flutter/material.dart';
// import 'package:genesis/models/User.dart';
// import 'package:genesis/models/chat-params.dart';
// import 'package:permission_handler/permission_handler.dart';

// const appId = "bc39e9a03b71461f929a9e915d3d7508";
// const token = "006bc39e9a03b71461f929a9e915d3d7508IADoczC8w+KZOEN9GNSpCTF4KkEs7s395sY1hZC7ardQgGvi2G4AAAAAEADC8VeAQUDtYQEAAQBCQO1h";

// class VideoCall extends StatefulWidget {
//   final UserData userfriend;
//   final AppUser? user;
//   const VideoCall({Key? key, required this.userfriend, required this.user}) : super(key: key);

// @override
//   _VideoCallState createState() => _VideoCallState();
// }

// class _VideoCallState extends State<VideoCall>{
//   int? _remoteUid;
//   bool _localUserJoined = false;
//   late RtcEngine _engine;

//   @override
//   void initState() {
//     super.initState();
//     initAgora();
// }
// Future<void> initAgora() async {
//     // retrieve permissions
//     await [Permission.microphone, Permission.camera].request();
//     //create the engine
//     _engine = await RtcEngine.create(appId);
//     await _engine.enableVideo();
//     _engine.setEventHandler(
//       RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//           print("local user $uid joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         userJoined: (int uid, int elapsed) {
//           print("remote user $uid joined");
//           setState(() {
//             _remoteUid = uid;
//           });
//         },
//         userOffline: (int uid, UserOfflineReason reason) {
//           print("remote user $uid left channel");
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//       ),
//     );
//     String channelName = ChatParams(widget.user!.uid, widget.userfriend).getChatGroupId();
//     await _engine.joinChannel(token, channelName, null, 0);
//   }

//   // Create UI with local view and remote view
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Appel Video'),
//       ),
//       body: Stack(
//         children: [
//           Center(
//             child: _remoteVideo(),
//           ),
//           Align(
//             alignment: Alignment.topLeft,
//             child: SizedBox(
//               width: 100,
//               height: 150,
//               child: Center(
//                 child: _localUserJoined
//                   ? const RtcLocalView.SurfaceView()
//                   : const CircularProgressIndicator(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//     }

//   // Display remote user's video
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return RtcRemoteView.SurfaceView(uid: _remoteUid!,
//         channelId: "Genesis"
//       );
//     } else {
//       return const Text(
//         'Attente...',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
//   }