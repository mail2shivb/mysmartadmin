import '../../../data/local/app_database.dart';

class DeleteSubscriptionUseCase {
  final AppDatabase _database;
  DeleteSubscriptionUseCase(this._database);

  Future<bool> call(int subscriptionId) async {
    return await _database.transaction(() async {
      final rows =
          await _database.subscriptionsDao.softDeleteSubscription(subscriptionId);
      await _database.remindersDao.cancelForSource('subscription', subscriptionId);
      return rows > 0;
    });
  }
}
