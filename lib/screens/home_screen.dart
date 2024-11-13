import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thriftcorner/screens/home_page.dart';
import 'package:thriftcorner/screens/orders_page.dart';
import 'package:thriftcorner/screens/search_page.dart';
import 'package:thriftcorner/screens/add_product_page.dart';
import 'package:thriftcorner/screens/settings_page.dart';

import 'login_signup_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    AddProductPage(),
    OrdersPage(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000000),  // Ensure the scaffold background is black
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: Text(
          "ThriftCorner",
          style: TextStyle(color: Color(0xFFBEE34F)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Color(0xFFBEE34F)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginSignupScreen()),
              );            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: Color(0xFF000000),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          selectedItemColor: Color(0xFFBEE34F),
          unselectedItemColor: Color(0xFF000000),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Product'),
            BottomNavigationBarItem(icon: Icon(Icons.collections), label: 'Collection'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
