import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _priority;
  DateTime? _dueDate;
  bool _isLoading = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? 'Moyenne';
    _dueDate = widget.task?.dueDate;
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le titre est obligatoire')));
      return;
    }
    setState(() => _isLoading = true);
    final userId = ref.read(authProvider).userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      if (isEditing) {
        final updated = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );
        await ref.read(tasksProvider.notifier).updateTask(updated);
      } else {
        final newTask = Task(
          userId: userId,
          title: _titleController.text.trim(),
          description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
          priority: _priority,
          dueDate: _dueDate,
        );
        await ref.read(tasksProvider.notifier).addTask(newTask);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la tâche' : 'Nouvelle tâche'),
        actions: [
          if (_isLoading)
            const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _save),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Titre *', prefixIcon: Icon(Icons.title)), textCapitalization: TextCapitalization.sentences, autofocus: !isEditing),
            const SizedBox(height: 16),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true), maxLines: 4, textCapitalization: TextCapitalization.sentences),
            const SizedBox(height: 24),
            Text('Priorité', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: AppConstants.priorities.map((p) {
                final selected = _priority == p;
                final color = Color(AppConstants.priorityColors[p]!);
                return ChoiceChip(
                  label: Text(p),
                  selected: selected,
                  selectedColor: color.withOpacity(0.2),
                  labelStyle: TextStyle(color: selected ? color : null, fontWeight: selected ? FontWeight.bold : null),
                  onSelected: (_) => setState(() => _priority = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_dueDate == null ? 'Ajouter une échéance' : 'Échéance : ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              trailing: _dueDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _dueDate = null)) : null,
              onTap: _pickDate,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }
}
