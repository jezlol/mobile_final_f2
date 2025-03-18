import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/sale_model.dart';
import '../providers/sale_provider.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({Key? key}) : super(key: key);

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _productPriceController = TextEditingController();
  final _amountController = TextEditingController();
  
  int _totalPrice = 0;
  bool _isEditing = false;
  Sale? _saleToEdit;

  @override
  void initState() {
    super.initState();
    
    // ใช้ Future.delayed เพื่อให้แน่ใจว่า build context พร้อมใช้งาน
    Future.delayed(Duration.zero, () {
      // ดึงข้อมูลจาก Provider
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);
      _saleToEdit = saleProvider.selectedSale;
      
      setState(() {
        _isEditing = _saleToEdit != null;
        
        if (_isEditing && _saleToEdit != null) {
          // กรอกข้อมูลที่มีอยู่แล้วลงในฟอร์ม
          _productNameController.text = _saleToEdit!.productName;
          _productPriceController.text = _saleToEdit!.productPrice.toString();
          _amountController.text = _saleToEdit!.amount.toString();
          _calculateTotalPrice();
        } else {
          // ตั้งค่าเริ่มต้นสำหรับการเพิ่มรายการใหม่
          _amountController.text = '1';
        }
      });
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _productPriceController.dispose();
    _amountController.dispose();
    
    // ล้างค่า selected sale เมื่อออกจากหน้าจอ
    Provider.of<SaleProvider>(context, listen: false).setSelectedSale(null);
    
    super.dispose();
  }

  // คำนวณราคารวม
  void _calculateTotalPrice() {
    int price = 0;
    int amount = 0;
    
    try {
      price = int.parse(_productPriceController.text);
    } catch (e) {
      price = 0;
    }
    
    try {
      amount = int.parse(_amountController.text);
    } catch (e) {
      amount = 0;
    }
    
    setState(() {
      _totalPrice = price * amount;
    });
  }

  // บันทึกข้อมูลการขาย
  void _saveSale() {
    if (_formKey.currentState!.validate()) {
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);
      
      final productName = _productNameController.text;
      final productPrice = int.parse(_productPriceController.text);
      final amount = int.parse(_amountController.text);
      
      if (_isEditing && _saleToEdit != null) {
        // อัพเดทข้อมูลการขาย
        final updatedSale = Sale(
          id: _saleToEdit!.id,
          productName: productName,
          productPrice: productPrice,
          amount: amount,
          totalPrice: _totalPrice,
          createdAt: _saleToEdit!.createdAt,
        );
        
        saleProvider.updateSale(updatedSale).then((_) {
          // กลับไปหน้าก่อนหน้า
          Navigator.pop(context);
        });
      } else {
        // สร้างข้อมูลการขายใหม่
        final newSale = Sale(
          productName: productName,
          productPrice: productPrice,
          amount: amount,
          totalPrice: _totalPrice,
        );
        
        saleProvider.createSale(newSale).then((_) {
          // กลับไปหน้าก่อนหน้า
          Navigator.pop(context);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'แก้ไขรายการขาย' : 'เพิ่มรายการขาย'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ชื่อสินค้า
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อสินค้า',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาระบุชื่อสินค้า';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // ราคาต่อชิ้น
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(
                  labelText: 'ราคาต่อชิ้น (บาท)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาระบุราคาสินค้า';
                  }
                  if (int.tryParse(value) == null) {
                    return 'ราคาสินค้าต้องเป็นตัวเลขเท่านั้น';
                  }
                  if (int.parse(value) <= 0) {
                    return 'ราคาสินค้าต้องมากกว่า 0';
                  }
                  return null;
                },
                onChanged: (_) => _calculateTotalPrice(),
              ),
              SizedBox(height: 16),
              
              // จำนวน
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'จำนวน (ชิ้น)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณาระบุจำนวนสินค้า';
                  }
                  if (int.tryParse(value) == null) {
                    return 'จำนวนสินค้าต้องเป็นตัวเลขเท่านั้น';
                  }
                  if (int.parse(value) <= 0) {
                    return 'จำนวนสินค้าต้องมากกว่า 0';
                  }
                  return null;
                },
                onChanged: (_) => _calculateTotalPrice(),
              ),
              SizedBox(height: 24),
              
              // แสดงราคารวม
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'ราคารวม',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$_totalPrice บาท',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Spacer(),
              
              // ปุ่มบันทึก
              ElevatedButton(
                onPressed: _saveSale,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isEditing ? 'บันทึกการแก้ไข' : 'บันทึกรายการขาย',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
