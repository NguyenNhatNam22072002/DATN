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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ordered Products',
              textAlign: TextAlign.center, // Căn giữa
              style: getRegularStyle(
                color: Colors.black,
                fontSize: 24.0, // Tăng kích thước
                fontWeight: FontWeight.bold, // Làm đậm
              ),
            ),
          ],
        ),

        backgroundColor: primaryColor,
        bottom: PreferredSize(
              preferredSize: Size.fromHeight(35.0), // Đặt chiều cao là 0 để ẩn bottom
              child: Container(
                padding: EdgeInsets.only(bottom: 2.0), // Điều chỉnh giá trị này để làm cho mặt dưới gần các Tab hơn
                child: TabBar(
                      controller: _tabBarController,
                      indicatorColor: accentColor,
                      tabs: const [
                        Tab(child: Text(
                          'Approved',
                          style: TextStyle(
                            fontSize: 10.6,
                          ),
                        )
                        ),
                        Tab(child: Text('Unapproved',
                          style: TextStyle(
                            fontSize: 10.5,
                          ),
                        )
                        ),
                        Tab(child: Text('Undelivered',
                          style: TextStyle(
                            fontSize: 10.5,
                          ),
                        )
                        ),
                        Tab(child: Text('Delivered',
                          style: TextStyle(
                            fontSize: 10.5,
                          ),
                        )
                        ),
                      ],
                    ),
                  ),
                ),
      ),
      body: TabBarView(
        controller: _tabBarController,
        children: const [
          ApprovedOrders(),
          UnApprovedOrders(),
          UnDeliveredOrders(),
          DeliveredOrders(),
        ],
      ),
    );
  }
}
