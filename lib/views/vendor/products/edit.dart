import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoes_shop/resources/font_manager.dart';
import '../../../models/product.dart';
import '../../../providers/product.dart';
import '../../../resources/styles_manager.dart';
import 'edit_prd_tab_screens/tabs_export.dart';

import '../../../constants/color.dart';
import '../main_screen.dart';

class VendorEditProduct extends StatefulWidget {
  const VendorEditProduct({Key? key, required this.product}) : super(key: key);
  final Product product;

  @override
  State<VendorEditProduct> createState() => _VendorEditProductState();
}

class _VendorEditProductState extends State<VendorEditProduct>
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
    final productProvider = Provider.of<ProductData>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Editing ${widget.product.productName}',
            style: getMediumStyle(
              color: Colors.black,
              fontSize: FontSize.s16,
            ),
          ),
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () => {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const VendorMainScreen(index: 2),
                  ),
                ),
              },
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
            EditGeneralTab(
              showAlert: true,
              product: widget.product,
            ),
            EditShippingTab(product: widget.product),
            EditAttributesTab(product: widget.product),
            EditImageUploadTab(
              product: widget.product,
              productProvider: productProvider,
            ),
          ],
        ),
      ),
    );
  }
}
