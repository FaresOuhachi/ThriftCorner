import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../domain/models/transaction_model.dart';
import 'order.dart';

class OrdersPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            ),
            bottom: TabBar(
              indicatorColor: Color(0xFFBEE34F),
              dividerHeight: 0,
              labelColor: Colors.white,
              tabs: [
                Tab(text: "Sold"),
                Tab(text: "Bought"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              // Orders Sold Tab
              OrdersList(
                filterField: 'sellerId',
                currentUserId: user?.uid,
                emptyMessage: 'No sold orders available',
                transactionText: (userName, productName) => "$userName purchased $productName from you!",
              ),
              // Orders Bought Tab
              OrdersList(
                filterField: 'buyerId',
                currentUserId: user?.uid,
                emptyMessage: 'No purchased orders available',
                transactionText: (userName, productName) => "You purchased $productName from $userName!",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String filterField;
  final String? currentUserId;
  final String emptyMessage;
  final String Function(String userName, String productName) transactionText;

  const OrdersList({
    super.key,
    required this.filterField,
    required this.currentUserId,
    required this.emptyMessage,
    required this.transactionText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where(filterField, isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                emptyMessage,
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final transactions = snapshot.data!.docs.map((doc) {
            return TransactionModel.fromMap(doc.data() as Map<String, dynamic>);
          }).toList();

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(filterField == 'sellerId' ? transaction.buyerId : transaction.sellerId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final user = userSnapshot.data?.data() as Map<String, dynamic>?;
                  final userName = user?['username'] ?? 'Unknown User';
                  final profilePicUrl = user?['profileImage'] ?? '';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('products')
                        .doc(transaction.productId)
                        .get(),
                    builder: (context, productSnapshot) {
                      if (productSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final product = productSnapshot.data?.data() as Map<String, dynamic>?;
                      final productName = product?['title'] ?? 'Unknown Product';

                      return OrderItemWidget(
                        userName: userName,
                        productName: productName,
                        time: _formatTime(transaction.createdAt),
                        profilePicUrl: profilePicUrl,
                        transactionText: transactionText,
                        transactionId: transaction.id, // Pass the transactionId here
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays} days ago';
    } else {
      final int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}
class OrderItemWidget extends StatelessWidget {
  final String userName;
  final String productName;
  final String time;
  final String profilePicUrl;
  final String Function(String userName, String productName) transactionText;
  final String transactionId; // Add transactionId for navigation

  const OrderItemWidget({
    super.key,
    required this.userName,
    required this.productName,
    required this.time,
    required this.profilePicUrl,
    required this.transactionText,
    required this.transactionId, // Accept transactionId
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderPage(transactionId: transactionId),
          ),
        );
      },
      child: Column(
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
                      Text(
                        transactionText(userName, productName),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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
      ),
    );
  }
}
