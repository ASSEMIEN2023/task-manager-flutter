import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import '../services/sync_service.dart';
import '../services/notification_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier(
    ref.watch(syncServiceProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(supabaseServiceProvider),
  );
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final SyncService _sync;
  final NotificationService _notifications;
  final SupabaseService _supabase;

  TasksNotifier(this._sync, this._notifications, this._supabase)
      : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final userId = _supabase.userId;
      if (userId == null) {
        state = const AsyncValue.data([]);
        return;
      }
      final tasks = await _sync.getTasks(userId);
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await _sync.createTask(task);
      // Programme le rappel si date d'échéance
      await _notifications.scheduleTaskReminder(newTask);
      state.whenData((tasks) {
        state = AsyncValue.data([newTask, ...tasks]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updated = await _sync.updateTask(task);
      // Met à jour le rappel
      await _notifications.cancelReminder(task.id);
      await _notifications.scheduleTaskReminder(updated);
      state.whenData((tasks) {
        state = AsyncValue.data([
          for (final t in tasks)
            if (t.id == updated.id) updated else t
        ]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _sync.deleteTask(id);
      await _notifications.cancelReminder(id);
      state.whenData((tasks) {
        state = AsyncValue.data(tasks.where((t) => t.id != id).toList());
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updated);
  }

  /// Force une synchronisation manuelle
  Future<void> syncNow() async {
    await loadTasks();
  }
}
