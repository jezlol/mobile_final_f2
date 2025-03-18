import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sale_model.dart';

// Simple API service class without singleton pattern
class ApiService {
  // Base URL for the API server
  String baseUrl = 'http://10.0.2.2:5000/api'; // Use 10.0.2.2 for Android emulator to access localhost

  // Get all sales
  Future<List<Sale>> getAllSales() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/sales'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Sale> sales = [];
        
        for (var item in data) {
          Sale sale = Sale(
            id: item['id'],
            productName: item['productName'],
            productPrice: item['productPrice'],
            amount: item['amount'],
            totalPrice: item['totalPrice'],
            createdAt: item['createdAt'] != null 
                ? DateTime.parse(item['createdAt']) 
                : null,
          );
          sales.add(sale);
        }
        
        return sales;
      } else {
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting all sales: $e');
      return [];
    }
  }

  // Get a sale by ID
  Future<Sale?> getSaleById(int id) async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/sales/$id'));
      
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return Sale(
          id: json['id'],
          productName: json['productName'],
          productPrice: json['productPrice'],
          amount: json['amount'],
          totalPrice: json['totalPrice'],
          createdAt: json['createdAt'] != null 
              ? DateTime.parse(json['createdAt']) 
              : null,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting sale by ID: $e');
      return null;
    }
  }

  // Create a new sale
  Future<Sale?> createSale(Sale sale) async {
    try {
      var body = {
        'productName': sale.productName,
        'productPrice': sale.productPrice,
        'amount': sale.amount,
        'totalPrice': sale.totalPrice,
      };
      
      var response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        var json = jsonDecode(response.body);
        return Sale(
          id: json['id'],
          productName: json['productName'],
          productPrice: json['productPrice'],
          amount: json['amount'],
          totalPrice: json['totalPrice'],
          createdAt: json['createdAt'] != null 
              ? DateTime.parse(json['createdAt']) 
              : null,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating sale: $e');
      return null;
    }
  }

  // Update a sale
  Future<Sale?> updateSale(Sale sale) async {
    try {
      var body = {
        'productName': sale.productName,
        'productPrice': sale.productPrice,
        'amount': sale.amount,
        'totalPrice': sale.totalPrice,
      };
      
      var response = await http.put(
        Uri.parse('$baseUrl/sales/${sale.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        var json = jsonDecode(response.body);
        return Sale(
          id: json['id'],
          productName: json['productName'],
          productPrice: json['productPrice'],
          amount: json['amount'],
          totalPrice: json['totalPrice'],
          createdAt: sale.createdAt,
        );
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating sale: $e');
      return null;
    }
  }

  // Delete a sale
  Future<bool> deleteSale(int id) async {
    try {
      var response = await http.delete(Uri.parse('$baseUrl/sales/$id'));
      
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting sale: $e');
      return false;
    }
  }

  // Get total sales amount
  Future<int> getTotalSalesAmount() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/sales/total'));
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Convert to string first, then parse as int
        String totalString = data['total'].toString();
        // If total is null or empty, return 0
        if (totalString == 'null' || totalString.isEmpty) {
          return 0;
        }
        return int.parse(totalString);
      } else {
        print('Error: ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('Error getting total sales amount: $e');
      return 0;
    }
  }
}
