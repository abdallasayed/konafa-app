import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============ إعدادات التطبيق ============
class AppConfig {
  static const String appName = 'كنافة بالقشطة';
  static const String appVersion = '1.0.0';
  static const String currency = 'ج.م';
  
  // إعدادات المتجر
  static String storeName = 'كنافة بالقشطة';
  static String storePhone = '+201234567890';
  static String storeAddress = 'القاهرة، مصر';
  static String storeEmail = 'info@konafa.com';
  
  // ساعات العمل
  static Map<String, String> workingHours = {
    'الأحد': '8:00 ص - 12:00 م',
    'الإثنين': '8:00 ص - 12:00 م',
    'الثلاثاء': '8:00 ص - 12:00 م',
    'الأربعاء': '8:00 ص - 12:00 م',
    'الخميس': '8:00 ص - 12:00 م',
    'الجمعة': '4:00 م - 12:00 م',
    'السبت': '8:00 ص - 12:00 م',
  };
}

// ============ متغير الاتصال ============
bool isFirebaseConnected = false;
User? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة SharedPreferences
  await SharedPreferences.getInstance();
  
  try {
    // محاولة الاتصال بفايربيز
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDWPN3hCNjW2arTtdrs3ueIZveHg9ie5gU",
        appId: "1:44212119840:android:YOUR_ANDROID_APP_ID_HERE",
        messagingSenderId: "44212119840",
        projectId: "konafasystem",
        storageBucket: "konafasystem.firebasestorage.app",
      ),
    );
    isFirebaseConnected = true;
    print("✅ تم الاتصال بـ Firebase بنجاح");
  } catch (e) {
    print("❌ خطأ في الاتصال بفايربيز: $e");
    isFirebaseConnected = false;
  }
  
  runApp(const KonafaApp());
}

// ============ ثيم التطبيق ============
class AppTheme {
  static const Color primaryColor = Color(0xFFEA580C);
  static const Color secondaryColor = Color(0xFFF97316);
  static const Color accentColor = Color(0xFFFFEDD5);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

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
        onPrimary: Colors.white,
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
        elevation: 6,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(color: Colors.grey[400]),
        labelStyle: const TextStyle(color: textColor, fontSize: 16),
        errorStyle: const TextStyle(color: errorColor, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primaryColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w600),
          elevation: 6,
          shadowColor: primaryColor.withOpacity(0.4),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.cairo(fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 11),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey[700]!.withOpacity(0.5),
        thickness: 1,
        space: 20,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        circularTrackColor: cardDark,
      ),
    );
  }
}

// ============ تطبيق كنافة ============
class KonafaApp extends StatelessWidget {
  const KonafaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: ui.TextDirection.rtl, 
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ============ شاشة الترحيب ============
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
    
