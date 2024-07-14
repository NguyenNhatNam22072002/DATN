import 'package:flutter/material.dart';
import '../../../resources/styles_manager.dart';
import 'create_prd_tab_screens/tabs_export.dart';

import '../../../constants/color.dart';
import '../main_screen.dart';

class VendorCreateProduct extends StatefulWidget {
  const VendorCreateProduct({Key? key}) : super(key: key);

  @override
  State<VendorCreateProduct> createState() => _VendorCreateProductState();
}

class _VendorCreateProductState extends State<VendorCreateProduct>
    with SingleTickerProviderStateMixin {
  TabController? _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      length: 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabBarController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Create a product',
          textAlign: TextAlign.center, // Căn giữa
          style: getRegularStyle(
            color: Colors.black,
            fontSize: 24.0, // Tăng kích thước
            fontWeight: FontWeight.bold, // Làm đậm
          ),
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const VendorMainScreen(index: 2),
              ),
            ),
            icon: const Icon(
              Icons.chevron_left,
              color: accentColor,
            ),
          );
        }),
        backgroundColor: primaryColor,
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          isScrollable: true,
          controller: _tabBarController,
          indicatorColor: accentColor,
          tabs: const [
            Tab(child: Text('General')),
            Tab(child: Text('Shipping')),
            Tab(child: Text('Attributes')),
            Tab(child: Text('Image Uploads')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabBarController,
        children: [
          GeneralTab(
            showAlert: true,
          ),
          const ShippingTab(),
          const AttributesTab(),
          const ImageUploadTab(),
        ],
      ),
    );
  }
}
