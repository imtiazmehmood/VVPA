import 'package:flutter/material.dart';
class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  // @override
  // void initState() {
  //   super.initState();
  //   navigateToHome();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.blue,
      child: const SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Virtual Video Player Application',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

// void navigateToHome() async {
  //   await Future.delayed(const Duration(milliseconds: 1500));
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(builder: (context) => VideoPlayerScreen()),
  //   );
  // }
}
