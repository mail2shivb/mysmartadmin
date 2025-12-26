import 'package:drift/drift.dart';
import '../../data/local/app_database.dart';

/// Domain repository for task operations
/// 
/// Thin layer above tasksDao - delegates to existing DAO methods
class TasksRepository {
  final AppDatabase _database;

  TasksRepository(this._database);

  /// Add a new task
  Future<int> addTask({
    required String title,
    required String taskType,
    String? category,
    DateTime? dueDate,
    String? description,
    int priority = 0,
    bool isRecurring = false,
  }) {
    return _database.tasksDao.createTask(
      TasksCompanion.insert(
        title: title,
        taskType: taskType,
        category: Value(category),
        dueDate: Value(dueDate),
        description: Value(description),
        priority: Value(priority),
        isRecurring: Value(isRecurring),
      ),
    );
  }

  /// Stream open tasks (pending + in-progress)
  Stream<List<TaskEntity>> watchOpenTasks() {
    return _database.tasksDao.watchAllTasks();
  }

  /// Mark task as completed
  Future<int> markTaskCompleted(int id) {
    return _database.tasksDao.markTaskAsCompleted(id);
  }

  /// Soft delete a task (can be restored later)
  Future<int> softDeleteTask(int id) {
    return _database.tasksDao.softDeleteTask(id);
  }
}

