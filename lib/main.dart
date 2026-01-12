import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

// متغير لمعرفة حالة الاتصال
bool isFirebaseConnected = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // محاولة الاتصال بفايربيز
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDWPN3hCNjW2arTtdrs3ueIZveHg9ie5gU",
        appId: "1:44212119840:web:8106de80c8c5abb6674f45", // تحتاج لتغييره
        messagingSenderId: "44212119840",
        projectId: "konafasystem",
        storageBucket: "konafasystem.firebasestorage.app",
      ),
    );
    isFirebaseConnected = true;
    print("✅ تم الاتصال بنجاح بـ Firebase");
  } catch (e) {
    print("❌ خطأ في الاتصال بفايربيز: $e");
    isFirebaseConnected = false;
  }
  
  runApp(const KonafaApp());
}

class AppTheme {
  static const Color primaryColor = Color(0xFFEA580C);
  static const Color secondaryColor = Color(0xFFF97316);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardDark,
        background: darkBackground,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark.withOpacity(0.8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: const TextStyle(color: textColor),
        errorStyle: const TextStyle(color: errorColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.cairo(),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }
}

class KonafaApp extends StatelessWidget {
  const KonafaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'كنافة بالقشطة',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl, 
          child: child!,
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}

class Product {
  String? id;
  String name;
  double price;
  String image;
  String? description;
  DateTime? createdAt;
  
  Product({
    this.id, 
    required this.name, 
    required this.price, 
    required this.image,
    this.description,
    this.createdAt,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? 'https://placehold.co/400',
      description: data['description'],
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name, 
      'price': price, 
      'image': image,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}

class OrderModel {
  String? id;
  double total;
  String status;
  Timestamp createdAt;
  List<Map<String, dynamic>>? items;
  String? customerName;
  String? customerPhone;

  OrderModel({
    this.id, 
    required this.total, 
    required this.status, 
    required this.createdAt,
    this.items,
    this.customerName,
    this.customerPhone,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'PENDING',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      items: data['items'] != null ? List<Map<String, dynamic>>.from(data['items']) : null,
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'status': status,
      'createdAt': createdAt,
      'items': items,
      'customerName': customerName,
      'customerPhone': customerPhone,
    };
  }
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    if (!isFirebaseConnected) {
      return Stream.value([
        Product(
          id: '1', 
          name: 'كنافة نابلسية', 
          price: 150, 
          image: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=600&auto=format&fit=crop'
        ),
        Product(
          id: '2', 
          name: 'كنافة بالقشطة', 
          price: 120, 
          image: 'https://images.unsplash.com/photo-1603532648955-039310d9ed75?w-600&auto=format&fit=crop'
        ),
        Product(
          id: '3', 
          name: 'بسبوسة مكسرات', 
          price: 90, 
          image: 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w-600&auto=format&fit=crop'
        ),
      ]);
    }
    return _db.collection('products')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
  }

  Stream<List<OrderModel>> getOrdersStream() {
    if (!isFirebaseConnected) {
      return Stream.value([]);
    }
    return _db.collection('orders')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      });
  }

  Future<void> addProduct(Product product) async {
    if (!isFirebaseConnected) {
      throw Exception("لا يوجد اتصال بقاعدة البيانات");
    }
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    if (!isFirebaseConnected) {
      throw Exception("لا يوجد اتصال");
    }
    await _db.collection('products').doc(productId).update(updates);
  }

  Future<void> deleteProduct(String productId) async {
    if (!isFirebaseConnected) {
      throw Exception("لا يوجد اتصال");
    }
    await _db.collection('products').doc(productId).delete();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!isFirebaseConnected) {
      throw Exception("لا يوجد اتصال");
    }
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  Future<String> placeOrder(double total, List<Product> cartItems, {String? customerName, String? customerPhone}) async {
    if (!isFirebaseConnected) {
      throw Exception("لا يوجد اتصال");
    }
    
    final items = cartItems.map((product) => {
      'name': product.name,
      'price': product.price,
      'image': product.image,
    }).toList();
    
    final docRef = await _db.collection('orders').add({
      'total': total,
      'status': 'PENDING',
      'createdAt': Timestamp.now(),
      'items': items,
      'itemsCount': cartItems.length,
      'customerName': customerName ?? 'عميل',
      'customerPhone': customerPhone,
    });
    
    return docRef.id;
  }
}

