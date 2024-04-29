import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vvplayer/pages/videolist.dart';

class TourScreen extends StatefulWidget {
  const TourScreen();

  @override
  _TourScreenState createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<TourStep> tourSteps = [
    TourStep(
      title: "Welcome to Virtual Video Player Application",
      description: "Discover the amazing features of our video player.",
      image: Icons.play_circle_filled,
    ),
    TourStep(
      title: "Play/Pause",
      description: "Tap the play/pause button to start or pause the video.",
      image: Icons.play_arrow,
    ),
    TourStep(
      title: "Full Screen",
      description: "Expand your view by tapping the full-screen button.",
      image: Icons.fullscreen,
    ),
    TourStep(
      title: "Playback Speed",
      description: "Adjust the playback speed for a personalized experience.",
      image: Icons.speed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: tourSteps.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return TourStepWidget(tourStep: tourSteps[index]);
            },
          ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPageIndicator(),
            ),
          ),
          Positioned(
            bottom: 10.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: () async {
                if (_currentPage == tourSteps.length - 1) {

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  prefs.setBool('isIntroShown', true).then((value) => Navigator.of(context).pushReplacement(MaterialPageRoute(
                     builder: (context) => const VideoPlayerScreen(),
                   )));

                  // If on the last page, navigate to the home screen
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //   builder: (context) => const VideoPlayerScreen(),
                  // ));

                  } else {
                  // Otherwise, move to the next page
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text(_currentPage == tourSteps.length - 1 ? "Finish" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < tourSteps.length; i++) {
      indicators.add(_indicator(i == _currentPage));
    }
    return indicators;
  }

  Widget _indicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData image;

  TourStep({
    required this.title,
    required this.description,
    required this.image,
  });
}

class TourStepWidget extends StatelessWidget {
  final TourStep tourStep;

  const TourStepWidget({required this.tourStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(tourStep.image, size: 120.0, color: Colors.blue),
          const SizedBox(height: 16.0),
          Text(
            textAlign: TextAlign.center,
            tourStep.title,
            style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Text(
            tourStep.description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
