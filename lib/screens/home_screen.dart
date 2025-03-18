import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/sale_model.dart';
import '../providers/sale_provider.dart';
import 'sale_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load sales when the screen is initialized
    Future.delayed(Duration.zero, () {
      Provider.of<SaleProvider>(context, listen: false).loadSales();
    });
  }

  // Format date
  String formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Navigate to add sale form
  void goToAddSaleForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaleFormScreen()),
    ).then((_) {
      // Refresh sales list when returning from form
      Provider.of<SaleProvider>(context, listen: false).loadSales();
    });
  }

  // Edit a sale
  void editSale(Sale sale) {
    // Set selected sale in provider
    Provider.of<SaleProvider>(context, listen: false).setSelectedSale(sale);

    // Navigate to edit form
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SaleFormScreen()),
    ).then((_) {
      // Refresh sales list when returning from form
      Provider.of<SaleProvider>(context, listen: false).loadSales();
    });
  }

  // Delete a sale
  void deleteSale(Sale sale) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ยืนยันการลบ'),
            content: Text(
              'คุณต้องการลบรายการขาย "${sale.productName}" ใช่หรือไม่?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () {
                  // Delete sale and close dialog
                  Provider.of<SaleProvider>(
                    context,
                    listen: false,
                  ).deleteSale(sale.id!);
                  Navigator.pop(context);
                },
                child: Text('ลบ', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Show sale details
  void showSaleDetails(Sale sale) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('รายละเอียดการขาย'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('สินค้า: ${sale.productName}'),
                Text('ราคา: ${sale.productPrice} บาท'),
                Text('จำนวน: ${sale.amount} ชิ้น'),
                Text('ราคารวม: ${sale.totalPrice} บาท'),
                Text('วันที่: ${formatDate(sale.createdAt)}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ปิด'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกการขายสินค้า'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SaleProvider>(
        builder: (context, saleProvider, child) {
          // Show loading indicator
          if (saleProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Show error message
          if (saleProvider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'เกิดข้อผิดพลาด: ${saleProvider.error}',
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => saleProvider.loadSales(),
                    child: Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          // Show empty state
          if (saleProvider.sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ไม่มีรายการขายสินค้า', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => goToAddSaleForm(),
                    child: Text('เพิ่มรายการขาย'),
                  ),
                ],
              ),
            );
          }

          // Show sales list
          return Column(
            children: [
              // Total sales card
              Card(
                margin: EdgeInsets.all(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'ยอดขายรวมทั้งหมด',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${NumberFormat("#,###").format(saleProvider.totalSalesAmount)} บาท',
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

              // Sales list
              Expanded(
                child: ListView.builder(
                  itemCount: saleProvider.sales.length,
                  itemBuilder: (context, index) {
                    Sale sale = saleProvider.sales[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              sale.productName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ราคา: ${NumberFormat("#,###").format(sale.productPrice)} บาท',
                                ),
                                Text('จำนวน: ${sale.amount} ชิ้น'),
                                Text('วันที่: ${formatDate(sale.createdAt)}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${NumberFormat("#,###").format(sale.totalPrice)} บาท',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text('รวม', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            onTap: () => showSaleDetails(sale),
                          ),
                          // Add buttons for edit and delete
                          Padding(
                            padding: EdgeInsets.only(
                              left: 8,
                              right: 8,
                              bottom: 8,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Edit button
                                TextButton.icon(
                                  onPressed: () => editSale(sale),
                                  label: Text(
                                    'แก้ไข',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                                // Delete button
                                TextButton.icon(
                                  onPressed: () => deleteSale(sale),
                                  label: Text(
                                    'ลบ',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => goToAddSaleForm(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
