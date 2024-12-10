import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'Sections/add_product_page.dart';
import 'Sections/home_page.dart';
import 'Sections/orders_page.dart';
import 'Sections/search_page.dart';
import 'Sections/settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  final List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    AddProductPage(),
    OrdersPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed the AppBar and body content from HomeScreen
      backgroundColor: Colors.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        height: 50.0,
        backgroundColor: Colors.transparent,
        color: Colors.black,
        items: _navBarItems(),
        onTap: _onTabTapped,
        index: _currentIndex,
        animationDuration: Duration(milliseconds: 250),
        animationCurve: Curves.easeInOut,
      ),
    );
  }

  List<Widget> _navBarItems() {
    return [
      _buildNavItem('assets/icons/Home.svg', 0),
      _buildNavItem('assets/icons/Search.svg', 1),
      _buildNavItem('assets/icons/Add.svg', 2),
      _buildNavItem('assets/icons/Notif.svg', 3),
      _buildNavItem('assets/icons/Settings.svg', 4),
    ];
  }

  Widget _buildNavItem(String iconPath, int index) {
    return SizedBox(
      width: 30.0,
      height: 30.0,
      child: SvgPicture.asset(
        iconPath,
        colorFilter: ColorFilter.mode(
          _currentIndex == index ? Color(0xFFBEE34F) : Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
