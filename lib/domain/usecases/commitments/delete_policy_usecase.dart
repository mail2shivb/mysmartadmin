import '../../../data/local/app_database.dart';

class DeletePolicyUseCase {
  final AppDatabase _database;
  DeletePolicyUseCase(this._database);

  /// Soft-deletes the policy and cancels all its active reminders.
  /// Returns true if a policy row was affected.
  Future<bool> call(int policyId) async {
    return await _database.transaction(() async {
      final rows = await _database.policiesDao.softDeletePolicy(policyId);
      await _database.remindersDao.cancelForSource('policy', policyId);
      return rows > 0;
    });
  }
}
