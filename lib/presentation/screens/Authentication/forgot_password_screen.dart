import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();

  void _resetPassword() async {
    String email = _emailController.text;
    if (email.isEmpty) {
      _showMessageDialog("Please enter an email.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessageDialog("Password reset link sent to $email.");
    } catch (e) {
      _showMessageDialog("Error: ${e.toString()}");
    }
  }

  void _showMessageDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification', style: TextStyle(color: Color(0xFFBEE34F))),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color(0xFFBEE34F))),
            ),
          ],
          backgroundColor: Color(0xFF333333),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF000000),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Return to the login screen
          },
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF000000), // Black color
                    Color(0xFFBEE34F), // Lime green color
                  ],
                  stops: [0.8, 1.0],
                  begin: Alignment.topRight,
                  end: Alignment(-0.2588, 0.9659), // -75 degrees angle
                ),
              ),
            ),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Image.asset('assets/icons/lock.png'),
                  ),
                  CustomTextField(controller: _emailController, label: 'Email', icon: Icons.email_outlined, obscureText: false),

                  SizedBox(height: 16),
                  Text(
                    'Please enter your email account to send the link verification to reset your password.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  SizedBox(height: 40),
                  Center(
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF92AE3D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(37),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      ),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
