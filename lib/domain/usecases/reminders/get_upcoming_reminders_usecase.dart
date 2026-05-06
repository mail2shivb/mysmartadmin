import '../../../data/local/app_database.dart';
import '../../validation/date_rules.dart';

class GetUpcomingRemindersUseCase {
  final AppDatabase _database;
  GetUpcomingRemindersUseCase(this._database);

  Future<List<ReminderEntity>> call({int lookaheadDays = 7}) async {
    if (lookaheadDays < 0) {
      throw ArgumentError('Lookahead days must be non-negative');
    }
    final now = DateTime.now();
    final end = now.add(Duration(days: lookaheadDays));

    final all = await _database.remindersDao.getFiresBetween(now, end);
    return all.where((r) => r.state == 'pending').toList()
      ..sort((a, b) => a.firesAt.compareTo(b.firesAt));
  }

  Future<List<ReminderEntity>> getAllPending() =>
      _database.remindersDao.getPending();

  Future<List<ReminderEntity>> getOverdue() =>
      _database.remindersDao.getOverdue();

  Future<List<ReminderEntity>> getForDocument(int documentId) async {
    if (documentId <= 0) throw ArgumentError('Invalid document ID');
    return _database.remindersDao.getForSource('document', documentId);
  }

  // Keep the date validator accessible for callers.
  static void validateRange(DateTime from, DateTime to) =>
      DateRules.validateDateRange(from, to);
}
