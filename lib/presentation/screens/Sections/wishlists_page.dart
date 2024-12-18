import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/models/product_model.dart';
import '../../../domain/models/user_model.dart';
import '../../../domain/repositories/wishlist_repository.dart';
import 'home/product_page.dart';

class WishlistPage extends StatefulWidget {
  final String userId;
  final IWishlistRepository wishlistRepository;

  const WishlistPage({
    super.key,
    required this.userId,
    required this.wishlistRepository,
  });

  @override
  _WishlistPageState createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  bool isGridView = true;
  List<String> productIds = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  void _fetchWishlist() async {
    try {
      final wishlist = await widget.wishlistRepository.getWishlistByUser(widget.userId);
      if (wishlist != null) {
        setState(() {
          productIds = wishlist.productIds;
        });
      }
    } catch (e) {
      print('Error fetching wishlist: $e');
    }
  }

  void _toggleView() {
    setState(() {
      isGridView = !isGridView;
    });
  }

  void _removeFromWishlist(String productId) async {
    try {
      await widget.wishlistRepository.removeFromWishlist(widget.userId, productId);
      setState(() {
        productIds.remove(productId);
      });
    } catch (e) {
      print('Error removing product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'My Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isGridView ? Icons.grid_view : Icons.list,
              color: Colors.white,
            ),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: productIds.isEmpty
          ? const Center(
        child: Text(
          'Your wishlist is empty.',
          style: TextStyle(color: Colors.white),
        ),
      )
          : isGridView
          ? _buildGridView()
          : _buildListView(),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: productIds.length,
      itemBuilder: (context, index) {
        final productId = productIds[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildWishlistItem(productId, isGridView: false),
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7, // Adjusted aspect ratio for smaller cards
      ),
      itemCount: productIds.length,
      itemBuilder: (context, index) {
        final productId = productIds[index];
        return _buildWishlistItem(productId, isGridView: true);
      },
    );
  }

  Widget _buildWishlistItem(String productId, {required bool isGridView}) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('products').doc(productId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Product not found', style: TextStyle(color: Colors.white)));
        }

        final productData = snapshot.data!.data() as Map<String, dynamic>;
        final product = Product.fromMap(productData, productId);

        // Fetching seller information
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(product.sellerId).get(),
          builder: (context, sellerSnapshot) {
            if (sellerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            if (!sellerSnapshot.hasData || !sellerSnapshot.data!.exists) {
              return const Center(child: Text('Seller not found', style: TextStyle(color: Colors.white)));
            }

            final sellerData = sellerSnapshot.data!.data() as Map<String, dynamic>;
            final seller = UserModel.fromMap(sellerData); // Convert to UserModel
            final sellerName = seller.username;

            return GestureDetector(
              onTap: () {
                // Navigate to the ProductScreen when clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(productId: productId),
                  ),
                );
              },
              onLongPress: () {
                _removeFromWishlist(productId);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Reduced padding
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(0, 4),
                      blurRadius: 8.0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center all content in the middle
                  crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
                  children: [
                    if (isGridView) ...[
                      // For GridView: Image on top
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          product.images.isNotEmpty
                              ? product.images[0]
                              : 'https://res.cloudinary.com/dc3luq18s/image/upload/v1/default-product.jpg',
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 100,
                            width: 100,
                            color: Colors.grey.withOpacity(0.5),
                            child: const Icon(Icons.image, color: Colors.white54),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      // Product details (title, seller, price) in GridView
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Seller: $sellerName',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              '${product.price} DZD',
                              style: const TextStyle(
                                color: Color(0xFF7D9349),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // For ListView: Image on left, information in the center
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              product.images.isNotEmpty
                                  ? product.images[0]
                                  : 'https://res.cloudinary.com/dc3luq18s/image/upload/v1/default-product.jpg',
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 80,
                                width: 80,
                                color: Colors.grey.withOpacity(0.5),
                                child: const Icon(Icons.image, color: Colors.white54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'Seller: $sellerName',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  '${product.price} DZD',
                                  style: const TextStyle(
                                    color: Color(0xFF7D9349),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8.0),
                    // Always show the remove icon, but under information in ListView and at the top-right in GridView
                    if (!isGridView)
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _removeFromWishlist(productId);
                        },
                      ),
                    if (isGridView) ...[
                      // Remove button at the bottom in GridView
                      const SizedBox(height: 8.0),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          _removeFromWishlist(productId);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }



}
