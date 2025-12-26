import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/accounts.dart';

part 'accounts_dao.g.dart';

/// Data Access Object for Accounts
/// 
/// Manages bank accounts, credit cards, loans, and savings
@DriftAccessor(tables: [Accounts])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new account
  Future<int> createAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Create multiple accounts
  Future<void> createAccounts(List<AccountsCompanion> accountList) async {
    await batch((batch) {
      batch.insertAll(accounts, accountList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get an account by ID
  Future<AccountEntity?> getAccountById(int id) {
    return (select(accounts)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all accounts
  Future<List<AccountEntity>> getAllAccounts() {
    return (select(accounts)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimaryAccount)]))
        .get();
  }

  /// Get account by account number
  Future<AccountEntity?> getAccountByAccountNumber(String accountNumber) {
    return (select(accounts)
          ..where((t) => t.accountNumber.equals(accountNumber))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get accounts by type
  Future<List<AccountEntity>> getAccountsByType(String accountType) {
    return (select(accounts)
          ..where((t) => t.accountType.equals(accountType))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get accounts by status
  Future<List<AccountEntity>> getAccountsByStatus(String status) {
    return (select(accounts)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get active accounts
  Future<List<AccountEntity>> getActiveAccounts() {
    return getAccountsByStatus('active');
  }

  /// Get primary account
  Future<AccountEntity?> getPrimaryAccount() {
    return (select(accounts)
          ..where((t) => t.isPrimaryAccount.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get current accounts
  Future<List<AccountEntity>> getCurrentAccounts() {
    return getAccountsByType('current');
  }

  /// Get savings accounts
  Future<List<AccountEntity>> getSavingsAccounts() {
    return getAccountsByType('savings');
  }

  /// Get credit cards
  Future<List<AccountEntity>> getCreditCards() {
    return getAccountsByType('credit_card');
  }

  /// Get loans
  Future<List<AccountEntity>> getLoans() {
    return (select(accounts)
          ..where((t) =>
              t.accountType.equals('loan') |
              t.accountType.equals('mortgage'))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get ISA accounts
  Future<List<AccountEntity>> getISAAccounts() {
    return (select(accounts)
          ..where((t) => t.isIsaAccount.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get accounts by provider
  Future<List<AccountEntity>> getAccountsByProvider(String provider) {
    return (select(accounts)
          ..where((t) => t.provider.equals(provider))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get joint accounts
  Future<List<AccountEntity>> getJointAccounts() {
    return (select(accounts)
          ..where((t) => t.isJointAccount.equals(true))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get accounts with negative balance (overdraft)
  Future<List<AccountEntity>> getOverdrawnAccounts() {
    return (select(accounts)
          ..where((t) => t.currentBalanceCents.isSmallerThanValue(0))
          ..where((t) => t.deletedAt.isNull()))
        .get();
  }

  /// Get accounts needing review
  Future<List<AccountEntity>> getAccountsNeedingReview() {
    final now = DateTime.now();
    return (select(accounts)
          ..where((t) => t.nextReviewDate.isSmallerThanValue(now))
          ..where((t) => t.nextReviewDate.isNotNull())
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextReviewDate)]))
        .get();
  }

  /// Stream all accounts
  Stream<List<AccountEntity>> watchAllAccounts() {
    return (select(accounts)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.isPrimaryAccount)]))
        .watch();
  }

  /// Stream accounts by type
  Stream<List<AccountEntity>> watchAccountsByType(String accountType) {
    return (select(accounts)
          ..where((t) => t.accountType.equals(accountType))
          ..where((t) => t.deletedAt.isNull()))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update an account
  Future<bool> updateAccount(AccountEntity account) {
    return update(accounts).replace(account);
  }

  /// Update account balance
  Future<int> updateBalance(int id, int balanceCents) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        currentBalanceCents: Value(balanceCents),
        lastUpdated: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update available balance
  Future<int> updateAvailableBalance(int id, int availableBalanceCents) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        availableBalanceCents: Value(availableBalanceCents),
        lastUpdated: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update loan balance
  Future<int> updateLoanBalance(int id, int outstandingBalanceCents) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        outstandingBalanceCents: Value(outstandingBalanceCents),
        lastUpdated: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update ISA allowance usage
  Future<int> updateISAAllowanceUsed(int id, int usedAllowanceCents) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        usedIsaAllowanceCents: Value(usedAllowanceCents),
        lastUpdated: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update account status
  Future<int> updateAccountStatus(int id, String status) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Close account
  Future<int> closeAccount(int id, DateTime closedDate) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        status: const Value('closed'),
        closedDate: Value(closedDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Freeze account
  Future<int> freezeAccount(int id) {
    return updateAccountStatus(id, 'frozen');
  }

  /// Activate account
  Future<int> activateAccount(int id) {
    return updateAccountStatus(id, 'active');
  }

  /// Set as primary account
  Future<void> setPrimaryAccount(int id) async {
    // First, unset all other accounts
    await (update(accounts)..where((t) => t.deletedAt.isNull())).write(
      const AccountsCompanion(
        isPrimaryAccount: Value(false),
      ),
    );
    // Then set the selected account as primary
    await (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        isPrimaryAccount: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update direct debit count
  Future<int> updateDirectDebitCount(int id, int count) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        directDebitCount: Value(count),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update standing order count
  Future<int> updateStandingOrderCount(int id, int count) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        standingOrderCount: Value(count),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete an account
  Future<int> softDeleteAccount(int id) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      AccountsCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete an account
  Future<int> hardDeleteAccount(int id) {
    return (delete(accounts)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted account
  Future<int> restoreAccount(int id) {
    return (update(accounts)..where((t) => t.id.equals(id))).write(
      const AccountsCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Calculate total balance across all accounts
  Future<int> calculateTotalBalance() async {
    final allAccounts = await getActiveAccounts();
    int total = 0;
    for (final account in allAccounts) {
      // Only include current and savings accounts
      if (account.accountType == 'current' || account.accountType == 'savings' || account.accountType == 'isa') {
        total += account.currentBalanceCents;
      }
    }
    return total;
  }

  /// Calculate total savings
  Future<int> calculateTotalSavings() async {
    final savingsAccounts = await getSavingsAccounts();
    final isaAccounts = await getISAAccounts();
    int total = 0;
    for (final account in [...savingsAccounts, ...isaAccounts]) {
      total += account.currentBalanceCents;
    }
    return total;
  }

  /// Calculate total debt (loans + credit cards + overdrafts)
  Future<int> calculateTotalDebt() async {
    final allAccounts = await getActiveAccounts();
    int total = 0;
    for (final account in allAccounts) {
      if (account.accountType == 'loan' || account.accountType == 'mortgage') {
        if (account.outstandingBalanceCents != null) {
          total += account.outstandingBalanceCents!;
        }
      } else if (account.accountType == 'credit_card') {
        // Credit card balance is typically negative (amount owed)
        if (account.currentBalanceCents < 0) {
          total += account.currentBalanceCents.abs();
        }
      }
    }
    return total;
  }

  /// Calculate total monthly loan payments
  Future<int> calculateMonthlyLoanPayments() async {
    final loans = await getLoans();
    int total = 0;
    for (final loan in loans) {
      if (loan.monthlyPaymentCents != null) {
        total += loan.monthlyPaymentCents!;
      }
    }
    return total;
  }

  /// Calculate credit utilization (used credit / total credit limit)
  Future<double> calculateCreditUtilization() async {
    final creditCards = await getCreditCards();
    int totalLimit = 0;
    int totalUsed = 0;
    
    for (final card in creditCards) {
      if (card.creditLimitCents != null) {
        totalLimit += card.creditLimitCents!;
        // Balance is negative for amount owed
        if (card.currentBalanceCents < 0) {
          totalUsed += card.currentBalanceCents.abs();
        }
      }
    }
    
    if (totalLimit == 0) return 0.0;
    return (totalUsed / totalLimit) * 100;
  }

  /// Calculate total ISA allowance remaining
  Future<int> calculateISAAllowanceRemaining() async {
    final isaAccounts = await getISAAccounts();
    int totalAllowance = 0;
    int totalUsed = 0;
    
    for (final isa in isaAccounts) {
      if (isa.annualIsaAllowanceCents != null) {
        totalAllowance += isa.annualIsaAllowanceCents!;
      }
      if (isa.usedIsaAllowanceCents != null) {
        totalUsed += isa.usedIsaAllowanceCents!;
      }
    }
    
    return totalAllowance - totalUsed;
  }

  /// Count accounts by type
  Future<int> countAccountsByType(String accountType) async {
    final query = selectOnly(accounts)
      ..addColumns([accounts.id.count()])
      ..where(accounts.accountType.equals(accountType))
      ..where(accounts.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(accounts.id.count()) ?? 0;
  }

  /// Count accounts by status
  Future<int> countAccountsByStatus(String status) async {
    final query = selectOnly(accounts)
      ..addColumns([accounts.id.count()])
      ..where(accounts.status.equals(status))
      ..where(accounts.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(accounts.id.count()) ?? 0;
  }

  // ============================================================
  // VERSIONING
  // ============================================================

  /// Get account versions
  Future<List<AccountEntity>> getAccountVersions(int accountId) {
    return (select(accounts)
          ..where((t) => t.id.equals(accountId) | t.previousVersionId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.version)]))
        .get();
  }

  /// Create new version of an account
  Future<int> createAccountVersion(int existingAccountId, AccountsCompanion updates) async {
    final existing = await getAccountById(existingAccountId);
    if (existing == null) throw Exception('Account not found');

    final newVersion = updates.copyWith(
      version: Value(existing.version + 1),
      previousVersionId: Value(existingAccountId),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );

    return into(accounts).insert(newVersion);
  }
}

