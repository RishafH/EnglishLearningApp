import 'package:flutter/material.dart';
import 'package:newone/dashboard.dart';
import 'package:newone/login.dart';
import 'package:newone/onboardingscreen.dart';
import 'package:newone/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<bool> checkOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('seenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Planner',
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: checkOnboardingSeen(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox(); // or splash
          }
          return snapshot.data! ? LoginScreen() : OnboardingScreen();
        },
      ),
      routes: {
        '/login': (_) => LoginScreen(),
        '/register': (_) => HomeDashboard (),
        '/onboarding': (_) => OnboardingScreen(),
        
      },
    );
  }
}
