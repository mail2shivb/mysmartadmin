import '../../../data/local/app_database.dart';

class GetActiveRemindersUseCase {
  final AppDatabase _database;
  GetActiveRemindersUseCase(this._database);

  Future<List<ReminderEntity>> call() =>
      _database.remindersDao.getPending();
}
