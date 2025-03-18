import 'package:flutter/foundation.dart';
import '../models/sale_model.dart';
import '../services/api_service.dart';

class SaleProvider with ChangeNotifier {
  // Create an instance of ApiService
  ApiService apiService = ApiService();
  
  // Variables to store data
  List<Sale> _sales = [];
  Sale? _selectedSale;
  bool _isLoading = false;
  String _error = '';
  int _totalSalesAmount = 0;

  // Getters
  List<Sale> get sales => _sales;
  Sale? get selectedSale => _selectedSale;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalSalesAmount => _totalSalesAmount;

  // Set selected sale
  void setSelectedSale(Sale? sale) {
    _selectedSale = sale;
    notifyListeners();
  }

  // Load all sales
  Future<void> loadSales() async {
    // Set loading state to true
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Get sales from API
      _sales = await apiService.getAllSales();
      
      // Get total sales amount
      _totalSalesAmount = await apiService.getTotalSalesAmount();
    } catch (e) {
      // Handle error
      _error = 'Failed to load sales: $e';
    }
    
    // Set loading state to false
    _isLoading = false;
    notifyListeners();
  }

  // Create a new sale
  Future<void> createSale(Sale sale) async {
    // Set loading state to true
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Create sale using API
      Sale? newSale = await apiService.createSale(sale);
      
      // Add new sale to list if not null
      if (newSale != null) {
        _sales.insert(0, newSale); // Add to the beginning of the list
      }
      
      // Update total sales amount
      _totalSalesAmount = await apiService.getTotalSalesAmount();
    } catch (e) {
      // Handle error
      _error = 'Failed to create sale: $e';
    }
    
    // Set loading state to false
    _isLoading = false;
    notifyListeners();
  }

  // Update a sale
  Future<void> updateSale(Sale sale) async {
    // Set loading state to true
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Update sale using API
      Sale? updatedSale = await apiService.updateSale(sale);
      
      // Update sale in list if not null
      if (updatedSale != null) {
        // Find the index of the sale to update
        int index = -1;
        for (int i = 0; i < _sales.length; i++) {
          if (_sales[i].id == sale.id) {
            index = i;
            break;
          }
        }
        
        // Update the sale if found
        if (index != -1) {
          _sales[index] = updatedSale;
        }
      }
      
      // Update total sales amount
      _totalSalesAmount = await apiService.getTotalSalesAmount();
    } catch (e) {
      // Handle error
      _error = 'Failed to update sale: $e';
    }
    
    // Set loading state to false
    _isLoading = false;
    notifyListeners();
  }

  // Delete a sale
  Future<void> deleteSale(int id) async {
    // Set loading state to true
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Delete sale using API
      bool success = await apiService.deleteSale(id);
      
      // Remove sale from list if deletion was successful
      if (success) {
        // Create a new list without the deleted sale
        List<Sale> newSales = [];
        for (var sale in _sales) {
          if (sale.id != id) {
            newSales.add(sale);
          }
        }
        _sales = newSales;
      }
      
      // Update total sales amount
      _totalSalesAmount = await apiService.getTotalSalesAmount();
    } catch (e) {
      // Handle error
      _error = 'Failed to delete sale: $e';
    }
    
    // Set loading state to false
    _isLoading = false;
    notifyListeners();
  }

  // Calculate total price for a single sale
  int calculateSaleTotalPrice(int price, int amount) {
    return price * amount;
  }
}
