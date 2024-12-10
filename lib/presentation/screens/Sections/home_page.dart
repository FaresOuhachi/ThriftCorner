import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thriftcorner/presentation/screens/Sections/product_page.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../data/services/firebase_auth_service.dart';
import '../../../domain/models/user_model.dart';

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
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          FutureBuilder<UserModel?>(
            future: authService.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return Text('No user logged in');
              }

              UserModel? user = snapshot.data;
              return _buildProfileSection(user);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed "Home" Text
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
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
            child: FutureBuilder<UserModel?>(
              future: authService.getCurrentUser(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!userSnapshot.hasData) {
                  return Center(child: Text("No user found", style: TextStyle(color: Colors.white)));
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

  // Future<List<QueryDocumentSnapshot>> _getUsersWithProducts(List<QueryDocumentSnapshot> users, String currentUserId) async {
  //   final List<QueryDocumentSnapshot> filteredUsers = [];
  //
  //   for (var user in users) {
  //     final userId = user.get('id');
  //     if (userId == currentUserId) continue; // Exclude current user
  //
  //     final productSnapshot = await FirebaseFirestore.instance
  //         .collection('products')
  //         .where('sellerId', isEqualTo: userId)
  //         .where('isSold', isEqualTo: false)
  //         .limit(1) // Only check if at least one product exists
  //         .get();
  //
  //     if (productSnapshot.docs.isNotEmpty) {
  //       filteredUsers.add(user);
  //     }
  //   }
  //
  //   return filteredUsers;
  // }

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

  Widget _buildProfileSection(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              user?.profileImage ?? 'https://res.cloudinary.com/dc3luq18s/image/upload/v1/images/ygtdo0cazixao3tyvz5f',  // Cloudinary default image
            ),
          ),
          SizedBox(width: 10),
          Text(
            user?.username ?? 'Username', // Fallback if displayName is null
            style: TextStyle(
              color: Color(0xFFBEE34F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListSection(String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
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
                return _buildUserCard(user['username'], user['id']);
              },
            );
          },
        );
      },
    );
  }


  Widget _buildUserCard(String username, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundImage: NetworkImage(
                'https://res.cloudinary.com/dc3luq18s/image/upload/v1/images/ygtdo0cazixao3tyvz5f',  // Cloudinary profile image URL
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      color: Color(0xFFBEE34F),
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        _buildProductList(userId),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProductList(String userId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .where('sellerId', isEqualTo: userId)
          .where('isSold', isEqualTo: false) // Ensure only unsold products are shown
          .snapshots(),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("No products available", style: TextStyle(color: Colors.white)));
        }

        final products = productSnapshot.data!.docs;

        return SizedBox(
          height: 200,
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
                child: _buildProductCard(product, products[index].id),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, String productId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              product['images'][0] ?? 'https://res.cloudinary.com/dc3luq18s/image/upload/v1/default-product.jpg',  // Cloudinary image URL
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
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SizedBox(
              width: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Unknown Product',  // Fallback if title is missing
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Size: ${product['size'] ?? 'N/A'}',
                        style: TextStyle(
                          color: Color(0xFFD4D4D4).withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${product['price'] ?? 'N/A'} DZD',  // Fallback if price is missing
                        style: TextStyle(
                          color: Color(0xFFBEE34F),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
