import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Home",
          style: TextStyle(
            color: Color(0xFFBEE34F),
            fontSize: 30,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildProfileSection(user),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildUserListSection(),
          ],
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
              user?.photoURL ?? 'https://www.example.com/default-profile-pic.jpg',
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

  Widget _buildUserListSection() {
    // Placeholder list of users and products. Replace with actual data.
    final users = List.generate(5, (index) => 'User $index');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: users.map((user) {
          return _buildUserCard(user);
        }).toList(),
      ),
    );
  }

  Widget _buildUserCard(String username) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                'https://www.example.com/$username-profile-pic.jpg', // Replace with actual URL
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow, size: 14),
                      SizedBox(width: 2),
                      Text('4.5', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      SizedBox(width: 5),
                      Text(' (120 ratings)', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildProductList(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductList() {
    // Placeholder list of products. Replace with actual data.
    final products = List.generate(5, (index) => 'Product $index');

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          return _buildProductCard(products[index], index);
        },
      ),
    );
  }

  Widget _buildProductCard(String title, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using a placeholder image. Replace with actual product image URL.
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
              child: Image.network(
                'https://www.example.com/$title-image.jpg', // Replace with actual product image URL
                height: 100,
                width: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: 120,
                  color: Colors.grey,
                  child: Icon(Icons.image, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('\$20.99', style: TextStyle(color: Colors.white)),
                  Text('Size: M', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
