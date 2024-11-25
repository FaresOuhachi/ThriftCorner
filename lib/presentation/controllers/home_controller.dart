import 'package:get/get.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/review_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/services/auth_service.dart';
import '../../domain/services/product_service.dart';

class HomeController extends GetxController {
  final IAuthService _authService;
  final IProductService _productService;
  final IUserRepository _userRepository;

  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<Product> recommendedProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;

  Stream<UserModel?>? _authSubscription;

  HomeController(
      this._authService,
      this._productService,
      this._userRepository,
      );

  @override
  void onInit() {
    super.onInit();
    _listenToAuthChanges();
    _loadInitialData();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authService.authStateChanges;
    _authSubscription?.listen((user) {
      currentUser.value = user;
    });
  }

  Future<void> _loadInitialData() async {
    await loadRecommendedProducts();
  }

  Future<void> loadRecommendedProducts() async {
    if (currentUser.value == null) {
      recommendedProducts.clear();
      return;
    }
    try {
      isLoading.value = true;
      final products = await _productService.getRecommendedProducts(
        currentUser.value!.id,
      );
      recommendedProducts.value = products;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load recommended products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      Get.snackbar('Success', 'Password reset email sent to $email.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send password reset email: $e');
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _userRepository.updateUser(user);
      currentUser.value = user;
      Get.snackbar('Success', 'Profile updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e');
    }
  }

  Future<void> toggleFavorite(String productId) async {
    if (currentUser.value == null) {
      Get.snackbar('Error', 'Please sign in to manage favorites.');
      return;
    }
    try {
      await _userRepository.toggleFavorite(currentUser.value!.id, productId);
      Get.snackbar('Success', 'Favorite updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update favorite: $e');
    }
  }

  Future<void> addReview(String userId, ReviewModel review) async {
    try {
      await _userRepository.addReview(userId, review);
      Get.snackbar('Success', 'Review added successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add review: $e');
    }
  }

  Future<void> getUserReviews(String userId) async {
    try {
      final reviews = await _userRepository.getUserReviews(userId);
      // Process reviews if needed
    } catch (e) {
      Get.snackbar('Error', 'Failed to get user reviews: $e');
    }
  }

  Future<void> getAllUsers() async {
    try {
      final users = await _userRepository.getAllUsers();
      // Process users if needed
    } catch (e) {
      Get.snackbar('Error', 'Failed to get all users: $e');
    }
  }

  @override
  void onClose() {
    super.onClose();
    // Dispose of the auth state listener to prevent memory leaks.
    _authSubscription = null;
  }
}
