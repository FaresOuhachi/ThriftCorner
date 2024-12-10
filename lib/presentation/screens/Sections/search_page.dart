import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedSearchType = "account"; // Initial selected value
  String searchQuery = ""; // Search query
  List<Map<String, dynamic>> searchResults = []; // To store search results
  bool isLoading = false; // Track loading state
  String? errorMessage; // Store error messages

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = widget._auth.currentUser;

    return Scaffold(
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
            // Bold "Search" Text
            Text(
              "Search",
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32.0), // Spacing below "Search" text

            // Text Input with Search Button
            Row(
              children: [
                // Input Field
                Expanded(
                  child: TextField(
                    onChanged: (value) =>
                        setState(() {
                          searchQuery = value;
                        }),
                    style: TextStyle(color: Colors.white),
                    // Set text color to white
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Colors.white, fontSize: 15),
                      hintText: "Type here ...",
                      hintStyle: TextStyle(
                          color: Color(0xFF999999), fontSize: 15),
                      filled: true,
                      fillColor: Color(0x00858585).withOpacity(0.25),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0), // Spacing between input and button

                // Search Button
                InkWell(
                  onTap: _performSearch,
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Color(0xFFBFE353).withOpacity(.95),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.0), // Spacing below the input field

            // Custom Radio Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCustomRadio(
                  label: "By Account",
                  value: "account",
                  isSelected: selectedSearchType == "account",
                  onTap: () => setState(() => selectedSearchType = "account"),
                ),
                SizedBox(width: 48.0), // Spacing between radio buttons
                _buildCustomRadio(
                  label: "By Product",
                  value: "product",
                  isSelected: selectedSearchType == "product",
                  onTap: () => setState(() => selectedSearchType = "product"),
                ),
              ],
            ),
            SizedBox(height: 18.0), // Spacing below the radio buttons

            // Search Results or Error
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : errorMessage != null
                  ? Center(
                child: Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              )
                  : searchResults.isEmpty && searchQuery.isNotEmpty
                  ? Center(
                child: Text(
                  "No results found.",
                  style: TextStyle(color: Colors.white.withOpacity(.4)),
                ),
              )
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  bool isUser = result['type'] ==
                      'user'; // Check if it's a user

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(result["profileImage"] ??
                          'https://res.cloudinary.com/dc3luq18s/image/upload/v1/images/ygtdo0cazixao3tyvz5f'), // Use default image if null
                    ),
                    title: Text(
                      isUser
                          ? result["username"] ?? 'No username'
                          : result["title"] ?? 'No title', // Handle null values
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: isUser
                        ? Text("Rating: ${result["rating"] ?? 'N/A'}",
                        style: TextStyle(color: Colors.white))
                        : Text("Price: ${result["price"] ?? 'N/A'} DZD",
                        style: TextStyle(color: Colors.white)),
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
      } else {
        querySnapshot = await _firestore
            .collection('products')
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
            .get();
      }

      setState(() {
        searchResults = querySnapshot.docs
            .map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          // Add a "type" field to distinguish between users and products
          if (selectedSearchType == "account") {
            data['type'] = 'user';
          } else {
            data['type'] = 'product';
          }
          return data;
        })
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to search. Please try again.";
      });
    }
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
                  'https://res.cloudinary.com/dc3luq18s/image/upload/v1/images/ygtdo0cazixao3tyvz5f', // Replace with valid image URL
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
              color: isSelected ? Color(0xFFBFE353) : Color(0xFFD9D9D9)
                  .withOpacity(0.25),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFBFE353) : Color(0xFFD9D9D9)
                  .withOpacity(0.25),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
