import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:thriftcorner/domain/repositories/transaction_repository.dart';
import '../../domain/models/transaction_model.dart';

class TransactionRepository implements ITransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository(this._firestore);

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final transaction =
          await _firestore.collection('transactions').doc(id).get();

      return transaction.exists
          ? TransactionModel.fromMap(transaction.data()!)
          : null;
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsBySeller(String sellerId) async {
    try {
      final transactions = await _firestore
          .collection('transactions')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return transactions.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get seller transactions: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByBuyer(String buyerId) async {
    try {
      final transactions = await _firestore
          .collection('transactions')
          .where('buyerId', isEqualTo: buyerId)
          .orderBy('createdAt', descending: true)
          .get();

      return transactions.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get buyer transactions: $e');
    }
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('transactions')
          .doc(transaction.id)
          .set(transaction.toMap());
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }
}
