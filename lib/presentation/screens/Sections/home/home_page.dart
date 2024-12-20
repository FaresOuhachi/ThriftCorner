import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thriftcorner/presentation/screens/Sections/home/product_page.dart';

import '../../../../data/repositories/user_repository.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/models/user_model.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuthService authService = FirebaseAuthService(
    FirebaseAuth.instance,
    UserRepository(FirebaseFirestore.instance),
  );

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed "Home" Text
          Padding(
            padding:
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Text(
              "Home",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
          ),
          // Scrollable List of Users
          Expanded(
            child: FutureBuilder<UserModel?>(  // Fetch current user details
              future: authService.getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData) {
                  return const Center(
                    child: Text(
                      "No user found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final currentUserId = userSnapshot.data!.id;
                return _buildUserListSection(currentUserId);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListSection(String currentUserId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
      child: StreamBuilder<QuerySnapshot>( // Listen for real-time updates of users
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final users = userSnapshot.data!.docs;

          return FutureBuilder<List<QueryDocumentSnapshot>>(
            future: _filterUsersWithProducts(users, currentUserId),
            builder: (context, filteredUserSnapshot) {
              if (filteredUserSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!filteredUserSnapshot.hasData || filteredUserSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    "No users with products found",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              final filteredUsers = filteredUserSnapshot.data!;
              return ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index].data() as Map<String, dynamic>;
                  return _buildUserCard(user['username'], user['id'], user['profileImage']);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> _filterUsersWithProducts(List<QueryDocumentSnapshot> users, String currentUserId) async {
    final List<QueryDocumentSnapshot> filteredUsers = [];

    for (var user in users) {
      final userId = user.get('id');
      if (userId == currentUserId) continue; // Exclude current user

      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .where('isSold', isEqualTo: false)
          .limit(1) // Only check if at least one product exists
          .get();

      if (productSnapshot.docs.isNotEmpty) {
        filteredUsers.add(user);
      }
    }

    return filteredUsers;
  }

  Widget _buildUserCard(String username, String userId, String? profileImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.network(
                profileImage ?? 'https://res.cloudinary.com/dc3luq18s/image/upload/v1733842092/images/icons8-avatar-96_epem6m',
                width: 25,
                height: 25,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.person,
                  color: Colors.grey,
                  size: 25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                username,
                style: const TextStyle(
                  color: Color(0xFFBEE34F),
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildProductList(userId), // Display products available from the user
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildProductList(String userId) {
    return StreamBuilder<QuerySnapshot>( // Listen for real-time product updates
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .where('isSold', isEqualTo: false)
          .snapshots(),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No products available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final products = productSnapshot.data!.docs;

        return SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(productId: products[index].id),
                  ),
                ),
                child: _buildProductCard(product),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              product['images'][0] ?? 'https://res.cloudinary.com/dc3luq18s/image/upload/v1/default-product.jpg',
              height: 124,
              width: 112,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 124,
                width: 112,
                color: Colors.grey.withOpacity(.5),
                child: Icon(Icons.image, color: Colors.white.withOpacity(.5)),
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['title'] ?? 'Unknown Product',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Size: ${product['size'] ?? 'N/A'}',
                      style: TextStyle(
                        color: const Color(0xFFD4D4D4).withOpacity(.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      // Check if the price is a double and convert it to an integer
                      '${(product['price'] is double ? (product['price'] as double).toInt() : product['price']) ?? 'N/A'} DZD',
                      style: const TextStyle(
                        color: Color(0xFF7D9349),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
