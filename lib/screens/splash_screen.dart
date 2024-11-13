import 'package:flutter/material.dart';
import 'login_signup_screen.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Black Background
          Container(color: Colors.black),

          // First background image with opacity (covering entire scaffold)
          Opacity(
            opacity: 0.5, // Adjust the opacity as needed
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Second background image with rounded corners at the bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              child: Image.asset(
                'assets/images/splash_screen_image.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.6,
              ),
            ),
          ),

          // Center Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 280,
                height: 280,
              ),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'One corner, endless treasures',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'Discover your style today!',
                    style: TextStyle(
                      color: Color(0xFFbee34f),
                      fontSize: 20,
                    ),
                  ),
                ],
              )
            ],
          ),

          // Continue Button at the bottom with padding
          Positioned(
            bottom: 50, // Adjust the bottom padding as needed
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginSignupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  backgroundColor: Color(0xFFbee34f),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // To center the content
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8), // Spacing between text and icon
                    Icon(Icons.arrow_forward), // Icon
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
