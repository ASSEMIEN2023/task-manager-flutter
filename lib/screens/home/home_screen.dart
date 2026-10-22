import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/task_provider.dart';
import '../../models/task.dart';
import '../tasks/task_form_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_alt, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucune tâche pour le moment'),
                  Text('Appuie sur + pour en ajouter une'),
                ],
              ),
            );
          }
          final pending = tasks.where((t) => !t.isCompleted).toList();
          final completed = tasks.where((t) => t.isCompleted).toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                Text('À faire (${pending.length})', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...pending.map((task) => _TaskTile(task: task)),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('Terminées (${completed.length})', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ...completed.map((task) => _TaskTile(task: task)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erreur: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TaskFormScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  final Task task;
  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = Color(
      task.priority == 'Urgente' ? 0xFFF44336 :
      task.priority == 'Haute' ? 0xFFFF9800 :
      task.priority == 'Moyenne' ? 0xFF2196F3 : 0xFF4CAF50,
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => ref.read(tasksProvider.notifier).toggleComplete(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: task.description != null && task.description!.isNotEmpty ? Text(task.description!) : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(task.priority, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen(task: task))),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Supprimer ?'),
              content: Text('Supprimer la tâche "${task.title}" ?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
                TextButton(
                  onPressed: () {
                    ref.read(tasksProvider.notifier).deleteTask(task.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
