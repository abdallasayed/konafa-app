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
    // محاولة الاتصال بفايربيز يدوياً باستخدام بياناتك
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDWPN3hCNjW2arTtdrs3ueIZveHg9ie5gU",
        appId: "1:44212119840:web:8106de80c8c5abb6674f45", // ملاحظة: هذا معرف الويب، قد يعمل وقد نحتاج لتغييره لاحقاً
        messagingSenderId: "44212119840",
        projectId: "konafasystem",
        storageBucket: "konafasystem.firebasestorage.app",
      ),
    );
    isFirebaseConnected = true;
  } catch (e) {
    debugPrint("خطأ في الاتصال بفايربيز: $e");
    // التطبيق سيعمل حتى لو فشل الاتصال
    isFirebaseConnected = false;
  }
  
  runApp(const KonafaApp());
}

class AppTheme {
  static const Color primaryColor = Color(0xFFEA580C);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textColor = Color(0xFFF8FAFC);

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
        secondary: primaryColor,
        surface: cardDark,
        background: darkBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
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
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          elevation: 5,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
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
        return Directionality(textDirection: ui.TextDirection.rtl, child: child!);
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
  
  Product({this.id, required this.name, required this.price, required this.image});

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? 'https://placehold.co/400',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price, 'image': image};
  }
}

class OrderModel {
  String? id;
  double total;
  String status;
  Timestamp createdAt;

  OrderModel({this.id, required this.total, required this.status, required this.createdAt});

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'PENDING',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }
}

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    if (!isFirebaseConnected) {
      // بيانات وهمية للعرض في حالة فشل الاتصال
      return Stream.value([
        Product(id: '1', name: 'كنافة نابلسية', price: 150, image: 'https://placehold.co/600x400/ea580c/white?text=Konafa'),
        Product(id: '2', name: 'كنافة بالقشطة', price: 120, image: 'https://placehold.co/600x400/ea580c/white?text=Cream'),
        Product(id: '3', name: 'بسبوسة مكسرات', price: 90, image: 'https://placehold.co/600x400/ea580c/white?text=Basbousa'),
      ]);
    }
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  Stream<List<OrderModel>> getOrdersStream() {
    if (!isFirebaseConnected) return Stream.value([]);
    return _db.collection('orders').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> addProduct(Product product) {
    if (!isFirebaseConnected) return Future.error("لا يوجد اتصال بقاعدة البيانات");
    return _db.collection('products').add(product.toMap());
  }

  Future<void> updateOrderStatus(String orderId, String status) {
    if (!isFirebaseConnected) return Future.error("لا يوجد اتصال");
    return _db.collection('orders').doc(orderId).update({'status': status});
  }

  Future<void> placeOrder(double total, List<Product> cartItems) {
    if (!isFirebaseConnected) return Future.error("لا يوجد اتصال");
    return _db.collection('orders').add({
      'total': total,
      'status': 'PENDING',
      'createdAt': Timestamp.now(),
      'itemsCount': cartItems.length,
    });
  }
}

class UploadService {
  static const String UPLOADCARE_PUB_KEY = "8e2cb6a00c4b7dd45f95";

  Future<String?> uploadImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://upload.uploadcare.com/base/'));
      request.fields['UPLOADCARE_PUB_KEY'] = UPLOADCARE_PUB_KEY;
      request.fields['UPLOADCARE_STORE'] = '1';
      
