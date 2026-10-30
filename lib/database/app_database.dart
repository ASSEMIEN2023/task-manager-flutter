import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ---------- Tables ----------

class LocalTasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get priority => text().withDefault(const Constant('Moyenne'))();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().withDefault(const Constant(0xFF3F51B5))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------- Database ----------

@DriftDatabase(tables: [LocalTasks, LocalCategories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---- Tasks helpers ----

  Future<List<LocalTask>> getAllTasks(String userId) {
    return (select(localTasks)
          ..where((t) => t.userId.equals(userId) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<void> upsertTask(LocalTasksCompanion task) {
    return into(localTasks).insertOnConflictUpdate(task);
  }

  Future<void> markTaskDeleted(String id) {
    return (update(localTasks)..where((t) => t.id.equals(id)))
        .write(const LocalTasksCompanion(
      isDeleted: Value(true),
      isSynced: Value(false),
    ));
  }

  Future<List<LocalTask>> getUnsyncedTasks() {
    return (select(localTasks)..where((t) => t.isSynced.equals(false))).get();
  }

  Future<void> markTaskSynced(String id) {
    return (update(localTasks)..where((t) => t.id.equals(id)))
        .write(const LocalTasksCompanion(isSynced: Value(true)));
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'task_manager.sqlite'));
    return NativeDatabase(file);
  });
}