    // الانتقال بعد 2 ثانية
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الشعار
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.cake_rounded,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // الاسم
              Text(
                AppConfig.appName,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              // الشعار
              Text(
                '🥧 أطيب كنافة في الوطن العربي',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 50),
              // مؤشر التحميل
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryColor,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ شاشة المصادقة ============
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  
  // متغيرات تسجيل الدخول
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _loginPasswordVisible = false;
  bool _isLoggingIn = false;
  
  // متغيرات التسجيل
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerPhoneController = TextEditingController();
  bool _registerPasswordVisible = false;
  bool _isRegistering = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    if (_auth.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoggingIn = true);
    
    try {
      await _auth.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'البريد الإلكتروني غير مسجل';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'user-disabled':
          errorMessage = 'الحساب معطل';
          break;
        default:
          errorMessage = 'حدث خطأ، حاول مرة أخرى';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('حدث خطأ غير متوقع');
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isRegistering = true);
    
    try {
      // إنشاء الحساب
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
      );
      
      // حفظ بيانات المستخدم في Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'uid': credential.user!.uid,
            'email': _registerEmailController.text.trim(),
            'name': _registerNameController.text.trim(),
            'phone': _registerPhoneController.text.trim(),
            'createdAt': DateTime.now(),
            'role': 'customer', // customer, admin, employee
            'points': 0,
            'totalSpent': 0,
          });
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'البريد الإلكتروني مستخدم بالفعل';
          break;
        case 'weak-password':
          errorMessage = 'كلمة المرور ضعيفة، يجب أن تكون 6 أحرف على الأقل';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صالح';
          break;
        default:
          errorMessage = 'حدث خطأ، حاول مرة أخرى';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('حدث خطأ غير متوقع');
    } finally {
      setState(() => _isRegistering = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // الشعار
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.cake_rounded,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppConfig.appName,
                  style: GoogleFonts.cairo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'مرحباً بك في متجرنا',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 30),
                
                // TabBar
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppTheme.primaryColor,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    tabs: const [
                      Tab(text: 'تسجيل الدخول'),
                      Tab(text: 'إنشاء حساب'),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                
                // TabBarView
                SizedBox(
                  height: 550,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // تسجيل الدخول
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _loginEmailController,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: Icon(Icons.email_rounded),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'البريد الإلكتروني غير صالح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _loginPasswordController,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _loginPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _loginPasswordVisible = !_loginPasswordVisible;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: !_loginPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: إعادة تعيين كلمة المرور
                                },
                                child: const Text('نسيت كلمة المرور؟'),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isLoggingIn ? null : _login,
                                icon: _isLoggingIn
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: Text(_isLoggingIn ? 'جاري تسجيل الدخول...' : 'تسجيل الدخول'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // إنشاء حساب
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _registerNameController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم بالكامل',
                                prefixIcon: Icon(Icons.person_rounded),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الاسم';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _registerEmailController,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: Icon(Icons.email_rounded),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'البريد الإلكتروني غير صالح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _registerPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'رقم الهاتف',
                                prefixIcon: Icon(Icons.phone_rounded),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رقم الهاتف';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _registerPasswordController,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _registerPasswordVisible
                                        ? Icons.visibility_off_rounded
                                        : Icons.visibility_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _registerPasswordVisible = !_registerPasswordVisible;
                                    });
                                  },
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: !_registerPasswordVisible,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'بإنشائك للحساب فإنك توافق على الشروط والأحكام',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isRegistering ? null : _register,
                                icon: _isRegistering
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.person_add_rounded),
                                label: Text(_isRegistering ? 'جاري إنشاء الحساب...' : 'إنشاء حساب'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerNameController.dispose();
    _registerPhoneController.dispose();
    super.dispose();
  }
}

// ============ نموذج المنتج ============
class Product {
  String? id;
  String name;
  double price;
  String image;
  String? description;
  String? category;
  int stock;
  bool isAvailable;
  double? discount;
  double? rating;
  int reviewCount;
  DateTime createdAt;
  List<String>? tags;
  
  Product({
    this.id,
    required this.name,
    required this.price,
    required this.image,
    this.description,
    this.category = 'حلويات',
    this.stock = 100,
    this.isAvailable = true,
    this.discount,
    this.rating,
    this.reviewCount = 0,
    DateTime? createdAt,
    this.tags,
  }) : createdAt = createdAt ?? DateTime.now();

  double get discountedPrice {
    if (discount != null && discount! > 0) {
      return price - (price * discount! / 100);
    }
    return price;
  }

  bool get hasDiscount => discount != null && discount! > 0;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? 'https://placehold.co/600x400/ea580c/white?text=Product',
      description: data['description'],
      category: data['category'] ?? 'حلويات',
      stock: (data['stock'] ?? 100).toInt(),
      isAvailable: data['isAvailable'] ?? true,
      discount: (data['discount'] ?? 0).toDouble(),
      rating: (data['rating'] ?? 0).toDouble(),
      reviewCount: (data['reviewCount'] ?? 0).toInt(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category': category,
      'stock': stock,
      'isAvailable': isAvailable,
      'discount': discount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'tags': tags,
      'updatedAt': DateTime.now(),
    };
  }
}

// ============ نموذج الطلب ============
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

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
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
}

// ============ نموذج المستخدم ============
class UserModel {
  String uid;
  String email;
  String name;
  String phone;
  String? profileImage;
  String role;
  int points;
  double totalSpent;
  List<String>? addresses;
  List<String>? favoriteProducts;
  DateTime createdAt;
  DateTime? lastLogin;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImage,
    this.role = 'customer',
    this.points = 0,
    this.totalSpent = 0,
    this.addresses,
    this.favoriteProducts,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      role: data['role'] ?? 'customer',
      points: (data['points'] ?? 0).toInt(),
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      addresses: data['addresses'] != null ? List<String>.from(data['addresses']) : [],
      favoriteProducts: data['favoriteProducts'] != null ? List<String>.from(data['favoriteProducts']) : [],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: data['lastLogin']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'points': points,
      'totalSpent': totalSpent,
      'addresses': addresses,
      'favoriteProducts': favoriteProducts,
      'createdAt': createdAt,
      'lastLogin': lastLogin ?? DateTime.now(),
    };
  }
}