      var multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonResponse = json.decode(responseString);
        return "https://ucarecdn.com/${jsonResponse['file']}/";
      } else {
        return null;
      }
    } catch (e) {
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

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} أضيفت للسلة! 🛒'), backgroundColor: AppTheme.primaryColor,)
    );
  }

  void clearCart() {
    setState(() {
      cart.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(addToCart: addToCart, cart: cart, clearCart: clearCart),
      const AdminScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.cardDark,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: 'الإدارة'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final Function(Product) addToCart;
  final VoidCallback clearCart;
  final List<Product> cart;
  final db = DatabaseService();

  HomeScreen({super.key, required this.addToCart, required this.cart, required this.clearCart});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(locale: 'ar_EG');

    return Scaffold(
      appBar: AppBar(
        title: const Text('كنافة بالقشطة 🥧'),
        actions: [
          if (!isFirebaseConnected)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.wifi_off, color: Colors.red),
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: () {
                   if (cart.isNotEmpty) _showCartBottomSheet(context, formatCurrency);
                },
                icon: const Icon(Icons.shopping_cart_rounded),
              ),
              if (cart.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${cart.length}', style: const TextStyle(fontSize: 10)),
                  ),
                )
            ],
          )
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: db.getProductsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = snapshot.data ?? [];
          
          if (products.isEmpty) return const Center(child: Text('لا توجد منتجات حالياً'));

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
                  placeholder: (context, url) => Container(color: AppTheme.cardDark, child: const Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Container(color: AppTheme.cardDark, child: const Icon(Icons.error)),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      )
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatter.format(product.price), style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, fontSize: 16)),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 18,
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white, size: 20),
                    padding: EdgeInsets.zero,
                    onPressed: () => addToCart(product),
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
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ملخص الطلب (${cart.length})', style: Theme.of(context).textTheme.headlineSmall),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))
                ],
              ),
              const Divider(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي', style: TextStyle(fontSize: 18)),
                  Text(formatter.format(total), style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (isFirebaseConnected) {
                       await db.placeOrder(total, cart);
                       clearCart();
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('تم إرسال طلبك بنجاح! 🎉'), backgroundColor: Colors.green)
                       );
                    } else {
                       ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text('وضع العرض فقط: لم يتم حفظ الطلب'), backgroundColor: Colors.orange)
                       );
                    }
                  },
                  child: const Text('تأكيد الطلب الآن'),
                ),
              )
            ],
          ),
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
  
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم 👨‍💼')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              const Text("لا يوجد اتصال بقاعدة البيانات", style: TextStyle(fontSize: 18)),
              const Text("تأكد من إعدادات Firebase للأندرويد", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم 👨‍💼'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddProductSection(),
            const SizedBox(height: 30),
             Text('الطلبات الحديثة', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إضافة منتج جديد', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'اسم المنتج', prefixIcon: Icon(Icons.cake))),
            const SizedBox(height: 16),
            TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'السعر', prefixIcon: Icon(Icons.monetization_on))),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                  image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_rounded, size: 50, color: AppTheme.primaryColor),
                    const SizedBox(height: 8),
                    const Text('اضغط لاختيار صورة المنتج'),
                  ],
                ) : null,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _addNewProduct,
                icon: _isUploading ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.add),
                label: Text(_isUploading ? 'جاري الرفع...' : 'إضافة للمنيو'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return StreamBuilder<List<OrderModel>>(
      stream: db.getOrdersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text('خطأ: ${snapshot.error}');
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!;
        if (orders.isEmpty) return const Text('لا توجد طلبات');

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.darkBackground,
                  child: Icon(Icons.receipt, color: AppTheme.primaryColor),
                ),
                title: Text('طلب #${order.id.toString().substring(0, 4)}'),
                subtitle: Text(DateFormat('dd/MM/yyyy hh:mm a').format(order.createdAt.toDate())),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${order.total} ج.م', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _buildStatusBadge(order.status),
                  ],
                ),
                onTap: () => _showOrderStatusDialog(order),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'COMPLETED': color = Colors.green; text = 'مكتمل'; break;
      case 'CANCELLED': color = Colors.red; text = 'ملغي'; break;
      default: color = Colors.orange; text = 'قيد الانتظار';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _addNewProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء جميع الحقول واختيار صورة')));
      return;
    }

    setState(() => _isUploading = true);
    String? imageUrl = await uploadService.uploadImage(_imageFile!);

    if (imageUrl != null) {
      await db.addProduct(Product(
        name: _nameController.text,
        price: double.parse(_priceController.text),
        image: imageUrl,
      ));
      
      _nameController.clear();
      _priceController.clear();
      setState(() {
        _imageFile = null;
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة المنتج بنجاح!'), backgroundColor: Colors.green));
    } else {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل رفع الصورة'), backgroundColor: Colors.red));
    }
  }

  void _showOrderStatusDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير حالة الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('مكتمل'),
              onTap: () {
                db.updateOrderStatus(order.id!, 'COMPLETED');
                Navigator.pop(context);
              },
            ),
             ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('إلغاء الطلب'),
              onTap: () {
                db.updateOrderStatus(order.id!, 'CANCELLED');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
