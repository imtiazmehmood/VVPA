import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vvplayer/pages/player.dart';
import 'package:vvplayer/pages/favorite.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_manager/file_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  VideoPlayerScreenState createState() => VideoPlayerScreenState();
}

class VideoPlayerScreenState extends State<VideoPlayerScreen> {
  List<Map<String, dynamic>> videos = [];
  List<Map<String, dynamic>> firebaseVideos = [];

  late final ValueNotifier<String> _videoUrl = ValueNotifier<String>('');
  late List<List<ValueNotifier<bool>>> _isFavoriteLists = [];

  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
     WidgetsFlutterBinding.ensureInitialized();
     Firebase.initializeApp();
      fetchVideos();
      Permission.storage.request();
  }

  Future<void> fetchVideos() async {
    List<Directory> directories = await FileManager.getStorageList();
    List<Map<String, dynamic>> allVideos = [];
    List<Map<String, dynamic>> allFirebaseVideos = [];

    for (Directory directory in directories) {
      List<FileSystemEntity> entities = directory.listSync(recursive: true);

      // Filter entities to only include directories
      List<Directory> subDirectories = entities.whereType<Directory>().toList();

      // Check if any subdirectory contains video files
      for (Directory subDir in subDirectories) {
        List<FileSystemEntity> files = subDir.listSync();
        List<File> videos = _getVideoFiles(files);
        if (videos.isNotEmpty) {
          String folderName = subDir.path.split('/').last;
          Map<String, dynamic> folderData = {
            'folderName': folderName,
            'videos': videos,
          };
          if (kDebugMode) {
            print("All Dirs $folderData");
          }
          allVideos.add(folderData);
        }
      }
    }

    setState(() {
      videos.clear();
      videos.addAll(allVideos);
      _isFavoriteLists = List.generate(allVideos.length, (index) {
        return List.generate(allVideos[index]['videos'].length, (_) => ValueNotifier<bool>(false));
      });
    });
  }

  List<File> _getVideoFiles(List<FileSystemEntity> files) {
    return files.whereType<File>().where(_isVideoFile).toList();
  }

  bool _isVideoFile(FileSystemEntity file) {
    if (file is File) {
      String extension = file.path.toLowerCase();
      return extension.endsWith('.mp4') ||
          extension.endsWith('.avi') ||
          extension.endsWith('.mov') ||
          extension.endsWith('.wmv') ||
          extension.endsWith('.mkv') ||
          extension.endsWith('.3gp');

    }
    return false;
  }

  Future<void> _deleteVideo(String videoPath) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("videos")
          .where('path', isEqualTo: videoPath)
          .get();

      if (querySnapshot.docs.length == 1) {
        String docId = querySnapshot.docs[0].id;

        await FirebaseFirestore.instance.collection("videos").doc(docId).delete();
      }
      final file = File(videoPath);
      file.deleteSync();

      setState(() {
        for (var folder in videos) {
          folder['videos'].removeWhere((videoFile) => videoFile.path == videoPath);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("ERROR: $e");
      }
    }
  }

  Future<void> _playFromUrl(String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(videoUrl: url, isNetwork: "yes"),
      ),
    );
  }

  void _showVideoUrlDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Video URL'),
          content: TextField(
            // controller: _urlController,
            decoration: const InputDecoration(hintText: 'Enter URL'),
            onChanged: (value) {
              _videoUrl.value = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _playFromUrl(_videoUrl.value);
              },
              child: const Text('Play'),
            ),
          ],
        );
      },
    );
  }

  void _goToFavorite(){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoriteScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VVPA'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              _showVideoUrlDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_sharp),
            onPressed: () {
              _goToFavorite();
            },
          ),
        ],
      ),
      body: ListView.builder(
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
                    future: _buildVideoItem(videoFile, index, videoIndex),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data!;
                      } else {
                        return const SizedBox(
                          width: 100,
                          child: Center(),
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

  Future<Widget> _buildVideoItem(File videoFile, int folderIndex, int videoIndex) async {
    String videoPath = videoFile.path;
    File thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    String videoDisplayName = videoPath.split('/').last;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlayerScreen(videoUrl: videoPath, isNetwork: "not"),
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
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                bool isFavorite = !_isFavoriteLists[folderIndex][videoIndex].value;

                _isFavoriteLists[folderIndex][videoIndex].value = isFavorite;

                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection("videos")
                    .where('path', isEqualTo: videoPath)
                    .get();

                if (querySnapshot.docs.length == 1) {
                  String docId = querySnapshot.docs[0].id;

                  await FirebaseFirestore.instance.collection("videos").doc(docId).set({
                    'name': videoDisplayName,
                    'path': videoPath,
                    'thumbnail': thumbnail.path,
                    'isFavorite': isFavorite,
                  });
                } else if (querySnapshot.docs.isEmpty) {
                  await FirebaseFirestore.instance.collection("videos").add({
                    'name': videoDisplayName,
                    'path': videoPath,
                    'thumbnail': thumbnail.path,
                    'isFavorite': isFavorite,
                  });
                } else {
                  if (kDebugMode) {
                    print('Multiple documents found with path: $videoPath');
                  }
                }
              },
              icon: ValueListenableBuilder<bool>(
                valueListenable: _isFavoriteLists[folderIndex][videoIndex],
                builder: (context, isFavourite, _) {
                  return Icon(
                    isFavourite ? Icons.favorite : Icons.favorite_border,
                  );
                },
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (String choice) async {
                if (choice == 'delete') {
                  if (videoPath.isNotEmpty) {
                    await _deleteVideo(videoPath);
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
