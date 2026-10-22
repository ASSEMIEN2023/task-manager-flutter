import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task.dart';
import '../models/category.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  String? get userId => currentUser?.id;

  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<List<Task>> getTasks() async {
    final response = await client
        .from('tasks')
        .select()
        .eq('user_id', userId!)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Task.fromMap(e)).toList();
  }

  Future<Task> createTask(Task task) async {
    final response = await client
        .from('tasks')
        .insert(task.toMap())
        .select()
        .single();
    return Task.fromMap(response);
  }

  Future<Task> updateTask(Task task) async {
    final response = await client
        .from('tasks')
        .update(task.toMap())
        .eq('id', task.id)
        .select()
        .single();
    return Task.fromMap(response);
  }

  Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  Future<List<Category>> getCategories() async {
    final response = await client
        .from('categories')
        .select()
        .eq('user_id', userId!)
        .order('name');
    return (response as List).map((e) => Category.fromMap(e)).toList();
  }

  Future<Category> createCategory(Category category) async {
    final response = await client
        .from('categories')
        .insert(category.toMap())
        .select()
        .single();
    return Category.fromMap(response);
  }

  Future<void> deleteCategory(String categoryId) async {
    await client.from('categories').delete().eq('id', categoryId);
  }
}
