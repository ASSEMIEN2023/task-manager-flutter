import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../models/task.dart';
import 'supabase_service.dart';
import 'package:drift/drift.dart';

class SyncService {
  final AppDatabase db;
  final SupabaseService supabase;

  SyncService(this.db, this.supabase);

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Charge les tâches (local d'abord, puis sync si online)
  Future<List<Task>> getTasks(String userId) async {
    // 1. Toujours lire le local en priorité (offline-first)
    final localTasks = await db.getAllTasks(userId);

    // 2. Si online, synchronise avec Supabase
    if (await isOnline && supabase.userId != null) {
      try {
        await _pushLocalChanges();
        await _pullRemoteTasks(userId);
        // Recharge après sync
        final updated = await db.getAllTasks(userId);
        return updated.map(_fromLocal).toList();
      } catch (_) {
        // En cas d'erreur réseau, on reste sur le local
      }
    }

    return localTasks.map(_fromLocal).toList();
  }

  Future<Task> createTask(Task task) async {
    // Toujours écrire en local d'abord
    await db.upsertTask(_toCompanion(task, isSynced: false));

    // Essaye de pousser vers Supabase si online
    if (await isOnline) {
      try {
        final remote = await supabase.createTask(task);
        await db.upsertTask(_toCompanion(remote, isSynced: true));
        return remote;
      } catch (_) {}
    }
    return task;
  }

  Future<Task> updateTask(Task task) async {
    await db.upsertTask(_toCompanion(task, isSynced: false));

    if (await isOnline) {
      try {
        final remote = await supabase.updateTask(task);
        await db.upsertTask(_toCompanion(remote, isSynced: true));
        return remote;
      } catch (_) {}
    }
    return task;
  }

  Future<void> deleteTask(String id) async {
    await db.markTaskDeleted(id);

    if (await isOnline) {
      try {
        await supabase.deleteTask(id);
        await db.markTaskSynced(id);
      } catch (_) {}
    }
  }

  // ---- Sync interne ----

  Future<void> _pushLocalChanges() async {
    final unsynced = await db.getUnsyncedTasks();
    for (final local in unsynced) {
      try {
        if (local.isDeleted) {
          await supabase.deleteTask(local.id);
        } else {
          final task = _fromLocal(local);
          // On tente un update, si ça échoue on crée
          try {
            await supabase.updateTask(task);
          } catch (_) {
            await supabase.createTask(task);
          }
        }
        await db.markTaskSynced(local.id);
      } catch (_) {}
    }
  }

  Future<void> _pullRemoteTasks(String userId) async {
    final remoteTasks = await supabase.getTasks();
    for (final task in remoteTasks) {
      await db.upsertTask(_toCompanion(task, isSynced: true));
    }
  }

  // ---- Helpers ----

  Task _fromLocal(LocalTask t) {
    return Task(
      id: t.id,
      userId: t.userId,
      title: t.title,
      description: t.description,
      dueDate: t.dueDate,
      priority: t.priority,
      categoryId: t.categoryId,
      isCompleted: t.isCompleted,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    );
  }

  LocalTasksCompanion _toCompanion(Task task, {required bool isSynced}) {
    return LocalTasksCompanion(
      id: Value(task.id),
      userId: Value(task.userId),
      title: Value(task.title),
      description: Value(task.description),
      dueDate: Value(task.dueDate),
      priority: Value(task.priority),
      categoryId: Value(task.categoryId),
      isCompleted: Value(task.isCompleted),
      createdAt: Value(task.createdAt),
      updatedAt: Value(task.updatedAt),
      isSynced: Value(isSynced),
      isDeleted: const Value(false),
    );
  }
}

// Providers
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseServiceProvider),
  );
});
