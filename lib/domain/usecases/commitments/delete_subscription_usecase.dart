import 'package:drift/drift.dart';
import '../../../data/local/app_database.dart';

/// Use case for deleting a subscription
///
/// Soft deletes the subscription and cancels auto-generated reminders (status='cancelled')
class DeleteSubscriptionUseCase {
  final AppDatabase _database;

  DeleteSubscriptionUseCase(this._database);

  /// Delete a subscription and cancel its associated auto-generated reminders
  /// 
  /// Returns true if successful
  Future<bool> call(int subscriptionId) async {
    // Wrap in transaction to ensure atomicity
    return await _database.transaction(() async {
      // 1. Soft delete the subscription
      final rowsAffected = await _database.subscriptionsDao.softDeleteSubscription(subscriptionId);

      // 2. Find auto-generated reminders linked to this subscription that are not completed
      // Uses entity identifier pattern: [ENTITY:subscription:$subscriptionId]
      final allReminders = await _database.remindersDao.getAllReminders();
      final subscriptionReminders = allReminders.where(
        (r) => r.description != null && 
               r.description!.contains('[ENTITY:subscription:$subscriptionId]') &&
               r.status != 'completed',
      );

      // 3. Cancel each reminder (mark as cancelled, do not hard delete)
      for (final reminder in subscriptionReminders) {
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

