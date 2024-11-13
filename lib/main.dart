import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart'; // Import the Splash Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'ThriftCorner',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        fontFamily: 'Arial',
      ),

      home: SplashScreen(), // Start with the Splash Screen
    );
  }
}
