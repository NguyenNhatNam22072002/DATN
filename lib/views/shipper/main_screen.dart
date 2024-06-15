import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:provider/provider.dart';
import 'package:shoes_shop/views/shipper/home_screen.dart';
import 'package:shoes_shop/views/shipper/shipping/delivered_orders.dart';
import 'package:shoes_shop/views/shipper/profile/profile.dart';
import 'package:shoes_shop/views/shipper/shipping/ready_to_delivery_orders.dart';
import '../../providers/cart.dart';
import '../../constants/color.dart';

class ShipperMainScreen extends StatefulWidget {
  const ShipperMainScreen({super.key, required this.index});
  final int index;

  @override
  State<ShipperMainScreen> createState() => _ShipperMainStateScreen();
}

class _ShipperMainStateScreen extends State<ShipperMainScreen> {
  var _pageIndex = 0;
  final List<Widget> _pages = const [
    ShipperHomeScreen(),
    ReadyDeliveryScreen(),
    DeliveredOrdersScreen(),
    ProfileScreen(),
  ];

  void setNewPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  @override
  void initState() {
    if (widget.index != 0) {
      setNewPage(widget.index);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    CartProvider cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: primaryColor,
        activeColor: Colors.white,
        style: TabStyle.reactCircle,
        initialActiveIndex: _pageIndex,
        items: [
          buildTabItem(Icons.home, 0),
          buildTabItem(Icons.local_shipping, 1),
          buildTabItem(Icons.local_shipping_outlined, 2),
          buildTabItem(Icons.person, 3),
        ],
        onTap: setNewPage,
      ),
      body: _pages[_pageIndex],
    );
  }

  // custom tab item
  TabItem<dynamic> buildTabItem(IconData icon, int pageIndex) {
    return TabItem(
      icon: Icon(
        icon,
        color: accentColor,
        size: _pageIndex == pageIndex ? 40 : 25,
      ),
    );
  }
}