class UploadService {
  static const String UPLOADCARE_PUB_KEY = "8e2cb6a00c4b7dd45f95";
  static const String UPLOADCARE_UPLOAD_URL = "https://upload.uploadcare.com/base/";

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(UPLOADCARE_UPLOAD_URL));
      request.fields['UPLOADCARE_PUB_KEY'] = UPLOADCARE_PUB_KEY;
      request.fields['UPLOADCARE_STORE'] = '1';
      
      var multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return "https://ucarecdn.com/${jsonResponse['file']}/";
      } else {
        print("❌ فشل رفع الصورة: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ خطأ في رفع الصورة: $e");
      return null;
    }
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<Product> cart = [];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    showSnackBar('${product.name} أضيفت للسلة! 🛒');
  }

  void removeFromCart(int index) {
    setState(() {
      cart.removeAt(index);
    });
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  void showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        addToCart: addToCart, 
        cart: cart, 
        clearCart: clearCart,
        removeFromCart: removeFromCart,
      ),
      const AdminScreen(),
    ];

    return ScaffoldMessenger(
      key: scaffoldMessengerKey,
      child: Scaffold(
        body: pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: BottomNavigationBar(
              backgroundColor: AppTheme.cardDark,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey[400],
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_rounded),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.admin_panel_settings_rounded),
                  label: 'الإدارة',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(Product) addToCart;
  final VoidCallback clearCart;
  final Function(int) removeFromCart;
  final List<Product> cart;
  final db = DatabaseService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();

  HomeScreen({
    super.key, 
    required this.addToCart, 
    required this.cart, 
    required this.clearCart,
    required this.removeFromCart,
  });

  void _showOrderConfirmation(BuildContext context, double total) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تأكيد الطلب',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم العميل',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال رقم الهاتف';
                        }
                        if (value.length < 10) {
                          return 'رقم الهاتف غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          NumberFormat.simpleCurrency(locale: 'ar_EG').format(total),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            Navigator.pop(context);
                            try {
                              await db.placeOrder(
                                total,
                                cart,
                                customerName: nameController.text,
                                customerPhone: phoneController.text,
                              );
                              clearCart();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('تم إرسال طلبك بنجاح! 🎉'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('فشل في إرسال الطلب، حاول مرة أخرى'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('تأكيد الطلب'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'ar_EG');

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('كنافة بالقشطة 🥧'),
        actions: [
          if (!isFirebaseConnected)
            Tooltip(
              message: 'وضع العرض فقط - لا يوجد اتصال',
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.wifi_off, color: Colors.red),
              ),
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (cart.isNotEmpty) {
                    _showCartBottomSheet(context, formatCurrency);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('السلة فارغة'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.shopping_cart_rounded),
                tooltip: 'عرض السلة',
              ),
              if (cart.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.darkBackground, width: 2),
                    ),
                    child: Text(
                      '${cart.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: db.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد منتجات حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'قم بإضافة منتجات من صفحة الإدارة',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(context, product, formatCurrency);
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, NumberFormat formatter) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.cardDark,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.cardDark,
                    child: const Center(
                      child: Icon(Icons.error_outline, color: Colors.red),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatter.format(product.price),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => addToCart(product),
                    icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
                    label: const Text('إضافة للسلة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCartBottomSheet(BuildContext context, NumberFormat formatter) {
    double total = cart.fold(0, (sum, item) => sum + item.price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'سلة المشتريات',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Row(
                        children: [
                          if (cart.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('تفريغ السلة'),
                                    content: const Text('هل أنت متأكد من تفريغ السلة؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          clearCart();
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('تم تفريغ السلة'),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppTheme.errorColor,
                                        ),
                                        child: const Text('تفريغ'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                              tooltip: 'تفريغ السلة',
                            ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: cart.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'السلة فارغة',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: cart.length,
                            separatorBuilder: (context, index) => const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final product = cart[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(product.image),
                                  radius: 24,
                                ),
                                title: Text(product.name),
                                subtitle: Text(formatter.format(product.price)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () => removeFromCart(index),
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      tooltip: 'إزالة',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  if (cart.isNotEmpty) ...[
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الإجمالي',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          formatter.format(total),
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showOrderConfirmation(context, total);
                        },
                        icon: const Icon(Icons.shopping_bag_rounded),
                        label: const Text(
                          'إتمام الطلب',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final db = DatabaseService();
  final uploadService = UploadService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;
  bool _isLoadingProducts = false;
  List<Product> _products = [];
  List<OrderModel> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadOrders();
  }

  Future<void> _loadProducts() async {
    if (!isFirebaseConnected) return;
    
    setState(() => _isLoadingProducts = true);
    final stream = db.getProductsStream();
    stream.listen((products) {
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    });
  }

  Future<void> _loadOrders() async {
    if (!isFirebaseConnected) return;
    
    final stream = db.getOrdersStream();
    stream.listen((orders) {
      setState(() => _orders = orders);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _addNewProduct() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار صورة للمنتج'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    try {
      String? imageUrl = await uploadService.uploadImage(_imageFile!);

      if (imageUrl != null) {
        await db.addProduct(Product(
          name: _nameController.text,
          price: double.parse(_priceController.text),
          image: imageUrl,
          description: _descriptionController.text,
          createdAt: DateTime.now(),
        ));
        
        _nameController.clear();
        _priceController.clear();
        _descriptionController.clear();
        setState(() {
          _imageFile = null;
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت إضافة المنتج بنجاح!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل رفع الصورة، حاول مرة أخرى'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _deleteProduct(String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: Text('هل أنت متأكد من حذف المنتج "$productName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await db.deleteProduct(productId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف المنتج "$productName"'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل حذف المنتج: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(OrderModel order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير حالة الطلب'),
        content: Text('تغيير حالة الطلب #${order.id!.substring(0, 6)} إلى "$newStatus"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await db.updateOrderStatus(order.id!, newStatus);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('تم تحديث حالة الطلب'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل تحديث حالة الطلب: $e'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(OrderModel order) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'ar_EG');
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل الطلب #${order.id!.substring(0, 6)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    'حالة الطلب:',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getStatusColor(order.status)),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'معلومات العميل:',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text(order.customerName ?? 'عميل'),
                    ],
                  ),
                  if (order.customerPhone != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 8),
                        Text(order.customerPhone!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'المنتجات (${order.items?.length ?? 0}):',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: order.items?.isEmpty ?? true
                        ? const Center(
                            child: Text('لا توجد منتجات'),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: order.items!.length,
                            separatorBuilder: (context, index) => const Divider(height: 8),
                            itemBuilder: (context, index) {
                              final item = order.items![index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(item['image']),
                                  radius: 20,
                                ),
                                title: Text(item['name']),
                                subtitle: Text(formatCurrency.format(item['price'])),
                              );
                            },
                          ),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي:',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        formatCurrency.format(order.total),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _updateOrderStatus(order, 'CANCELLED'),
                          icon: const Icon(Icons.cancel, size: 20),
                          label: const Text('إلغاء'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: AppTheme.errorColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(order, 'COMPLETED'),
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text('إتمام'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppTheme.successColor;
      case 'CANCELLED':
        return AppTheme.errorColor;
      case 'PREPARING':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'مكتمل';
      case 'CANCELLED':
        return 'ملغي';
      case 'PREPARING':
        return 'قيد التحضير';
      default:
        return 'قيد الانتظار';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم 👨‍💼')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              const Text(
                'لا يوجد اتصال بقاعدة البيانات',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'تأكد من إعدادات Firebase وحاول مرة أخرى',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                                onPressed: () {
                  setState(() {
                    _loadProducts();
                    _loadOrders();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم 👨‍💼'),
          bottom: TabBar(
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(icon: Icon(Icons.add_box), text: 'إضافة منتج'),
              Tab(icon: Icon(Icons.list_alt), text: 'الطلبات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // تبويب إضافة منتج
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppTheme.cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _imageFile != null 
                                ? AppTheme.primaryColor 
                                : Colors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                          image: _imageFile != null
                              ? DecorationImage(
                                  image: FileImage(_imageFile!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _imageFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 60,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('اضغط لاختيار صورة المنتج'),
                                ],
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم المنتج',
                        prefixIcon: Icon(Icons.cake),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'السعر',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'وصف المنتج',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _addNewProduct,
                      icon: _isUploading 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                            )
                          : const Icon(Icons.save),
                      label: Text(_isUploading ? 'جاري الحفظ...' : 'حفظ المنتج'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_products.isNotEmpty) ...[
                      const Text(
                        'المنتجات الحالية:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: CachedNetworkImageProvider(product.image),
                              ),
                              title: Text(product.name),
                              subtitle: Text('${product.price} ج.م'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(product.id!, product.name),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // تبويب الطلبات
            _orders.isEmpty
                ? const Center(child: Text('لا توجد طلبات حتى الآن'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showOrderDetails(order),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'طلب #${order.id!.substring(0, 5)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(order.status).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _getStatusText(order.status),
                                        style: TextStyle(
                                          color: _getStatusColor(order.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(order.customerName ?? 'زبون'),
                                      ],
                                    ),
                                    Text(
                                      NumberFormat.simpleCurrency(locale: 'ar_EG').format(order.total),
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt.toDate()),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
