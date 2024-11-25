import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../widgets/custom_text_field.dart';
import '../forgot_password_screen.dart';
import '../../home_screen.dart';

class LoginTab extends StatefulWidget {
  @override
  _LoginTabState createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isUsernameEmpty = false;
  bool _isPasswordEmpty = false;

  Future<void> _loginWithUsernamePassword() async {
    setState(() {
      _isUsernameEmpty = _usernameController.text.isEmpty;
      _isPasswordEmpty = _passwordController.text.isEmpty;
    });

    if (_isUsernameEmpty || _isPasswordEmpty) {
      _showErrorDialog("Please fill in both username and password.");
      return;
    }

    try {
      String username = _usernameController.text;
      String password = _passwordController.text;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'No user found with this username');
      }

      String email = snapshot.docs.first['email'];

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Login Failed: ${e.message}");
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return; // User canceled the sign-in process
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } catch (e) {
      _showErrorDialog("Google Sign-In Failed: ${e.toString()}");
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
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Spacer(),
          TextField(
            controller: _usernameController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon:
                  Icon(Icons.account_circle_outlined, color: Colors.white.withOpacity(0.375)),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.375)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                  color: _isUsernameEmpty
                      ? Colors.red
                      : Color(0xFFE5EAFF).withOpacity(0.375),
                ),
                borderRadius: BorderRadius.circular(48),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                  color: _isUsernameEmpty
                      ? Colors.red
                      : Color(0xFFBEE34F).withOpacity(0.375),
                ),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
          ),
          SizedBox(height: 30),
          TextField(
            controller: _passwordController,
            style: TextStyle(color: Colors.white.withOpacity(0.375)),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.375)),
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.375)),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                  color: _isPasswordEmpty
                      ? Colors.red
                      : Color(0xFFE5EAFF).withOpacity(0.375),
                ),
                borderRadius: BorderRadius.circular(48),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                  color: _isPasswordEmpty
                      ? Colors.red
                      : Color(0xFFBEE34F).withOpacity(0.375),
                ),
                borderRadius: BorderRadius.circular(48),
              ),
            ),
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen()),
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Color(0xFF5B95E6)),
              ),
            ),
          ),
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: _loginWithUsernamePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF92AE3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(37),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            ),
            child: Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'or',
            style: TextStyle(color: Color(0xFFB1C378), fontSize: 16),
          ),
          SizedBox(height: 10),
          OutlinedButton(
            onPressed: _loginWithGoogle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFFFFFFFF), width: 2.0),
              // Outline color and width
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(37),
              ),
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login with Google',
                  style: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16),
                ),
                SizedBox(width: 10), // Add spacing between text and icon
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


