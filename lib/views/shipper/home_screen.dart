import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shoes_shop/views/shipper/profile/profile.dart';
import 'package:shoes_shop/views/shipper/shipping/delivered_orders.dart';
import 'package:shoes_shop/views/shipper/shipping/ready_to_delivery_orders.dart';

class ShipperHomeScreen extends StatefulWidget {
  const ShipperHomeScreen({super.key});

  @override
  State<ShipperHomeScreen> createState() => _ShipperHomeScreenState();
}

class _ShipperHomeScreenState extends State<ShipperHomeScreen>
    with SingleTickerProviderStateMixin {
  String _currentAddress = "Fetching location...";
  late AnimationController _controller;
  late Animation<double> _animation;
  double earnings = 0.0;
  bool _isLoading = true;
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  String? _userId = FirebaseAuth.instance.currentUser?.uid;
  DocumentSnapshot? _credential;

  Future<void> _fetchUserDetails() async {
    try {
      // Fetching shipper details
      _credential = await _firebase.collection('shippers').doc(_userId).get();
      if (_credential != null) {
        setState(() {
          earnings = (_credential!.data() as Map<String, dynamic>)['earnings']
                  ?.toDouble() ??
              0.0;
        });
      }
    } catch (e) {
      // Handle errors if any
      print('Error fetching user details: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchUserDetails();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.grey[800],
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
        backgroundColor: Colors.grey[100],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey, Colors.grey],
          ),
        ),
      ),
      title: const Text('Home'),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // Handle notification action
          },
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage('http://i.pravatar.cc/300'),
            radius: 20,
          ),
        ),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        await _getCurrentLocation();
        await _fetchUserDetails();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationSection(),
              const SizedBox(height: 20),
              _buildEarningsSection(), // Add this line
              const SizedBox(height: 20),
              _buildGridSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEarningsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Your Earnings:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    '\$${earnings.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Current Location:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _currentAddress,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Update Location'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildGridItem(
            'Ready to Delivery', Icons.local_shipping, ReadyDeliveryScreen()),
        _buildGridItem(
            'Delivered', Icons.check_circle, const DeliveredOrdersScreen()),
        _buildGridItem('Earnings', Icons.attach_money, ProfileScreen()),
        _buildGridItem('Profile', Icons.person, ProfileScreen()),
      ],
    );
  }

  Widget _buildGridItem(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0.0);
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.lightBlueAccent],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    if (!await _checkLocationPermission()) return;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _getAddressFromPosition(position);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentAddress = "Failed to get location: $e";
      });
    }
  }

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateAddress("Location services are disabled.");
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _updateAddress("Location permissions are denied");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _updateAddress("Location permissions are permanently denied");
      return false;
    }

    return true;
  }

  Future<void> _getAddressFromPosition(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      _updateAddress(placemark.street ?? "Address not found");
    } else {
      _updateAddress("Address not found");
    }
  }

  void _updateAddress(String address) {
    if (!mounted) return;
    setState(() {
      _currentAddress = address;
    });
  }
}
