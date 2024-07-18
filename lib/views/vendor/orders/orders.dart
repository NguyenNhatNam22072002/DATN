import 'package:flutter/material.dart';
import '../../../constants/color.dart';
import '../../../resources/styles_manager.dart';
import 'orders_tab/orders_tab_export.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      length: 5,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabBarController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ordered Products',
              textAlign: TextAlign.center,
              style: getRegularStyle(
                color: Colors.black,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: primaryColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: TabBar(
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              controller: _tabBarController,
              indicatorColor: accentColor,
              tabs: const [
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pending),
                      SizedBox(height: 2.0),
                      Text(
                        'Pending',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(height: 2.0),
                      Text(
                        'Approved',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_top),
                      SizedBox(height: 2.0),
                      Text(
                        'Processing',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping),
                      SizedBox(height: 2.0),
                      Text(
                        'Delivering',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.done_all),
                      SizedBox(height: 2.0),
                      Text(
                        'Delivered',
                        style: TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabBarController,
        children: const [
          PendingOrders(),
          ApprovedOrders(),
          ProcessingOrders(),
          DeliveringOrders(),
          DeliveredOrders(),
        ],
      ),
    );
  }
}
