import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;

  const CustomTextField({super.key, 
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.white),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.375)),
        //reduce opacity to icon  and label
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.375)),
        enabledBorder: OutlineInputBorder(
          borderSide:
          BorderSide(width: 1.0, color: Color(0xFFE5EAFF).withOpacity(0.375)),
          borderRadius: BorderRadius.circular(48),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
          BorderSide(width: 2.0, color: Color(0xFFBEE34F).withOpacity(0.375)),
          borderRadius: BorderRadius.circular(48),
        ),
      ),
    );
  }
}
