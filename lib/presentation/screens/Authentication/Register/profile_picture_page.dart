import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../domain/models/user_model.dart';
import '../../home_screen.dart';

class ProfilePictureScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;
  final String address;
  final String phoneNumber;
  final String? country;
  final String? gender;

  const ProfilePictureScreen({
    Key? key,
    required this.username,
    required this.email,
    required this.password,
    required this.address,
    required this.phoneNumber,
    this.country,
    this.gender,
  }) : super(key: key);

  @override
  _ProfilePictureScreenState createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _imageFile;
  bool _isUploading = false;

  final FirebaseAuthService authService = FirebaseAuthService(
    FirebaseAuth.instance,
    UserRepository(FirebaseFirestore.instance),
  );

  // Cloudinary API setup
  final String cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/dc3luq18s/image/upload';
  final String uploadPreset = 'profile_pictures';

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      _showErrorDialog("Please select an image first.");
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image to Cloudinary
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files
          .add(await http.MultipartFile.fromPath('file', _imageFile!.path));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);
        final imageUrl = jsonResponse['secure_url'];

        // Create user after image upload
        UserModel? user = await authService.signUp(widget.email, widget.password, {
          'username': widget.username,
          'address': widget.address,
          'country': widget.country,
          'phoneNumber': widget.phoneNumber,
          'gender': widget.gender,
          'profileImage': imageUrl,
        });

        print(user);

        if (user != null) {
          // Navigate to Home Screen after successful user creation
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          _showErrorDialog("Account creation failed. Please try again.");
        }
      } else {
        _showErrorDialog("Failed to upload image. Please try again.");
      }
    } catch (e) {
      _showErrorDialog("Failed to upload image. Please try again.");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.0, color: Color(0xFFE5EAFF).withOpacity(0.375)),
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Error', style: TextStyle(color: Colors.white.withOpacity(0.375))),
        content: Text(message, style: TextStyle(color: Colors.white.withOpacity(0.375))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF000000), Color(0xFFBEE34F)],
              stops: [0.8, 1.0],
              begin: Alignment.topRight,
              end: Alignment(-0.2588, 0.9659),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Text(
                    'Add Profile Picture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SizedBox(height: 80),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileImage(),
                        SizedBox(height: 32),
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 202,
              height: 202,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFAEAEAE).withOpacity(0.5),
                    Color(0xFF484848).withOpacity(0.5),
                  ],
                  begin: Alignment(-0.7, 1),
                  end: Alignment(1, -0.7),
                ),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.375)),
              ),
              child: _imageFile == null
                  ? Center(
                child: Text(
                  'Tap to add image',
                  style:
                  TextStyle(color: Colors.white.withOpacity(0.375)),
                ),
              )
                  : ClipOval(
                child: Image.file(
                  _imageFile!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: _isUploading
          ? CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBEE34F)),
      )
          : ElevatedButton(
        onPressed: _uploadImage,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
          backgroundColor: Color(0xFFBEE34F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(38.0),
          ),
        ),
        child: Text(
          'Create Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