// ============ خدمة قاعدة البيانات ============
class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // المنتجات
  Stream<List<Product>> getProductsStream({String? category}) {
    if (!isFirebaseConnected) {
      return Stream.value(_getDemoProducts());
    }
    
    Query query = _db.collection('products').where('isAvailable', isEqualTo: true);
    
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    
    return query
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
      });
  }

  List<Product> _getDemoProducts() {
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
      Product(
        id: '4',
        name: 'قطايف محشوة',
        price: 80,
        image: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&auto=format&fit=crop',
        description: 'قطايف محشوة بالمكسرات',
        category: 'حلويات',
        stock: 40,
        rating: 4.6,
        reviewCount: 45,
      ),
    ];
  }

  // الطلبات
  Stream<List<OrderModel>> getOrdersStream({String? status, String? userId}) {
    if (!isFirebaseConnected) return Stream.value([]);
    
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
        return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      });
  }

  // المستخدمين
  Stream<UserModel?> getUserStream(String userId) {
    if (!isFirebaseConnected) return Stream.value(null);
    
    return _db.collection('users').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromFirestore(snapshot);
    });
  }

  // الإحصائيات
  Future<Map<String, dynamic>> getStatistics() async {
    if (!isFirebaseConnected) {
      return {
        'totalOrders': 0,
        'totalRevenue': 0,
        'totalProducts': 0,
        'totalCustomers': 0,
      };
    }
    
    // يمكن إضافة استعلامات حقيقية هنا
    return {
      'totalOrders': 0,
      'totalRevenue': 0,
      'totalProducts': 0,
      'totalCustomers': 0,
    };
  }

  // CRUD Operations
  Future<void> addProduct(Product product) async {
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
    await _db.collection('products').doc(productId).update(updates);
  }

  Future<void> deleteProduct(String productId) async {
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
    await _db.collection('products').doc(productId).delete();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
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
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
    
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

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    if (!isFirebaseConnected) throw Exception("لا يوجد اتصال");
    await _db.collection('users').doc(userId).update(updates);
  }
}

// ============ خدمة رفع الصور ============
class UploadService {
  static const String UPLOADCARE_PUB_KEY = "8e2cb6a00c4b7dd45f95";
  static const String UPLOADCARE_UPLOAD_URL = "https://upload.uploadcare.com/base/";

  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(UPLOADCARE_UPLOAD_URL));
      request.fields['UPLOADCARE_PUB_KEY'] = UPLOADCARE_PUB_KEY;
      request.fields['UPLOADCARE_STORE'] = '1';
      
      if (folder != null) {
        request.fields['UPLOADCARE_STORE'] = folder;
      }
      
      var multipartFile = await http.MultipartFile.fromPath('file', imageFile.path);
      request.files.add(multipartFile);

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        return "https://ucarecdn.com/${jsonResponse['file']}/";
      }
      return null;
    } catch (e) {
      print("❌ خطأ في رفع الصورة: $e");
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    List<String> urls = [];
    for (var imageFile in imageFiles) {
      final url = await uploadImage(imageFile);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }
}

// ============ خدمة التخزين المحلي ============
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // حفظ بيانات المستخدم
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString('user_data', json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = _prefs.getString('user_data');
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // السلة المحلية
  Future<void> saveCart(List<Map<String, dynamic>> cartItems) async {
    await _prefs.setString('cart', json.encode(cartItems));
  }

  Future<List<Map<String, dynamic>>> getCart() async {
    final data = _prefs.getString('cart');
    if (data != null) {
      return List<Map<String, dynamic>>.from(json.decode(data));
    }
    return [];
  }

  // المفضلة
  Future<void> saveFavorites(List<String> favoriteIds) async {
    await _prefs.setStringList('favorites', favoriteIds);
  }

  Future<List<String>> getFavorites() async {
    return _prefs.getStringList('favorites') ?? [];
  }

  // إعدادات التطبيق
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _prefs.setString('settings', json.encode(settings));
  }

  Future<Map<String, dynamic>> getSettings() async {
    final data = _prefs.getString('settings');
    if (data != null) {
      return json.decode(data) as Map<String, dynamic>;
    }
    return {
      'notifications': true,
      'darkMode': true,
      'language': 'ar',
    };
  }

  // مسح جميع البيانات
  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}

