import 'dart:io';
import 'package:flutter/material.dart';
import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:flutter/services.dart';

class PlayerScreen extends StatefulWidget {
  final String parameter;

  const PlayerScreen({super.key, required this.parameter});

  @override
  PlayerScreenState createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  late CustomVideoPlayerController _customVideoPlayerController;
  String localPath="assets/videos/mob.mp4";
  @override
  void initState() {
    super.initState();
    setPlayerOrientation();
    playVideo(widget.parameter);
  }
  @override
  void dispose() {
    _customVideoPlayerController.dispose();
    super.dispose();
    setAllOrientations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Video Player'),
      // ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width, // Set width to full device width
        height: MediaQuery.of(context).size.height,
        child: CustomVideoPlayer(customVideoPlayerController: _customVideoPlayerController), // Set height to full device height
      ),
    );
  }

  void playVideo(String url) {
    // Implement video playback logic
    File videoFile = File(url);
    late VideoPlayerController videoPlayerController;
    videoPlayerController = VideoPlayerController.file(videoFile)
    //   _videoPlayerController = VideoPlayerController.asset(localPath)
      ..initialize().then((value) {
        // Play the video after initialization
        videoPlayerController.play();
        setState(() {});
      });

    _customVideoPlayerController =
        CustomVideoPlayerController(context: context, videoPlayerController: videoPlayerController);
  }
}

Future setPlayerOrientation() async{
  await SystemChrome.setEnabledSystemUIMode([] as SystemUiMode);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]);
}

Future setAllOrientations() async{
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.values as SystemUiMode);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.values as DeviceOrientation]);
}
