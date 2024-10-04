import 'package:flutter/material.dart';
import 'package:projeto_incasa_app/screens/home/views/profile/profile_view.dart';
import 'package:projeto_incasa_app/screens/home/views/my_store/my_store_view.dart';
import 'package:projeto_incasa_app/screens/home/views/marketplace/marketplace_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InCasa'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          MarketplaceView(), // Página Vitrine
          MyStoreView(), // Página Minha Loja
          ProfileView(), // Página Perfil
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Vitrine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Minha Loja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
