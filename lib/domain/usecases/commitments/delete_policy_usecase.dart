import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';

/// Use case for deleting a policy
///
/// Soft deletes the policy and cancels auto-generated reminders (status='cancelled')
class DeletePolicyUseCase {
  final AppDatabase _database;

  DeletePolicyUseCase(this._database);

  /// Delete a policy and cancel its associated auto-generated reminders
  /// 
  /// Returns true if successful
  Future<bool> call(int policyId) async {
    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // 1. Soft delete the policy
      final rowsAffected = await _database.policiesDao.softDeletePolicy(policyId);

      // 2. Find auto-generated reminders linked to this policy that are not completed
      // Uses entity identifier pattern: [ENTITY:policy:$policyId]
      final allReminders = await _database.remindersDao.getAllReminders();
      final policyReminders = allReminders.where(
        (r) => r.description != null && 
               r.description!.contains('[ENTITY:policy:$policyId]') &&
               r.status != 'completed',
      );

      // 3. Cancel each reminder (mark as cancelled, do not hard delete)
      for (final reminder in policyReminders) {
        await ((_database.update(_database.reminders))
              ..where((t) => t.id.equals(reminder.id)))
            .write(RemindersCompanion(
          status: const Value('cancelled'),
          updatedAt: Value(DateTime.now()),
        ));
      }

      return rowsAffected > 0;
    });
  }
}

