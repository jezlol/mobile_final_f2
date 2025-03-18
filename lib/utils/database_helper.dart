import '../services/ddatabase_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  final DatabaseService _databaseService = DatabaseService();


  Future<void> initializeDatabase() async {
    try {
      await _databaseService.initializeDatabase();
      print('Database initialized successfully');
    } catch (e) {
      print('Failed to initialize database: $e');
      rethrow;
    }
  }
}
