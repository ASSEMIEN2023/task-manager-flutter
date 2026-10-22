class AppConstants {
  // Remplace par tes vraies clés Supabase
  static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';

  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';

  static const List<String> priorities = ['Basse', 'Moyenne', 'Haute', 'Urgente'];

  static const Map<String, int> priorityColors = {
    'Basse': 0xFF4CAF50,
    'Moyenne': 0xFF2196F3,
    'Haute': 0xFFFF9800,
    'Urgente': 0xFFF44336,
  };
}
