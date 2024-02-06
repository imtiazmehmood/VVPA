import 'package:flutter/material.dart';
import 'package:vvplayer/pages/splash.dart';
import 'package:vvplayer/pages/tour.dart';
import 'package:vvplayer/pages/videolist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isIntroShown = prefs.getBool('isIntroShown') ?? false;
  runApp(MyApp(isIntroShown: isIntroShown));
}

class MyApp extends StatelessWidget {
  final bool isIntroShown;

  const MyApp({super.key, required this.isIntroShown});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: AnimatedSplashScreen(
        duration: 3000,
        splash: const Splash(),
        nextScreen: isIntroShown ? const VideoPlayerScreen() : const TourScreen(),
        splashTransition: SplashTransition.scaleTransition,
        backgroundColor: Colors.blue,
      ),
    );
  }
}