// ============ الشاشة الرئيسية مع التنقل ============
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  List<Product> cart = [];
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final DatabaseService db = DatabaseService();
  final LocalStorageService localStorage = LocalStorageService();
  UserModel? currentUser;
  StreamSubscription? _userSubscription;

  @override
  void initState() {
    super.initState();
    _initServices();
    _loadCart();
  }

  Future<void> _initServices() async {
    await localStorage.init();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSubscription = db.getUserStream(user.uid).listen((userModel) {
        setState(() {
          currentUser = userModel;
        });
      });
    }
  }

  Future<void> _loadCart() async {
    final cartData = await localStorage.getCart();
    // يمكن تحويل cartData إلى List<Product> هنا
  }

  void addToCart(Product product) {
    setState(() {
      cart.add(product);
    });
    _showSnackBar('${product.name} أضيفت للسلة! 🛒');
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

  void _showSnackBar(String message, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<Widget> _getPages() {
    final userRole = currentUser?.role ?? 'customer';
    
    if (userRole == 'admin' || userRole == 'employee') {
      // للموظفين والإدارة
      return [
        HomeScreen(
          addToCart: addToCart,
          cart: cart,
          clearCart: clearCart,
          removeFromCart: removeFromCart,
          user: currentUser,
        ),
        const OrdersScreen(),
        const ProductsScreen(),
        AdminScreen(user: currentUser),
      ];
    } else {
      // للعملاء
      return [
        HomeScreen(
          addToCart: addToCart,
          cart: cart,
          clearCart: clearCart,
          removeFromCart: removeFromCart,
          user: currentUser,
        ),
        const SearchScreen(),
        const CartScreen(),
        ProfileScreen(user: currentUser),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    final userRole = currentUser?.role ?? 'customer';
    
    if (userRole == 'admin' || userRole == 'employee') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'الطلبات'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'المنتجات'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: 'الإدارة'),
      ];
    } else {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'البحث'),
        BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded), label: 'السلة'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'حسابي'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages();
    final navItems = _getBottomNavItems();

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
                blurRadius: 15,
                spreadRadius: 3,
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
              type: BottomNavigationBarType.fixed,
              elevation: 8,
              items: navItems,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

// ============ شاشة الرئيسية ============
class HomeScreen extends StatelessWidget {
  final Function(Product) addToCart;
  final VoidCallback clearCart;
  final Function(int) removeFromCart;
  final List<Product> cart;
  final UserModel? user;
  final DatabaseService db = DatabaseService();
  
  HomeScreen({
    super.key,
    required this.addToCart,
    required this.cart,
    required this.clearCart,
    required this.removeFromCart,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('كنافة بالقشطة 🥧'),
        actions: [
          if (!isFirebaseConnected)
            Tooltip(
              message: 'وضع العرض فقط',
              child: const Icon(Icons.wifi_off, color: Colors.red),
            ),
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Text(
                  user!.name[0],
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: const HomeContent(),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // بانر العرض
        _buildPromoBanner(),
        
        // الأقسام
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الفئات
              _buildCategories(),
              const SizedBox(height: 24),
              
              // المنتجات المميزة
              _buildFeaturedProducts(),
              
              // العروض الخاصة
              _buildSpecialOffers(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خصم ٢٠٪',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'على كل أنواع الكنافة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('اطلب الآن'),
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            bottom: 20,
            child: Icon(
              Icons.cake_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['كل المنتجات', 'كنافة', 'حلويات', 'مشروبات', 'مكسرات'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيفات',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Chip(
                  label: Text(categories[index]),
                  backgroundColor: index == 0 
                      ? AppTheme.primaryColor 
                      : AppTheme.cardDark,
                  labelStyle: TextStyle(
                    color: index == 0 ? Colors.white : Colors.grey[400],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المنتجات المميزة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // هنا يمكن عرض قائمة المنتجات المميزة
      ],
    );
  }

  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'العروض الخاصة',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // هنا يمكن عرض العروض الخاصة
      ],
    );
  }
}

// ============ شاشة البحث ============
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'ابحث عن منتج...',
            prefixIcon: const Icon(Icons.search_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppTheme.cardDark.withOpacity(0.5),
          ),
        ),
      ),
      body: ListView(
        children: [
          // نتائج البحث
        ],
      ),
    );
  }
}

