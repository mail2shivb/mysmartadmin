import '../../../data/local/app_database.dart';

class CompleteReminderUseCase {
  final AppDatabase _database;
  CompleteReminderUseCase(this._database);

  Future<bool> call(int reminderId) async {
    if (reminderId <= 0) throw ArgumentError('Invalid reminder ID');

    final reminder = await _database.remindersDao.getById(reminderId);
    if (reminder == null) throw StateError('Reminder $reminderId not found');
    if (reminder.state == 'completed') {
      throw StateError('Reminder is already completed');
    }

    final rows = await _database.remindersDao.complete(reminderId);
    return rows > 0;
  }
}
