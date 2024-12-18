import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftcorner/presentation/screens/Authentication/Register/profile_picture_page.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/models/user_model.dart';
import '../../../widgets/custom_text_field.dart';

class PersonalInfoScreen extends StatefulWidget {
  final String username;
  final String email;
  final String password;

  const PersonalInfoScreen({
    super.key,
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

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        backgroundColor: Color(0xFF121212),
        borderRadius: BorderRadius.circular(48),
        textStyle: TextStyle(color: Colors.white),
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
              Color(0xFF000000),
              Color(0xFFBEE34F),
            ],
            stops: [0.8, 1.0],
            begin: Alignment.topRight,
            end: Alignment(-0.2588, 0.9659),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white.withOpacity(0.375)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(height: 48),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Enter Your Personal Details',
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 40),
              Flexible(
                flex: 6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
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
                        label: 'Phone Number',
                        icon: Icons.phone_outlined,
                      ),
                      SizedBox(height: 20),
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
              Flexible(
                flex: 1,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFBEE34F),
                      borderRadius: BorderRadius.circular(38.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: Offset(4, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePictureScreen(
                              username: widget.username,
                              email: widget.email,
                              password: widget.password,
                              address: _addressController.text,
                              phoneNumber: _phoneNumberController.text,
                              country: _selectedCountry,
                              gender: _gender,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding:
                        EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(38.0),
                        ),
                      ),
                      child: Text(
                        'Next',
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
