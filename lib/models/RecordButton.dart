import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:avatar_glow/avatar_glow.dart';

typedef RecordCallback = void Function(String);

class RecordButton extends StatefulWidget {
  const RecordButton({
    Key? key,
    required this.recordingFinishedCallback,
  }) : super(key: key);

  final RecordCallback recordingFinishedCallback;

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  bool _isRecording = false;
  final _audioRecorder = Record();

  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start();

        bool isRecording = await _audioRecorder.isRecording();
        setState(() {
          _isRecording = isRecording;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();

    widget.recordingFinishedCallback(path!);

    setState(() => _isRecording = false);
  }

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color? color;
    if (_isRecording) {
      icon = Icons.mic_none_outlined;
      color = Colors.green.withOpacity(0.5);
    } else {
      color = Colors.grey[600];
      icon = Icons.mic;
    }
    return GestureDetector(
        onTap: () {
          _isRecording ? _stop() : _start();
        },
        child: SizedBox(
          width:  _isRecording ? 80 : 30,
          height: _isRecording ? 80 : 30,
          child: AvatarGlow(
              animate: _isRecording,
              endRadius: 5.0,
              glowColor: Colors.blue,
              duration: const Duration(milliseconds: 2000),
              repeatPauseDuration: const Duration(milliseconds: 100),
              repeat: true,
              child: Icon(icon, color: color)),
        )
        );
  }
}
