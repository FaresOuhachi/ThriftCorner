import 'package:flutter/material.dart';
import 'Login/login_tab.dart';
import 'Register/signup_tab.dart';

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF000000), // Black color in hex
                  Color(0xFFBEE34F), // Lime green color in hex
                ],
                stops: [0.8, 1.0],
                // Black stops at 80%, lime green starts after
                begin: Alignment.topRight,
                end: Alignment(-0.2588, 0.9659), // Adjusted for -75 degrees
              ),
            ),
          ),
          // Main Content
          Column(
            children: [
              SizedBox(height: 100),
              // Tabs
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Color(0xFF262626).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    indicator: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD6F7D8).withOpacity(0.3), Color(0xFFFFFFFF).withOpacity(0.3)],
                        begin: Alignment(-1.5, -1.5),
                        end: Alignment(1.5, 1.5),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Color(0x66FFFFFF),
                    tabs: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Tab(text: 'Login'),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Tab(text: 'Sign Up'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    LoginTab(),
                    SignUpTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
