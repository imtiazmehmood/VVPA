import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vvplayer/pages/player.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_manager/file_manager.dart';
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  List videos = [];
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    fetchVideos();
    Permission.storage.request();
  }

  Future<void> fetchVideos() async {
    List<Directory> directories = await FileManager.getStorageList();
    List<Map<String, dynamic>> allVideos = [];

    for (Directory directory in directories) {
      List<FileSystemEntity> entities = directory.listSync(recursive: true);

      // Filter entities to only include directories
      List<Directory> subDirectories = entities.whereType<Directory>().toList();

      // Check if any subdirectory contains video files
      for (Directory subDir in subDirectories) {
        List<FileSystemEntity> files = subDir.listSync();
        if (files.any((file) => file is File && file.path.toLowerCase().endsWith('.mp4'))) {
          String folderName = subDir.path;
          List<File> videos = files.whereType<File>().toList();
          Map<String, dynamic> folderData = {
            'folderName': folderName.split('/').last,
            'videos': videos,
          };
          if (kDebugMode) {
            print("folderData $folderData");
          }
          allVideos.add(folderData);
        }
      }
    }

    setState(() {
      videos.clear();
      videos.addAll(allVideos);
    });
  }

  Future<void> _deleteVideo(String videoPath) async {
    try {
      final file = File(videoPath);
       file.deleteSync();
       fetchVideos();
    } catch (e) {
      if (kDebugMode) {
        print("ERROR:$e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VVPA'),
      ),
      body:
      ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          String folderName = videos[index]['folderName'];
          List<File> folderVideos = videos[index]['videos'];

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
              ListView.builder(
                shrinkWrap: true, // Ensure the ListView only occupies the space it needs
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling of inner ListView
                itemCount: folderVideos.length,
                itemBuilder: (context, videoIndex) {
                  File videoFile = folderVideos[videoIndex];
                  return FutureBuilder<Widget>(
                    future: _buildVideoItem(videoFile),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      } else {
                        return const SizedBox(
                          width: 100,
                          child: Center(
                            child: Column(),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ],
          );
        },
      ),




    );
  }

  Future<Widget> _buildVideoItem(File videoFile) async { // Update parameter type
    String videoPath = videoFile.path; // Access file path
    File thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    String videoDisplayName = videoPath.split('/').last;
if(kDebugMode){
  print('videoDisplayName $videoDisplayName');
}
    return
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(parameter: videoPath),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.all(8.0),
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Conditionally show thumbnail
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
                      videoDisplayName ?? 'Unnamed Video',
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String choice) async {
                  // Handle menu item selection
                  if (choice == 'delete') {
                    // Check if videoPath is not null before deleting
                    if (videoPath.isNotEmpty) {
                      await _deleteVideo( videoPath);
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );

  }

}
