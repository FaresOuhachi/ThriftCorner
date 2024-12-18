import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thriftcorner/presentation/screens/Sections/profile/user_profile_page.dart';
import 'home/product_page.dart';

class SearchPage extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedSearchType = "account";
  String searchQuery = "";
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  String? errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() {
                      searchQuery = value;
                    }),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type here ...",
                      hintStyle: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: const Color(0x00858585).withOpacity(0.25),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                InkWell(
                  onTap: _performSearch,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFE353).withOpacity(.95),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCustomRadio(
                  label: "By Account",
                  value: "account",
                  isSelected: selectedSearchType == "account",
                  onTap: () {
                    setState(() {
                      selectedSearchType = "account";
                      searchResults.clear();
                    });
                    _performSearch();
                  },
                ),
                SizedBox(width: 48.0),
                _buildCustomRadio(
                  label: "By Product",
                  value: "product",
                  isSelected: selectedSearchType == "product",
                  onTap: () {
                    setState(() {
                      selectedSearchType = "product";
                      searchResults.clear();
                    });
                    _performSearch();
                  },
                ),
              ],
            ),
            SizedBox(height: 18.0),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              )
                  : searchResults.isEmpty && searchQuery.isNotEmpty
                  ? Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(.4)),
                ),
              )
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  final isUser = result['type'] == 'user';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        result["profileImage"] ??
                            'https://res.cloudinary.com/dc3luq18s/image/upload/v1733842092/images/icons8-avatar-96_epem6m',
                      ),
                    ),
                    title: Text(
                      result["username"] ?? 'No username',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: isUser
                        ? Text(
                      "Items: ${result["totalItems"]} (${result["soldItems"]} sold)",
                      style: const TextStyle(
                          color: Colors.white),
                    )
                        : Text(
                      "Price: ${result["price"] ?? 'N/A'} DZD",
                      style: const TextStyle(
                          color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => isUser
                              ? UserProfilePage(
                              userId: result["id"])
                              : ProductScreen(
                              productId: result["id"]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch() async {
    if (searchQuery.isEmpty) {
      setState(() {
        searchResults = [];
        errorMessage = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      QuerySnapshot querySnapshot;

      if (selectedSearchType == "account") {
        querySnapshot = await _firestore
            .collection('users')
            .where('username', isGreaterThanOrEqualTo: searchQuery)
            .where('username', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .get();

        final List<Map<String, dynamic>> users = await Future.wait(
          querySnapshot.docs.map((doc) async {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;

            final products = await _firestore
                .collection('products')
                .where('sellerId', isEqualTo: doc.id)
                .get();

            final totalItems = products.docs.length;
            final soldItems = products.docs
                .where((product) => (product.data() as Map)['isSold'] == true)
                .length;

            return {
              ...data,
              "type": "user",
              "totalItems": totalItems,
              "soldItems": soldItems,
            };
          }).toList(),
        );

        setState(() {
          searchResults = users;
          isLoading = false;
        });
      } else {
        querySnapshot = await _firestore
            .collection('products')
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .get();

        setState(() {
          searchResults = querySnapshot.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            data['type'] = 'product';
            return data;
          }).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to search. Please try again.";
      });
    }
  }

  Widget _buildCustomRadio({
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFBFE353)
                  : const Color(0xFFD9D9D9).withOpacity(0.25),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFBFE353)
                  : const Color(0xFFD9D9D9).withOpacity(0.25),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
