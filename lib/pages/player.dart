import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class PlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String isNetwork;

  const PlayerScreen({super.key, required this.videoUrl,required this.isNetwork});

  @override
  PlayerScreenState createState() => PlayerScreenState();
}

class PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late VideoPlayerController _urlPlayerController;
  late ChewieController _chewieController;

  // @override
  // void initState() {
  //   super.initState();
  //   setPlayerOrientation();
  //   _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl));
  //   _urlPlayerController = VideoPlayerController.networkUrl(widget.videoUrl as Uri)
  //     ..initialize().then((_) {
  //       setState(() {});
  //     });
  //
  //   _chewieController = ChewieController(
  //     videoPlayerController: _videoPlayerController,
  //     autoPlay: true, // Autoplay the video
  //     looping: true, // Loop the video
  //     autoInitialize: true, // Auto-initialize the video player
  //     // You can customize controls further if needed
  //     // For example, to show volume control and seekbar:
  //     showControls: true,
  //     materialProgressColors: ChewieProgressColors(
  //       playedColor: Colors.red,
  //       handleColor: Colors.blue,
  //       backgroundColor: Colors.grey,
  //       bufferedColor: Colors.lightGreen,
  //     ),
  //   );
  //   _chewieController.play();
  // }

  @override
  void initState() {
    super.initState();
    setPlayerOrientation();

    if (widget.isNetwork == "yes") {
      _urlPlayerController = VideoPlayerController.network(widget.videoUrl)
        ..initialize().then((_) {
          setState(() {});
        });

      _chewieController = ChewieController(
        videoPlayerController: _urlPlayerController,
        autoPlay: true,
        looping: true,
        autoInitialize: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );
      _chewieController.play();
    } else {
      _videoPlayerController = VideoPlayerController.file(File(widget.videoUrl))
        ..initialize().then((_) {
          setState(() {});
        });

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
        autoInitialize: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
      );
      _chewieController.play();
    }
  }


  @override
  void dispose() {
    _videoPlayerController.dispose();
    _urlPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
    setAllOrientations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _chewieController.videoPlayerController.value.isInitialized
            ? Chewie(
          controller: _chewieController,
        )
            : const CircularProgressIndicator(),
      ),
    );
  }

  void setPlayerOrientation() async {
    if (kDebugMode) {
      print(widget.videoUrl);
    }
    await SystemChrome.setEnabledSystemUIMode([] as SystemUiMode);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  void setAllOrientations() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.values as SystemUiMode);
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }
}
