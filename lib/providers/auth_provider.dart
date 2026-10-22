import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return service.client.auth.onAuthStateChange.map((event) => event.session?.user);
});

final authProvider = Provider<SupabaseService>((ref) {
  return ref.watch(supabaseServiceProvider);
});
