import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftcorner/domain/models/transaction_model.dart';
import 'package:thriftcorner/data/repositories/transaction_repository.dart';
import 'package:thriftcorner/data/repositories/product_repository.dart';

class OrderPage extends StatefulWidget {
  final String transactionId;

  const OrderPage({super.key, required this.transactionId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final TransactionRepository _transactionRepository;
  late final ProductRepository _productRepository;
  bool _isLoading = true;
  bool _hasError = false;

  late TransactionModel _transaction;

  @override
  void initState() {
    super.initState();
    _transactionRepository = TransactionRepository(FirebaseFirestore.instance);
    _productRepository = ProductRepository(FirebaseFirestore.instance);
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    try {
      // Fetch the transaction data
      final transaction = await _transactionRepository.getTransactionById(widget.transactionId);

      if (transaction != null) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error fetching transaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : _hasError
          ? Center(child: Text('Error fetching data', style: TextStyle(color: Colors.white)))
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Order',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Product Info Section
                _buildProductInfo(),
                SizedBox(height: 20),
                // Buyer Info Section
                _buildUserInfo(_transaction.buyerId, "Buyer"),
                SizedBox(height: 20),
                // Seller Info Section
                _buildUserInfo(_transaction.sellerId, "Seller"),
                SizedBox(height: 20),
                // Order Info Section
                _buildOrderInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Product Information Section
  Widget _buildProductInfo() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(_transaction.productId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Text('Product not found', style: TextStyle(color: Colors.white));
        }

        final productData = snapshot.data!.data() as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  productData['images'][0] ?? 'https://via.placeholder.com/150',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.black,
                    child: Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Product name: ${productData['title']}',
                style: TextStyle(color: Color(0xFFBEE34F), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Price: ${productData['price']} DZD',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Size: ${productData['size']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Color: ${productData['color']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                'Condition: ${productData['condition']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  // User Info Section (Buyer/Seller)
  Widget _buildUserInfo(String userId, String role) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Text('$role not found', style: TextStyle(color: Colors.white));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      userData['profileImage'] ?? 'https://via.placeholder.com/150',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '$role: ${userData['username']}',
                    style: TextStyle(color: Color(0xFFBEE34F), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Country: ${userData['country']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Gender: ${userData['gender']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                'Phone: ${userData['phoneNumber']}',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  // Order Info Section
  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction ID: ${_transaction.id}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Date: ${_transaction.createdAt.day}/${_transaction.createdAt.month}/${_transaction.createdAt.year}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          SizedBox(height: 8),
          Text(
            'Time: ${_transaction.createdAt.hour}:${_transaction.createdAt.minute}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}