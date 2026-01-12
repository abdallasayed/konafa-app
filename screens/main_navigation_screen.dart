import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  List<Widget> _getPages() {
    if (currentUser?.email == 'admin@konafa.com') {
      // للمسؤول
      return [
        const HomeScreen(),
        Container(), // مكان للطلبات
        Container(), // مكان للمنتجات
        const AdminScreen(),
      ];
    } else {
      // للعملاء
      return [
        const HomeScreen(),
        Container(), // مكان للبحث
        Container(), // مكان للسلة
        ProfileScreen(user: currentUser),
      ];
    }
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    if (currentUser?.email == 'admin@konafa.com') {
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

    return Scaffold(
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
            backgroundColor: AppColors.cardDark,
            selectedItemColor: AppColors.primaryColor,
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
    );
  }
}
