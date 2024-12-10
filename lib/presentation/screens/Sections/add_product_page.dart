import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thriftcorner/domain/repositories/product_repository.dart';
import '../../../domain/models/product_model.dart';
import '../../widgets/custom_text_field.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final IProductRepository _productRepository = Get.find<IProductRepository>();
  List<File> _selectedImages = [];


  final TextEditingController titleController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  String selectedSize = '';
  String selectedCondition = 'New';


  Future<List<String>> _uploadImagesToCloudinary(List<File> imageFiles) async {
    const cloudinaryUrl =
        "https://api.cloudinary.com/v1_1/dc3luq18s/image/upload";
    const uploadPreset = "products_images";

    List<String> imageUrls = [];

    for (File imageFile in imageFiles) {
      final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
      request.fields['upload_preset'] = uploadPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseData = await response.stream.bytesToString();
          final jsonResponse = json.decode(responseData);
          imageUrls.add(jsonResponse['secure_url']);
        } else {
          print("Cloudinary upload failed with status: ${response.statusCode}");
        }
      } catch (e) {
        print("Error uploading image: $e");
      }
    }
    return imageUrls;
  }



  Future<void> _pickMultipleImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedImages = result.paths.map((path) => File(path!)).toList();
      });
    }
  }



  void _handleUploadProduct() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select images before uploading.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Uploading images...')),
    );

    final imageUrls = await _uploadImagesToCloudinary(_selectedImages);

    if (imageUrls.isNotEmpty) {
      try {
        final product = Product(
          id: '',
          title: titleController.text.trim(),
          sellerId: _auth.currentUser?.uid ?? '',
          images: imageUrls,
          size: selectedSize,
          price: double.tryParse(priceController.text.trim()) ?? 0.0,
          color: colorController.text.trim(),
          condition: selectedCondition,
          description: descriptionController.text.trim(),
          isSold: false,
          uploadedAt: DateTime.now(),
        );

        await _productRepository.createProduct(product);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product uploaded successfully!')),
        );

        setState(() {
          _selectedImages.clear();
          titleController.clear();
          priceController.clear();
          descriptionController.clear();
          colorController.clear();
          selectedSize = '';
          selectedCondition = 'New';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create product: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload images.')),
      );
    }
  }



  void _showConditionPicker() {
    final List<String> productConditions = [
      'New',
      'Like New',
      'Very Good',
      'Good',
      'Acceptable'
    ];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1.0,
                color: Color(0xFFE5EAFF).withOpacity(0.375)
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Product Condition',
            style: TextStyle(
              color: Colors.white.withOpacity(0.375),
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: productConditions.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(
                    productConditions[index],
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.375),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedCondition = productConditions[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          actions: [
            _buildProfileSection(_auth.currentUser),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Product',
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
                      _buildProductImage(), // Now centered
                      SizedBox(height: 32),
                      Text(
                        'Details:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildProductForm(),
                      SizedBox(height: 24),
                      _buildUploadButton(),
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

  Widget _buildProductImage() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _pickMultipleImages,
                child: Container(
                  width: 202,
                  height: 202,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFAEAEAE).withOpacity(0.5),
                        Color(0xFF484848).withOpacity(0.5),
                      ],
                      begin: Alignment(-0.7, 1),
                      end: Alignment(1, -0.7),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.375)),
                  ),
                  child: _selectedImages.isEmpty
                      ? Center(
                    child: Text(
                      'Tap to add images',
                      style:
                      TextStyle(color: Colors.white.withOpacity(0.375)),
                    ),
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImages.first,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              if (_selectedImages.isNotEmpty)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _pickMultipleImages,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFBEE34F),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 24,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 10),
          if (_selectedImages.isNotEmpty)
            Text(
              "${_selectedImages.length} images selected",
              style: TextStyle(color: Colors.white),
            ),
          SizedBox(height: 10),
          if (_selectedImages.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear Selection',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildSizeSection() {
    final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align to the extreme right
          children: [
            Text(
              'Size:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 20, // Space between buttons
          children: sizes.map((size) {
            final isSelected = selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSize = size;
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0xFF1F1F1F).withOpacity(.5), // Inner color
                      Color(0xFF858585).withOpacity(.5), // Outer color
                    ],
                    stops: [0.55, 1.0], // Radius for gradient
                  ),
                  border: Border.all(
                    color: isSelected ? Color(0xFFBEE34F) : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }


  Widget _buildConditionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: _showConditionPicker,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1.0,
                  color: Color(0xFFE5EAFF).withOpacity(0.375)
              ),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    selectedCondition,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.375),
                      fontSize: 16,
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white.withOpacity(0.375),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductForm() {
    return Column(
      children: [
        CustomTextField(
          controller: titleController,
          label: 'Product Title',
          icon: Icons.title,
        ),
        SizedBox(height: 16),
        _buildSizeSection(), // Existing size selection
        SizedBox(height: 16),
        _buildConditionSection(), // New condition selection
        SizedBox(height: 16),
        CustomTextField(
          controller: colorController,
          label: 'Color',
          icon: Icons.color_lens,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: descriptionController,
          label: 'Description',
          icon: Icons.description,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: priceController,
          label: 'Price in DZD',
          icon: Icons.attach_money,
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.75,
        height: 48,
        child: ElevatedButton(
          onPressed: _handleUploadProduct,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFBEE34F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(48),
            ),
            padding: EdgeInsets.symmetric(vertical: 8),
          ),
          child: Center(
            child: Text(
              'Upload Product',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
