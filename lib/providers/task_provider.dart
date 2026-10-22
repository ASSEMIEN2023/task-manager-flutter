import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

final tasksProvider = StateNotifierProvider<TasksNotifier, AsyncValue<List<Task>>>((ref) {
  return TasksNotifier(ref.watch(supabaseServiceProvider));
});

class TasksNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final SupabaseService _service;

  TasksNotifier(this._service) : super(const AsyncValue.loading()) {
    loadTasks();
  }

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await _service.createTask(task);
      state.whenData((tasks) {
        state = AsyncValue.data([newTask, ...tasks]);
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updated = await _service.updateTask(task);
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
      await _service.deleteTask(id);
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
}
