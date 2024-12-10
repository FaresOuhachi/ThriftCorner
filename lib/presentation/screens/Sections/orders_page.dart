import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class OrdersPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, String>> orders = [
    {
      'user_name': 'John Doe',
      'product_name': 'Laptop',
      'time': '10:30 AM',
      'profile_pic':
      'https://www.example.com/user1-profile-pic.jpg', // Example profile picture URL
    },
    {
      'user_name': 'Jane Smith',
      'product_name': 'Headphones',
      'time': '11:15 AM',
      'profile_pic':
      'https://www.example.com/user2-profile-pic.jpg', // Example profile picture URL
    },
    {
      'user_name': 'Alice Johnson',
      'product_name': 'Smartphone',
      'time': '1:00 PM',
      'profile_pic':
      'https://www.example.com/user3-profile-pic.jpg', // Example profile picture URL
    },
  ];

  OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            _buildProfileSection(user),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title styling like Add Product Page
              Text(
                'Orders',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return OrderItemWidget(
                            userName: order['user_name']!,
                            productName: order['product_name']!,
                            time: order['time']!,
                            profilePicUrl: order['profile_pic']!,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(User? user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              user?.photoURL ??
                  'https://www.example.com/default-profile-pic.jpg',
            ),
          ),
          SizedBox(width: 10),
          Text(
            user?.displayName ?? 'Username',
            style: TextStyle(
              color: Color(0xFFBEE34F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}


class OrderItemWidget extends StatelessWidget {
  final String userName;
  final String productName;
  final String time;
  final String profilePicUrl;

  const OrderItemWidget({
    super.key,
    required this.userName,
    required this.productName,
    required this.time,
    required this.profilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.white.withOpacity(0.5),
          thickness: 0.5,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(profilePicUrl),
                backgroundColor: Colors.grey, // Fallback color if image fails
              ),
              SizedBox(width: 12),
              // Notification Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: userName,
                            style: TextStyle(
                              color: Color(0xFFBEE34F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " purchased ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: productName,
                            style: TextStyle(
                              color: Color(0xFFBEE34F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: " from you!!",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              // Expand Arrow
              Transform.rotate(
                angle: -math.pi / 2,
                child: Icon(
                  Icons.expand_more,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.white.withOpacity(0.5),
          thickness: 0.5,
        ),
      ],
    );
  }
}
