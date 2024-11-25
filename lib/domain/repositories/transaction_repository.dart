import '../models/transaction_model.dart';

abstract class ITransactionRepository {
  Future<TransactionModel?> getTransactionById(String id);

  Future<List<TransactionModel>> getTransactionsByBuyer(String buyerId);

  Future<List<TransactionModel>> getTransactionsBySeller(String sellerId);

  Future<void> createTransaction(TransactionModel transaction);
 }
