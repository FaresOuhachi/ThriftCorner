import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:thriftcorner/screens/signup_tab.dart';

import 'login_tab.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Controllers for Login and Sign Up fields
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupUsernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Google Sign-In Logic
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // User canceled sign-in
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      // Navigate to Home Screen
    } catch (e) {
      print("Google Sign-In Error: $e");
    }
  }

  // Forgot Password Logic
  Future<void> _resetPassword() async {
    if (_loginEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter your email to reset password."),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _loginEmailController.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Password reset email sent."),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("Forgot Password Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF000000), // Black color in hex
                  Color(0xFFBEE34F), // Lime green color in hex
                ],
                stops: [0.8, 1.0],
                // Black stops at 80%, lime green starts after
                begin: Alignment.topRight,
                end: Alignment(-0.2588, 0.9659), // Adjusted for -75 degrees
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              SizedBox(height: 100),
              // Tabs
              Center(
                child: Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.5,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Login'),
                      Tab(text: 'Sign Up'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LoginTab(),
                    SignUpTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}