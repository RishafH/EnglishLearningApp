import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  void goToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Master all IELTS skills",
          body: "Practice real-life English—speaking, listening, reading, and writing—all in one place.",
          image: Center(child: Image.asset("assets/images/page1.png", height: 250)),
        ),
        PageViewModel(
          title: "Learn Together, Grow Faster",
          body: "Join live discussions, explore music and stories, and connect with a global community.",
          image: Center(child: Image.asset("assets/images/page2.png", height: 250)),
        ),
        PageViewModel(
          title: "Are you ready to embark on a transformative journey?",
          body: "Sign up and join a global community of learners.",
          image: Center(child: Image.asset("assets/images/page3.png", height: 250)),
        ),
      ],
      onDone: () => goToLogin(context),
      onSkip: () => goToLogin(context),
      showSkipButton: true,
      skip: Text("Skip"),
      next: Text("Next"),
      done: Text("Get Started"),
      dotsDecorator: DotsDecorator(
        size: Size(8, 8),
        activeSize: Size(16, 8),
        activeColor: Colors.teal,
        color: Colors.grey,
        spacing: EdgeInsets.symmetric(horizontal: 4),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
