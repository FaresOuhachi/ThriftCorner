import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:thriftcorner/data/repositories/wishlist_repository.dart';
import 'package:thriftcorner/presentation/screens/Sections/wishlists_page.dart';

import 'Sections/add_product_page.dart';
import 'Sections/home/home_page.dart';
import 'Sections/orders/orders_page.dart';
import 'Sections/search_page.dart';
import 'Sections/profile/my_profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../domain/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final FirebaseAuthService authService = FirebaseAuthService(
    FirebaseAuth.instance,
    UserRepository(FirebaseFirestore.instance),
  );

  final WishlistRepository wishlistRepository =
  WishlistRepository(FirebaseFirestore.instance);

  final List<Widget> _screens = [
    HomePage(),
    SearchPage(),
    AddProductPage(),
    OrdersPage(),
    MyProfilePage(),
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
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.0),
        child: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          elevation: 0,
          flexibleSpace: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: FutureBuilder<UserModel?>(
                future: authService.getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFBEE34F),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white),
                    );
                  } else if (!snapshot.hasData) {
                    return Text(
                      'No user logged in',
                      style: TextStyle(color: Colors.white),
                    );
                  }

                  UserModel? user = snapshot.data;
                  return _buildProfileSection(user);
                },
              ),
            ),
          ),
        ),
      ),
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
      _buildNavItem('assets/icons/avatar.svg', 4),
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

  Widget _buildProfileSection(UserModel? user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          user?.username ?? 'Username', // Fallback if username is null
          style: TextStyle(
            color: Color(0xFFBEE34F),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        SizedBox(width: 8),
        ClipOval(
          child: Image.network(
            user?.profileImage ??
                'https://res.cloudinary.com/dc3luq18s/image/upload/v1733842092/images/icons8-avatar-96_epem6m',
            width: 35, // Width of the image
            height: 35, // Height of the image
            fit: BoxFit.cover, // Ensures the image covers the space
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.person, // Default fallback icon if image fails to load
                color: Colors.grey,
                size: 35,
              );
            },
          ),
        ),
        SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WishlistPage(
                    userId: user!.id,
                    wishlistRepository: wishlistRepository,
                  )),
            );
          },
          child: Image.asset(
            "assets/icons/Cintre.png", // Path to your PNG file
            width: 30, // Adjust the width of the PNG
            height: 30, // Adjust the height of the PNG
          ),
        ),
        SizedBox(width: 24),
      ],
    );
  }
}
