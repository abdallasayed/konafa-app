import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// تم استيراد المكونات من الملفات المنفصلة
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/main_navigation_screen.dart';

// ============ متغير الاتصال ============
bool isFirebaseConnected = false;
User? currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
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

// ============ تطبيق كنافة ============
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
      home: const SplashScreen(),
    );
  }
}
