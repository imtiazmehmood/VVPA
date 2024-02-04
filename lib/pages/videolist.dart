import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vvplayer/pages/player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:flutter_storage_path/flutter_storage_path.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  List<Map<String, dynamic>> videos = [];
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  void fetchVideos() async {
    try {
      dynamic videoPaths = await StoragePath.videoPath;

      if (videoPaths is String) {
        List<dynamic> videoPathsList = json.decode(videoPaths);

        setState(() {
          videos = List<Map<String, dynamic>>.from(videoPathsList.map((folder) {
            return {
              'folderName': folder['folderName'],
              'videos': List<Map<String, dynamic>>.from(folder['files']),
            };
          }));
        });

        if (kDebugMode) {
          print("Videos: $videos");
        }
      } else {
        if (kDebugMode) {
          print("Error: videoPaths is not a String");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching videos: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VVPA'),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          String folderName = videos[index]['folderName'];
          List<Map<String, dynamic>> folderVideos = videos[index]['videos'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  folderName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Flex(
              direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
          child: SizedBox(
          height: 75,
          child: FutureBuilder<List<Widget>>(
          future: _buildVideoItems(folderVideos),
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
          return ListView(
          scrollDirection: Axis.horizontal,
          children: snapshot.data!,
          );
          } else {
          return const Center(
          child: CircularProgressIndicator(),
          );
          }
          },
          ),
          ),
          ),
          ],
          ),

          ],
          );
        },
      ),
    );
  }

  Future<List<Widget>> _buildVideoItems(List<Map<String, dynamic>> videos) async {
    List<Widget> videoItems = [];

    for (int videoIndex = 0; videoIndex < videos.length; videoIndex++) {
      String videoPath = videos[videoIndex]['path'];
      File thumbnail = await VideoCompress.getFileThumbnail(videoPath);
      String videoDisplayName = videos[videoIndex]['displayName'];

      videoItems.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlayerScreen(parameter: videoPath),
              ),
            );
          },
          child:Container(
            margin: const EdgeInsets.all(8.0),
            // width: 150, // Increase the width as needed
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    thumbnail,
                    width: 40,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  videoDisplayName,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

        ),
      );
    }

    return videoItems;
  }
}
