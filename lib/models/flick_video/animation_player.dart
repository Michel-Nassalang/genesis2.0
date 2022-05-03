import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:genesis/models/flick_video/data_manager.dart';
import 'package:genesis/models/flick_video/landscape_controls.dart';
import 'package:genesis/models/flick_video/portrait_video_controls.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class AnimationPlayer extends StatefulWidget {
  const AnimationPlayer({ Key? key }) : super(key: key);

  @override
  State<AnimationPlayer> createState() => _AnimationPlayerState();
}

class _AnimationPlayerState extends State<AnimationPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FlickManager flickManager;
  late AnimationPlayerDataManager dataManager;
  List items = [
    {
      "title": "Rio from Above",
      "image": "images/rio_from_above_poster.jpg",
      "trailer_url":
          "https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/example/rio_from_above_compressed.mp4?raw=true",
    },
    {
      "title": "The Valley",
      "image": "images/the_valley_poster.jpg",
      "trailer_url":
          "https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/example/the_valley_compressed.mp4?raw=true",
    },
    {
      "title": "Iceland",
      "image": "images/iceland_poster.jpg",
      "trailer_url":
          "https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/example/iceland_compressed.mp4?raw=true",
    },
    {
      "title": "9th May & Fireworks",
      "image": "images/9th_may_poster.jpg",
      "trailer_url":
          "https://github.com/GeekyAnts/flick-video-player-demo-videos/blob/master/example/9th_may_compressed.mp4?raw=true",
    },
  ];
  bool _pauseOnTap = true;
  double playBackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    flickManager = FlickManager(
      videoPlayerController:
          VideoPlayerController.network(items[0]['trailer_url']),
      onVideoEnd: () => dataManager.playNextVideo(
        const Duration(seconds: 5),
      ),
    );

    dataManager = AnimationPlayerDataManager(flickManager, items);
  }

  @override
  void dispose() {
    super.dispose();
    flickManager.dispose();
    _controller.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(flickManager),
      onVisibilityChanged: (visibility) {
        if (visibility.visibleFraction == 0 && this.mounted) {
          flickManager.flickControlManager!.autoPause();
        } else if (visibility.visibleFraction == 1) {
          flickManager.flickControlManager!.autoResume();
        }
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: FlickVideoPlayer(
              flickManager: flickManager,
              flickVideoWithControls: AnimationPlayerPortraitVideoControls(
                  dataManager: dataManager, pauseOnTap: _pauseOnTap),
              flickVideoWithControlsFullscreen: FlickVideoWithControls(
                controls: AnimationPlayerLandscapeControls(
                  animationPlayerDataManager: dataManager,
                ),
              ),
            ),
          ),
          ElevatedButton(
            child: const Text('Next video'),
            onPressed: () => dataManager.playNextVideo(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text('On tap action -- '),
              Row(
                children: <Widget>[
                  GestureDetector(
                      onTap: () {
                        setState(() {
                          _pauseOnTap = true;
                        });
                      },
                      child: const Text('Pause')),
                  Switch(
                    value: !_pauseOnTap,
                    onChanged: (value) {
                      setState(() {
                        _pauseOnTap = !value;
                      });
                    },
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.blue,
                    inactiveTrackColor: Colors.blue[200],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _pauseOnTap = false;
                      });
                    },
                    child: const Text(
                      'Mute',
                    ),
                  )
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              const Text('Playback speed -- '),
              Row(
                children: [
                  Slider(
                    value: playBackSpeed,
                    onChanged: (val) {},
                    onChangeEnd: (val) {
                      flickManager.flickVideoManager?.videoPlayerController!
                          .setPlaybackSpeed(val);
                      setState(() {
                        playBackSpeed = val;
                      });
                    },
                    min: 0.25,
                    max: 2,
                  ),
                  Text(playBackSpeed.toStringAsFixed(2).toString()),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}