// ============ شاشة السلة ============
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // عناصر السلة
              ],
            ),
          ),
          // ملخص الطلب
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإجمالي'),
                    Text(
                      '٠ ج.م',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shopping_bag_rounded),
                    label: const Text('إتمام الطلب'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ شاشة الملف الشخصي ============
class ProfileScreen extends StatelessWidget {
  final UserModel? user;
  
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // معلومات المستخدم
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                child: Icon(
                  Icons.person_rounded,
                  color: AppTheme.primaryColor,
                ),
              ),
              title: Text(user?.name ?? 'زائر'),
              subtitle: Text(user?.email ?? ''),
              trailing: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.edit_rounded),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // القائمة
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: const Text('طلباتي'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded),
                  title: const Text('المفضلة'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  title: const Text('العناوين'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.notifications_rounded),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('الإعدادات'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // زر تسجيل الخروج
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                );
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('تسجيل الخروج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor.withOpacity(0.2),
                foregroundColor: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ شاشة الطلبات ============
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات')),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'الكل'),
                Tab(text: 'قيد الانتظار'),
                Tab(text: 'قيد التجهيز'),
                Tab(text: 'مكتمل'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // كل الطلبات
                  _buildOrdersList(),
                  // الطلبات قيد الانتظار
                  _buildOrdersList(),
                  // الطلبات قيد التجهيز
                  _buildOrdersList(),
                  // الطلبات المكتملة
                  _buildOrdersList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.receipt_rounded, color: Colors.green),
            ),
            title: const Text('طلب #12345'),
            subtitle: const Text('١٢/٠١/٢٠٢٤ - ١٥٠ ج.م'),
            trailing: const Chip(
              label: Text('مكتمل'),
              backgroundColor: Colors.green,
              labelStyle: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

// ============ شاشة المنتجات ============
class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المنتجات'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?w=600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'كنافة نابلسية',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '١٥٠ ج.م',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
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
    );
  }
}

// ============ شاشة الإدارة ============
class AdminScreen extends StatefulWidget {
  final UserModel? user;
  
  const AdminScreen({super.key, this.user});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة التحكم'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.dashboard_rounded), text: 'لوحة التحكم'),
              Tab(icon: Icon(Icons.inventory_2_rounded), text: 'المنتجات'),
              Tab(icon: Icon(Icons.receipt_long_rounded), text: 'الطلبات'),
              Tab(icon: Icon(Icons.people_rounded), text: 'العملاء'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // لوحة التحكم
            _buildDashboard(),
            // إدارة المنتجات
            _buildProductsManagement(),
            // إدارة الطلبات
            _buildOrdersManagement(),
            // إدارة العملاء
            _buildCustomersManagement(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // الإحصائيات
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildStatCard('المبيعات اليومية', '١٢٥٠ ج.م', Icons.attach_money_rounded, Colors.green),
            _buildStatCard('عدد الطلبات', '٤٨', Icons.receipt_rounded, Colors.blue),
            _buildStatCard('العملاء الجدد', '١٢', Icons.person_add_rounded, Colors.orange),
            _buildStatCard('المخزون', '٢٣٤', Icons.inventory_2_rounded, Colors.purple),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // الطلبات الأخيرة
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلبات الأخيرة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        child: const Icon(Icons.receipt_rounded, color: Colors.orange),
                      ),
                      title: const Text('طلب #12346'),
                      subtitle: const Text('كنافة بالقشطة × ٢'),
                      trailing: const Chip(
                        label: Text('قيد الانتظار'),
                        backgroundColor: Colors.orange,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // المنتجات الأكثر مبيعاً
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المنتجات الأكثر مبيعاً',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // قائمة المنتجات
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsManagement() {
    return Scaffold(
      body: ListView(
        children: [
          // هنا إدارة المنتجات
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildOrdersManagement() {
    return Scaffold(
      body: ListView(
        children: [
          // هنا إدارة الطلبات
        ],
      ),
    );
  }

  Widget _buildCustomersManagement() {
    return Scaffold(
      body: ListView(
        children: [
          // هنا إدارة العملاء
        ],
      ),
    );
  }
}

// ============ صفحة حول التطبيق ============
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.cake_rounded,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConfig.appName,
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'الإصدار ${AppConfig.appVersion}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'تطبيق كنافة بالقشطة هو تطبيق متخصص في بيع الحلويات الشرقية عالية الجودة. نحن نقدم أفضل أنواع الكنافة والحلويات الشرقية بأسعار مناسبة وخدمة توصيل سريعة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.store_rounded),
                  title: const Text('معلومات المتجر'),
                  subtitle: Text(AppConfig.storeName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_rounded),
                  title: const Text('الهاتف'),
                  subtitle: Text(AppConfig.storePhone),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_rounded),
                  title: const Text('البريد الإلكتروني'),
                  subtitle: Text(AppConfig.storeEmail),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_on_rounded),
                  title: const Text('العنوان'),
                  subtitle: Text(AppConfig.storeAddress),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ساعات العمل',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: AppConfig.workingHours.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(entry.value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('الشروط والأحكام'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('سياسة الخصوصية'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('اتصل بنا'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
