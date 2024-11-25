import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../widgets/custom_text_field.dart';
import '../../home_screen.dart';
import 'personalInfo_screen.dart';

class SignUpTab extends StatefulWidget {
  @override
  _SignUpTabState createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _signUpWithEmailPassword() async {
    // Check for empty fields
    if (_usernameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }

    // Validate email format
    final emailPattern =
        r'^[a-zA-Z0-9.a-zA-Z0-9.!#$%&\*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
    if (!RegExp(emailPattern).hasMatch(_emailController.text)) {
      _showErrorDialog("Please enter a valid email address.");
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog("Passwords do not match.");
      return;
    }

    // Check if username or email already exists
    var usernameSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: _usernameController.text)
        .get();
    if (usernameSnapshot.docs.isNotEmpty) {
      _showErrorDialog("Username already exists.");
      return;
    }

    var emailSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: _emailController.text)
        .get();
    if (emailSnapshot.docs.isNotEmpty) {
      _showErrorDialog("Email already registered.");
      return;
    }

    // Navigate to the additional information screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoScreen(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      ),
    );
  }

  Future<void> _signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user already exists in Firestore
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (!userDoc.exists) {
        // Add user to Firestore if new
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': googleUser.displayName ?? "User",
          'email': googleUser.email,
        });
      }

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      _showErrorDialog("Google Sign-Up Failed: ${e.toString()}");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(color: Color(0xFFBEE34F))),
          content: Text(message, style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Color(0xFFBEE34F))),
            ),
          ],
          backgroundColor: Color(0xFF000000),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Sign up',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Spacer(),
          CustomTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.account_circle_outlined,
              obscureText: false),
          SizedBox(height: 20),
          CustomTextField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              obscureText: false),
          SizedBox(height: 20),
          CustomTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outline,
              obscureText: true),
          SizedBox(height: 20),
          CustomTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: _signUpWithEmailPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF92AE3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(37),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            ),
            child: Text('Sign Up',
                style: TextStyle(color: Colors.white, fontSize: 20)),
          ),
          SizedBox(height: 10),
          Text(
            'or',
            style: TextStyle(color: Color(0xFFB1C378), fontSize: 16),
          ),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: _signUpWithGoogle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(37),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sign-up with Google',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18),
                ),
                SizedBox(width: 10),
                Image.asset('assets/icons/google.png', height: 24),
              ],
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
