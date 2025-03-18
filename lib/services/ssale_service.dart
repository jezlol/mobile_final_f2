import 'package:mysql1/mysql1.dart';
import '../models/sale_model.dart';
import 'ddatabase_service.dart';

class SaleService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Sale> createSale(Sale sale) async {
    final conn = await _databaseService.getConnection();
    try {
      final result = await conn.query(
        'INSERT INTO tbsale (productName, productPrice, amount, totalPrice) VALUES (?, ?, ?, ?)',
        [sale.productName, sale.productPrice, sale.amount, sale.totalPrice],
      );

      final id = result.insertId;

      final createdSale = await getSaleById(id!);
      return createdSale;
    } catch (e) {
      print('Error creating sale: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<List<Sale>> getAllSales() async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT * FROM tbsale ORDER BY createdAt DESC',
      );

      return results
          .map(
            (row) => Sale(
              id: row['id'],
              productName: row['productName'],
              productPrice: row['productPrice'],
              amount: row['amount'],
              totalPrice: row['totalPrice'],
              createdAt: row['createdAt'],
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting all sales: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Sale> getSaleById(int id) async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query('SELECT * FROM tbsale WHERE id = ?', [
        id,
      ]);

      if (results.isEmpty) {
        throw Exception('Sale not found');
      }

      final row = results.first;
      return Sale(
        id: row['id'],
        productName: row['productName'],
        productPrice: row['productPrice'],
        amount: row['amount'],
        totalPrice: row['totalPrice'],
        createdAt: row['createdAt'],
      );
    } catch (e) {
      print('Error getting sale by ID: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<Sale> updateSale(Sale sale) async {
    final conn = await _databaseService.getConnection();
    try {
      await conn.query(
        'UPDATE tbsale SET productName = ?, productPrice = ?, amount = ?, totalPrice = ? WHERE id = ?',
        [
          sale.productName,
          sale.productPrice,
          sale.amount,
          sale.totalPrice,
          sale.id,
        ],
      );

      return await getSaleById(sale.id!);
    } catch (e) {
      print('Error updating sale: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<void> deleteSale(int id) async {
    final conn = await _databaseService.getConnection();
    try {
      await conn.query('DELETE FROM tbsale WHERE id = ?', [id]);
    } catch (e) {
      print('Error deleting sale: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  Future<int> getTotalSalesAmount() async {
    final conn = await _databaseService.getConnection();
    try {
      final results = await conn.query(
        'SELECT SUM(totalPrice) as total FROM tbsale',
      );

      final total = results.first['total'];
      return total != null ? total as int : 0;
    } catch (e) {
      print('Error getting total sales amount: $e');
      return 0;
    } finally {
      await conn.close();
    }
  }
}
