import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for account operations
/// 
/// Thin layer above accountsDao - delegates to existing DAO methods
class AccountsRepository {
  final AppDatabase _database;

  AccountsRepository(this._database);

  /// Add a new account
  Future<int> addAccount({
    required String accountName,
    required String accountType,
    required String provider,
    String? accountNumber,
    String? sortCode,
    int currentBalanceCents = 0,
    String status = 'active',
    bool isPrimaryAccount = false,
  }) {
    return _database.accountsDao.createAccount(
      AccountsCompanion.insert(
        accountName: accountName,
        accountType: accountType,
        provider: provider,
        accountNumber: Value(accountNumber),
        sortCode: Value(sortCode),
        currentBalanceCents: Value(currentBalanceCents),
        status: Value(status),
        isPrimaryAccount: Value(isPrimaryAccount),
      ),
    );
  }

  /// Stream all accounts (excluding soft deleted)
  Stream<List<AccountEntity>> watchAllAccounts() {
    return _database.accountsDao.watchAllAccounts();
  }

  /// Get a single account by ID
  Future<AccountEntity?> getAccountById(int id) {
    return _database.accountsDao.getAccountById(id);
  }

  /// Update an existing account
  Future<bool> updateAccount(AccountEntity account) {
    return _database.accountsDao.updateAccount(account);
  }

  /// Soft delete an account (can be restored later)
  Future<int> softDeleteAccount(int id) {
    return _database.accountsDao.softDeleteAccount(id);
  }
}

