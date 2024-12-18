import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thriftcorner/data/repositories/wishlist_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../domain/models/product_model.dart';
import '../../../../domain/models/transaction_model.dart';

class ProductScreen extends StatefulWidget {
  final String productId;

  const ProductScreen({super.key, required this.productId});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool isItemAdded = false; // State to track if the product is in wishlist
  late final TransactionRepository _transactionRepository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final WishlistRepository _wishlistRepository;
  bool isSold = false; // Track if the product is sold

  @override
  void initState() {
    super.initState();
    _transactionRepository = TransactionRepository(FirebaseFirestore.instance);
    _wishlistRepository = WishlistRepository(FirebaseFirestore.instance);
    _checkIfProductInWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("View Product", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Product not found", style: TextStyle(color: Colors.white)));
          }

          final product = Product.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
            snapshot.data!.id,
          );

          // Check if the product is sold
          isSold = product.isSold ?? false;

          final userId = _auth.currentUser?.uid;

          return Column(
            children: [
              if (product.images.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                  child: CarouselSlider(
                    items: product.images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.black,
                                    child: Icon(Icons.image, size: 100, color: Colors.white70),
                                  ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: 300,
                      viewportFraction: 1.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 9,
                      initialPage: 0,
                    ),
                  ),
                ),
              SizedBox(height: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            product.title,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Center(
                          child: Text(
                            "${product.price} DZD",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBEE34F),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildDetailRow("Size", product.size),
                        _buildDetailRow("Color", product.color),
                        _buildDetailRow("Condition", product.condition),
                        _buildDetailRow("Uploaded",
                            _formatUploadedTime(product.uploadedAt)),
                        SizedBox(height: 16),
                        Text(
                          "Description:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          product.description,
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black,
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSold ? null : () {
                          _createTransaction(product);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSold
                              ? Colors.grey
                              : Color(0xFFBEE34F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                        ),
                        child: Text(
                          isSold ? "Sold" : "Buy Now",
                          style: TextStyle(
                            fontSize: 18,
                            color: isSold ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (userId != null) {
                          if (isItemAdded) {
                            // Remove from wishlist
                            await _wishlistRepository.removeFromWishlist(userId, product.id);
                          } else {
                            // Add to wishlist
                            await _wishlistRepository.addToWishlist(userId, product.id);
                          }

                          // Update the button state after action
                          setState(() {
                            isItemAdded = !isItemAdded;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isItemAdded ? Colors.red : Color(0xFFBEE34F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      ),
                      child: Image.asset(
                        isItemAdded
                            ? 'assets/icons/Cintre_remove.png'
                            : 'assets/icons/Cintre_add.png',
                        width: 24,
                        height: 24,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }

  // Check if the product is in the wishlist
  Future<void> _checkIfProductInWishlist() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final isProductInWishlist = await _wishlistRepository.isProductInWishlist(userId, widget.productId);
      setState(() {
        isItemAdded = isProductInWishlist; // Update state based on the result
      });
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          Text(
            value.isNotEmpty ? value : 'N/A',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  String _formatUploadedTime(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  Future<void> _createTransaction(Product product) async {
    try {
      final buyerId = _auth.currentUser?.uid;
      if (buyerId == null) {
        throw Exception('User not authenticated');
      }
      final sellerId = product.sellerId;
      final transaction = TransactionModel(
        id: FirebaseFirestore.instance.collection('transactions').doc().id,
        buyerId: buyerId,
        sellerId: sellerId,
        productId: product.id,
        amountPaid: product.price,
        status: TransactionStatus.success,
        createdAt: DateTime.now(),
        updatedAt: null,
      );

      await _transactionRepository.createTransaction(transaction);
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'isSold': true});
      _showSuccessDialog(context);
    } catch (e) {
      print('Error creating transaction: $e');
      _showErrorDialog(context);
    }
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Center(
            child: Icon(
              Icons.check_circle,
              color: Color(0xFFBEE34F),
              size: 60,
            ),
          ),
          content: Text(
            "Product bought successfully!",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFBEE34F),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          title: Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: 60,
            ),
          ),
          content: Text(
            "An error occurred while processing your request. Please try again.",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFBEE34F),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
