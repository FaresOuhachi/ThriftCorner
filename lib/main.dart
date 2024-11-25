import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:thriftcorner/presentation/screens/splash_screen.dart';

import 'data/repositories/product_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/wishlist_repository.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/product_service.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/wishlist_repository.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/product_service.dart';
import 'presentation/controllers/home_controller.dart';
import 'presentation/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Set up dependencies
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // Register repositories
    Get.put<IUserRepository>(UserRepository(firestore));
    Get.put<IProductRepository>(ProductRepository(firestore));
    Get.put<ITransactionRepository>(TransactionRepository(firestore));
    Get.put<IWishlistRepository>(WishlistRepository(firestore));

    // Register services
    Get.put<IAuthService>(
      FirebaseAuthService(auth, Get.find<IUserRepository>()),
    );
    Get.put<IProductService>(
      ProductService(firestore, Get.find<IProductRepository>()),
    );

    // Register controllers
    Get.put(
      HomeController(
        Get.find<IAuthService>(),
        Get.find<IProductService>(),
        Get.find<IUserRepository>(),
      ),
    );
  } catch (e) {
    debugPrint('Error during Firebase initialization: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'ThriftCorner',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        fontFamily: 'Arial',
      ),
      home: SplashScreen(), // Start with the Home Screen
    );
  }
}
