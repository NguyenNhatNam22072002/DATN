import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shoes_shop/views/customer/favorite/favorite.dart';
import '../../providers/cart.dart';
import 'categories/categories.dart';
import 'profile/profile.dart';
import 'search/search.dart';
import '../../constants/color.dart';
import 'cart/cart.dart';
import 'home_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key, required this.index});
  final int index;

  @override
  State<CustomerMainScreen> createState() => _CustomerMainStateScreen();
}

class _CustomerMainStateScreen extends State<CustomerMainScreen> {
  late int _pageIndex;
  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    CategoriesScreen(),
    FavoriteProducts(),
    SearchScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.index != 0 ? widget.index : 0;
  }

  void _setNewPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColor,
        activeColor: Colors.white,
        style: TabStyle.reactCircle,
        initialActiveIndex: _pageIndex,
        items: [
          _buildTabItem(Icons.home, 0),
          _buildTabItem(Icons.category_outlined, 1),
          _buildTabItem(Icons.favorite_border, 2),
          _buildTabItem(Icons.search, 3),
          _buildCartTabItem(cartProvider),
          _buildTabItem(Icons.person, 5),
        ],
        onTap: _setNewPage,
      ),
      body: _pages[_pageIndex],
    );
  }

  TabItem<dynamic> _buildTabItem(IconData icon, int pageIndex) {
    return TabItem(
      icon: Icon(
        icon,
        color: accentColor,
        size: _pageIndex == pageIndex ? 40 : 25,
      ),
    );
  }

  TabItem<dynamic> _buildCartTabItem(CartProvider cartProvider) {
    return TabItem(
      icon: Badge(
        backgroundColor: Colors.white,
        label: Text(
          '${cartProvider.getCartQuantity}',
          style: const TextStyle(color: Colors.black),
        ),
        child: Icon(
          Icons.shopping_cart,
          size: _pageIndex == 4 ? 40 : 25,
          color: accentColor,
        ),
      ),
    );
  }
}
