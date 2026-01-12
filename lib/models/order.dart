import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? id;
  String orderNumber;
  double total;
  double subTotal;
  double? deliveryFee;
  double? discount;
  String status;
  String? paymentMethod;
  String? paymentStatus;
  Timestamp createdAt;
  Timestamp? updatedAt;
  List<Map<String, dynamic>> items;
  Map<String, dynamic> customer;
  Map<String, dynamic>? deliveryAddress;
  String? notes;
  String? assignedTo;
  
  OrderModel({
    this.id,
    required this.orderNumber,
    required this.total,
    required this.subTotal,
    this.deliveryFee = 0,
    this.discount = 0,
    required this.status,
    this.paymentMethod = 'كاش',
    this.paymentStatus = 'pending',
    required this.createdAt,
    this.updatedAt,
    required this.items,
    required this.customer,
    this.deliveryAddress,
    this.notes,
    this.assignedTo,
  });

  static String generateOrderNumber() {
    return 'ORD${DateTime.now().millisecondsSinceEpoch}';
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'total': total,
      'subTotal': subTotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? Timestamp.now(),
      'items': items,
      'customer': customer,
      'deliveryAddress': deliveryAddress,
      'notes': notes,
      'assignedTo': assignedTo,
    };
  }

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      orderNumber: data['orderNumber'] ?? generateOrderNumber(),
      total: (data['total'] ?? 0).toDouble(),
      subTotal: (data['subTotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      status: data['status'] ?? 'PENDING',
      paymentMethod: data['paymentMethod'] ?? 'كاش',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'],
      items: data['items'] != null ? List<Map<String, dynamic>>.from(data['items']) : [],
      customer: data['customer'] != null ? Map<String, dynamic>.from(data['customer']) : {},
      deliveryAddress: data['deliveryAddress'],
      notes: data['notes'],
      assignedTo: data['assignedTo'],
    );
  }
}
