class Sale {
  final int? id;
  final String productName;
  final int productPrice;
  final int amount;
  final int totalPrice;
  final DateTime? createdAt;

  Sale({
    this.id,
    required this.productName,
    required this.productPrice,
    required this.amount,
    required this.totalPrice,
    this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productName': productName,
      'productPrice': productPrice,
      'amount': amount,
      'totalPrice': totalPrice,
      'createdAt': createdAt?.toIso8601String(),
    };
  }


  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      productName: map['productName'],
      productPrice: map['productPrice'],
      amount: map['amount'],
      totalPrice: map['totalPrice'],
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'].toString()) 
          : null,
    );
  }


  Sale copyWith({
    int? id,
    String? productName,
    int? productPrice,
    int? amount,
    int? totalPrice,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      amount: amount ?? this.amount,
      totalPrice: totalPrice ?? this.totalPrice,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
