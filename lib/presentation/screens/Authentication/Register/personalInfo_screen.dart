import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../domain/models/user_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../home_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;


  PersonalInfoScreen({
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  _PersonalInfoScreenState createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  String? _selectedCountry;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? _gender;

  Future<void> _createAccount() async {
    if (_selectedCountry == null ||
        _addressController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _gender == null) {
      _showErrorDialog("Please fill in all fields.");
      return;
    }


    try {
      UserModel user = signUp(widget.email, widget.password, {
        'username': widget.username,
        'address': _addressController.text,
        'country': _selectedCountry,
        'phoneNumber': _phoneNumberController.text,)
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Account Creation Failed: ${e.message}");
    }


    try {
      // Create the user in Firebase Authentication
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Get the user ID (UID)
      String userId = userCredential.user!.uid;

      // Create a UserModel instance
      UserModel user = UserModel(
        id: userId,
        username: widget.username,
        email: widget.email,
        address: _addressController.text, // User's address
        country: _selectedCountry!, // Selected country
        phoneNumber: _phoneNumberController.text, // User's phoneNumber number
        gender: _gender!, // User's gender
        reviews: [], // Starting with an empty list of reviews
        createdAt: DateTime.now(),
      );

      // Save the user to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set(user.toMap());

      // Navigate to the HomeScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      _showErrorDialog("Account Creation Failed: ${e.message}");
    }
  }



  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true, // Optional
      countryListTheme: CountryListThemeData(
        backgroundColor: Color(0xFF121212), // Dark background
        borderRadius: BorderRadius.circular(48), // Rounded corners
        textStyle: TextStyle(color: Colors.white), // Text color
        inputDecoration: InputDecoration(
          hintText: 'Search Country',
          hintStyle: TextStyle(color: Color(0xFFBEE34F)),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.displayNameNoCountryCode;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF000000), // Black color
              Color(0xFFBEE34F), // Lime green color
            ],
            stops: [0.8, 1.0],
            begin: Alignment.topRight,
            end: Alignment(-0.2588, 0.9659), // Adjusted for -75 degrees
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // First Section: Back Arrow and Text
              Flexible(
                flex: 3, // Ratio: 2
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back arrow
                    IconButton(
                      icon: Icon(Icons.arrow_back,
                          color: Colors.white.withOpacity(0.375)),
                      onPressed: () {
                        Navigator.pop(context); // Returns to the Sign-Up Tab
                      },
                    ),
                    SizedBox(height: 48),
                    // Header Text
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Enter Your Personal Details',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              // Second Section: Forms
              Flexible(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      // Country Picker
                      GestureDetector(
                        onTap: _showCountryPicker,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.375),
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(48),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.emoji_flags_outlined,
                                  color: Colors.white.withOpacity(0.375)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedCountry ?? 'Select Country',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: _selectedCountry == null
                                        ? Colors.white.withOpacity(0.375)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                      ),
                      SizedBox(height: 20),
                      CustomTextField(
                        controller: _phoneNumberController,
                        label: 'phoneNumber Number',
                        icon: Icons.phone_outlined,
                      ),
                      SizedBox(height: 20),
                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        value: _gender,
                        hint: Text(
                          'Select Gender',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.375)),
                        ),
                        items: ['Male', 'Female']
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(
                                    gender,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                        dropdownColor: Color(0xFF121212),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          labelStyle:
                              TextStyle(color: Colors.white.withOpacity(0.75)),
                          prefixIcon: Icon(Icons.person_2_outlined,
                              color: Colors.white.withOpacity(0.375)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.375),
                                width: 1.0),
                            borderRadius: BorderRadius.circular(48),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFFBEE34F), width: 2.0),
                            borderRadius: BorderRadius.circular(48),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Spacer(),
              // Third Section: Button
              Flexible(
                flex: 1, // Ratio: 1
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFBEE34F), // Same as button background color
                      borderRadius: BorderRadius.circular(38.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3), // Shadow color with opacity
                          spreadRadius: 2, // Spread radius
                          blurRadius: 8, // Blur radius
                          offset: Offset(4, 4), // Offset in x and y directions
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // Prevents overriding the container's color
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shadowColor: Colors.transparent, // Disable default ElevatedButton shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38.0), // Match the container's border radius
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
