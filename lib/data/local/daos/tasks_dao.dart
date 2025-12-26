import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tasks.dart';

part 'tasks_dao.g.dart';

/// Data Access Object for Tasks
/// 
/// Manages user and system-generated tasks
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(AppDatabase db) : super(db);

  // ============================================================
  // CREATE
  // ============================================================

  /// Create a new task
  Future<int> createTask(TasksCompanion task) {
    return into(tasks).insert(task);
  }

  /// Create multiple tasks
  Future<void> createTasks(List<TasksCompanion> taskList) async {
    await batch((batch) {
      batch.insertAll(tasks, taskList);
    });
  }

  // ============================================================
  // READ
  // ============================================================

  /// Get a task by ID
  Future<TaskEntity?> getTaskById(int id) {
    return (select(tasks)
          ..where((t) => t.id.equals(id))
          ..where((t) => t.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Get all tasks
  Future<List<TaskEntity>> getAllTasks() {
    return (select(tasks)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks by type
  Future<List<TaskEntity>> getTasksByType(String taskType) {
    return (select(tasks)
          ..where((t) => t.taskType.equals(taskType))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks by category
  Future<List<TaskEntity>> getTasksByCategory(String category) {
    return (select(tasks)
          ..where((t) => t.category.equals(category))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks by status
  Future<List<TaskEntity>> getTasksByStatus(String status) {
    return (select(tasks)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get pending tasks
  Future<List<TaskEntity>> getPendingTasks() {
    return getTasksByStatus('pending');
  }

  /// Get in-progress tasks
  Future<List<TaskEntity>> getInProgressTasks() {
    return getTasksByStatus('in_progress');
  }

  /// Get completed tasks
  Future<List<TaskEntity>> getCompletedTasks() {
    return getTasksByStatus('completed');
  }

  /// Get overdue tasks
  Future<List<TaskEntity>> getOverdueTasks() {
    final now = DateTime.now();
    return (select(tasks)
          ..where((t) => t.dueDate.isSmallerThanValue(now))
          ..where((t) => t.status.isNotValue('completed'))
          ..where((t) => t.status.isNotValue('cancelled'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks by priority
  Future<List<TaskEntity>> getTasksByPriority(int priority) {
    return (select(tasks)
          ..where((t) => t.priority.equals(priority))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get high priority tasks
  Future<List<TaskEntity>> getHighPriorityTasks() {
    return (select(tasks)
          ..where((t) => t.priority.isBiggerOrEqualValue(1))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks due today
  Future<List<TaskEntity>> getTasksDueToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return (select(tasks)
          ..where((t) => t.dueDate.isBiggerOrEqualValue(startOfDay))
          ..where((t) => t.dueDate.isSmallerOrEqualValue(endOfDay))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority)]))
        .get();
  }

  /// Get tasks due this week
  Future<List<TaskEntity>> getTasksDueThisWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return (select(tasks)
          ..where((t) => t.dueDate.isBiggerOrEqualValue(startOfWeek))
          ..where((t) => t.dueDate.isSmallerOrEqualValue(endOfWeek))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get recurring tasks
  Future<List<TaskEntity>> getRecurringTasks() {
    return (select(tasks)
          ..where((t) => t.isRecurring.equals(true))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.nextOccurrence)]))
        .get();
  }

  /// Get system-generated tasks
  Future<List<TaskEntity>> getSystemGeneratedTasks() {
    return getTasksByType('system_generated');
  }

  /// Get user-created tasks
  Future<List<TaskEntity>> getUserCreatedTasks() {
    return getTasksByType('user_created');
  }

  /// Get tasks for a property
  Future<List<TaskEntity>> getTasksForProperty(int propertyId) {
    return (select(tasks)
          ..where((t) => t.propertyId.equals(propertyId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks for a vehicle
  Future<List<TaskEntity>> getTasksForVehicle(int vehicleId) {
    return (select(tasks)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Get tasks for a home asset
  Future<List<TaskEntity>> getTasksForHomeAsset(int homeAssetId) {
    return (select(tasks)
          ..where((t) => t.homeAssetId.equals(homeAssetId))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  /// Stream all tasks
  Stream<List<TaskEntity>> watchAllTasks() {
    return (select(tasks)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Stream tasks by status
  Stream<List<TaskEntity>> watchTasksByStatus(String status) {
    return (select(tasks)
          ..where((t) => t.status.equals(status))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.priority), (t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  /// Stream pending tasks
  Stream<List<TaskEntity>> watchPendingTasks() {
    return watchTasksByStatus('pending');
  }

  /// Stream overdue tasks
  Stream<List<TaskEntity>> watchOverdueTasks() {
    final now = DateTime.now();
    return (select(tasks)
          ..where((t) => t.dueDate.isSmallerThanValue(now))
          ..where((t) => t.status.isNotValue('completed'))
          ..where((t) => t.status.isNotValue('cancelled'))
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  // ============================================================
  // UPDATE
  // ============================================================

  /// Update a task
  Future<bool> updateTask(TaskEntity task) {
    return update(tasks).replace(task);
  }

  /// Update task status
  Future<int> updateTaskStatus(int id, String status) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark task as completed
  Future<int> markTaskAsCompleted(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('completed'),
        completedDate: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark task as in progress
  Future<int> markTaskAsInProgress(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        status: const Value('in_progress'),
        startDate: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Mark task as cancelled
  Future<int> markTaskAsCancelled(int id) {
    return updateTaskStatus(id, 'cancelled');
  }

  /// Mark task as overdue
  Future<int> markTaskAsOverdue(int id) {
    return updateTaskStatus(id, 'overdue');
  }

  /// Update task priority
  Future<int> updateTaskPriority(int id, int priority) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        priority: Value(priority),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Update task due date
  Future<int> updateTaskDueDate(int id, DateTime dueDate) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        dueDate: Value(dueDate),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  /// Soft delete a task
  Future<int> softDeleteTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      TasksCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Hard delete a task
  Future<int> hardDeleteTask(int id) {
    return (delete(tasks)..where((t) => t.id.equals(id))).go();
  }

  /// Restore a soft deleted task
  Future<int> restoreTask(int id) {
    return (update(tasks)..where((t) => t.id.equals(id))).write(
      const TasksCompanion(
        deletedAt: Value(null),
      ),
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  /// Count tasks by status
  Future<int> countTasksByStatus(String status) async {
    final query = selectOnly(tasks)
      ..addColumns([tasks.id.count()])
      ..where(tasks.status.equals(status))
      ..where(tasks.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Count overdue tasks
  Future<int> countOverdueTasks() async {
    final now = DateTime.now();
    final query = selectOnly(tasks)
      ..addColumns([tasks.id.count()])
      ..where(tasks.dueDate.isSmallerThanValue(now))
      ..where(tasks.status.isNotValue('completed'))
      ..where(tasks.status.isNotValue('cancelled'))
      ..where(tasks.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Count high priority tasks
  Future<int> countHighPriorityTasks() async {
    final query = selectOnly(tasks)
      ..addColumns([tasks.id.count()])
      ..where(tasks.priority.isBiggerOrEqualValue(1))
      ..where(tasks.status.isNotValue('completed'))
      ..where(tasks.status.isNotValue('cancelled'))
      ..where(tasks.deletedAt.isNull());

    final result = await query.getSingle();
    return result.read(tasks.id.count()) ?? 0;
  }

  /// Calculate completion rate
  Future<double> calculateCompletionRate() async {
    final allTasks = await getAllTasks();
    if (allTasks.isEmpty) return 0.0;
    
    final completedCount = allTasks.where((t) => t.status == 'completed').length;
    
    return completedCount / allTasks.length;
  }
}

