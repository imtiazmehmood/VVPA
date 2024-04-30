import 'dart:io';
import 'package:flutter/material.dart';
import 'package:vvplayer/pages/player.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(
    home: FavoriteScreen(),
  ));
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Videos',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('videos')
            .where('isFavorite', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          List<QueryDocumentSnapshot> documents = snapshot.data!.docs;

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final videoSnapshot = documents[index];
              final videoPath = videoSnapshot['path'];
              final thumbnailPath = videoSnapshot['thumbnail'];
              final videoDisplayName = videoSnapshot['name'];

              if (videoPath != null && videoPath.isNotEmpty && videoSnapshot['isFavorite'] == true) {
                // Check if the file exists in internal storage
                File videoFile = File(videoPath);
                if (videoFile.existsSync()) {
                  return _buildVideoItem(videoSnapshot);
                }
              }

              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  Future<void> _playFromUrl(String url) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(videoUrl: url, isNetwork: "not"),
      ),
    );
  }

  Widget _buildVideoItem(QueryDocumentSnapshot videoSnapshot) {
    String videoPath = videoSnapshot['path'];
    String thumbnailPath = videoSnapshot['thumbnail'];
    String videoDisplayName = videoSnapshot['name'];

    return GestureDetector(
      onTap: () async {
        await _playFromUrl(videoPath);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Display thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(thumbnailPath), // Convert thumbnailPath to File
                  width: 40,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16.0),
              // Display video display name
              Expanded(
                child: Text(
                  videoDisplayName,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
              // Add favorite icon here
              // IconButton(
              //   icon: const Icon(Icons.favorite),
              //   onPressed: () async {
              //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              //         .collection("videos")
              //         .where('path', isEqualTo: videoPath)
              //         .get();
              //
              //     if (querySnapshot.docs.length == 1) {
              //       // Get the document ID
              //       String docId = querySnapshot.docs[0].id;
              //
              //       // Update the document with the found docId
              //       await FirebaseFirestore.instance.collection("videos").doc(docId).update({
              //         'isFavorite': false, // Update the isFavorite field
              //       });
              //     } else {
              //       if (kDebugMode) {
              //         print('Document not found for path: $videoPath');
              //       }
              //     }
              //
              //     // Refresh the screen by rebuilding the widget
              //     setState(() {});
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
