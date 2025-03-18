import 'package:mysql1/mysql1.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<MySqlConnection> getConnection() async {
    final settings = ConnectionSettings(
      host: '127.0.0.1',
      port: 3306,
      user: 'root',
      password: '',
      db: 'dbshop',
    );

    try {
      return await MySqlConnection.connect(settings);
    } catch (e) {
      print('Database connection error: $e');
      rethrow;
    }
  }

  Future<void> initializeDatabase() async {
    var conn;
    try {
      final settings = ConnectionSettings(
        host: '127.0.0.1',
        port: 3306,
        user: 'root',
        password: '',
      );

      conn = await MySqlConnection.connect(settings);

      await conn.query('CREATE DATABASE IF NOT EXISTS dbshop');

      await conn.query('USE dbshop');

      await conn.query('''
        CREATE TABLE IF NOT EXISTS tbsale (
          id INT AUTO_INCREMENT PRIMARY KEY,
          productName TEXT NOT NULL,
          productPrice INT NOT NULL,
          amount INT NOT NULL,
          totalPrice INT NOT NULL,
          createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      print('Database and tables initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    } finally {
      if (conn != null) {
        await conn.close();
      }
    }
  }
}
