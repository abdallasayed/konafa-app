import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // المنتجات
  Stream<List<Product>> getProductsStream({String? category}) {
    Query query = _db.collection('products').where('isAvailable', isEqualTo: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => 
          Product.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
        ).toList();
      });
  }

  List<Product> getDemoProducts() {
    return [
      Product(
        id: '1',
        name: 'كنافة نابلسية',
        price: 150,
        image: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=600&auto=format&fit=crop',
        description: 'كنافة نابلسية أصلية بالمكسرات',
        category: 'كنافة',
        stock: 50,
        discount: 10,
        rating: 4.8,
        reviewCount: 125,
      ),
      Product(
        id: '2',
        name: 'كنافة بالقشطة',
        price: 120,
        image: 'https://images.unsplash.com/photo-1603532648955-039310d9ed75?w=600&auto=format&fit=crop',
        description: 'كنافة بالقشطة الطازجة',
        category: 'كنافة',
        stock: 30,
        rating: 4.9,
        reviewCount: 89,
      ),
      Product(
        id: '3',
        name: 'بسبوسة مكسرات',
        price: 90,
        image: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=600&auto=format&fit=crop',
        description: 'بسبوسة بالمكسرات والقطر',
        category: 'حلويات',
        stock: 100,
        discount: 15,
        rating: 4.7,
        reviewCount: 67,
      ),
    ];
  }

  // الطلبات
  Stream<List<OrderModel>> getOrdersStream({String? status, String? userId}) {
    Query query = _db.collection('orders');
    
    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }
    
    if (userId != null) {
      query = query.where('customer.uid', isEqualTo: userId);
    }
    
    return query
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => 
          OrderModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
        ).toList();
      });
  }

  // المستخدمين
  Stream<UserModel?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  // CRUD Operations
  Future<void> addProduct(Product product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<String> placeOrder({
    required double total,
    required double subTotal,
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> customer,
    double deliveryFee = 0,
    double discount = 0,
    String paymentMethod = 'كاش',
    String? notes,
    Map<String, dynamic>? deliveryAddress,
  }) async {
    final order = OrderModel(
      orderNumber: OrderModel.generateOrderNumber(),
      total: total,
      subTotal: subTotal,
      deliveryFee: deliveryFee,
      discount: discount,
      status: 'PENDING',
      paymentMethod: paymentMethod,
      paymentStatus: 'pending',
      createdAt: Timestamp.now(),
      items: items,
      customer: customer,
      notes: notes,
      deliveryAddress: deliveryAddress,
    );
    
    final docRef = await _db.collection('orders').add(order.toMap());
    return docRef.id;
  }
}
