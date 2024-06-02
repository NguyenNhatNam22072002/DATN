import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/views/customer/main_screen.dart';
import '../../../constants/color.dart';
import '../../../controllers/route_manager.dart';
import '../../../resources/assets_manager.dart';
import '../../widgets/k_tile.dart';
import '../../widgets/loading_widget.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String _userId;
  DocumentSnapshot? _credential;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      _credential = await _firebase.collection('customers').doc(_userId).get();
    } catch (e) {
      // Handle errors
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    await _fetchUserDetails();
  }

  void _showLogoutOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Image.asset(
              AssetManager.avatar,
              width: 35,
            ),
            const Text(
              'Logout Account',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _logout,
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    _auth.signOut();
    Navigator.of(context).pushNamed(RouteManager.accountType);
  }

  void _editProfile() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const EditProfile()))
        .then((_) => _fetchUserDetails());
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.black,
      backgroundColor: Colors.white,
      child: _isLoading
          ? const Center(
              child: LoadingWidget(size: 50),
            )
          : CustomScrollView(
              slivers: [
                const SliverAppBar(
                  automaticallyImplyLeading: false,
                  title: Center(
                    child: Text(
                      'My Profile',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  expandedHeight: 50,
                  backgroundColor: Colors.white,
                ),
                SliverAppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  expandedHeight: 130,
                  backgroundColor: Colors.black54,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      return FlexibleSpaceBar(
                        titlePadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        title: AnimatedOpacity(
                          opacity: constraints.biggest.height <= 120 ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: primaryColor,
                                backgroundImage: NetworkImage(
                                  _credential!['image'],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                _credential!['fullname'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        background: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [primaryColor, Colors.black26],
                              stops: [0.1, 1],
                              end: Alignment.topRight,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: primaryColor,
                                backgroundImage: NetworkImage(
                                  _credential!['image'],
                                ),
                              ),
                              Text(
                                _credential!['fullname'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildTopButtons(size),
                        const SizedBox(height: 10),
                        _buildAccountInfo(size),
                        const SizedBox(height: 20),
                        _buildSettings(size),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildTopButtons(Size size) {
    return Container(
      height: 60,
      width: size.width / 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTopButton(
              label: 'Order',
              backgroundColor: Colors.lightGreen,
              textColor: primaryColor,
              onPressed: () => Navigator.of(context)
                  .pushNamed(RouteManager.orderManageScreen),
            ),
            _buildTopButton(
              label: 'Wishlist',
              backgroundColor: Colors.green,
              textColor: Colors.white,
              onPressed: () =>
                  Navigator.of(context).pushNamed(RouteManager.wishList),
            ),
            _buildTopButton(
              label: 'Cart',
              backgroundColor: Colors.lightGreen,
              textColor: primaryColor,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CustomerMainScreen(index: 4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: label == 'Order'
              ? const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
              : label == 'Cart'
                  ? const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                  : BorderRadius.circular(5),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildAccountInfo(Size size) {
    return Container(
      height: size.height / 3.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          KListTile(
            title: 'Email Address',
            subtitle: _credential!['email'],
            icon: Icons.email,
            onTapHandler: _editProfile,
          ),
          KListTile(
            title: 'Phone Number',
            subtitle: _credential!['phone'] == ""
                ? 'Not set yet'
                : _credential!['phone'],
            icon: Icons.phone,
            onTapHandler: _editProfile,
          ),
          KListTile(
            title: 'Delivery Address',
            subtitle: _credential!['address'] == ""
                ? 'Not set yet'
                : _credential!['address'],
            icon: Icons.location_pin,
            onTapHandler: _editProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(Size size) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: size.height / 3.3,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            KListTile(
              title: 'App Settings',
              icon: Icons.settings,
              onTapHandler: _settings,
              showSubtitle: false,
            ),
            KListTile(
              title: 'Edit Profile',
              icon: Icons.edit_note,
              onTapHandler: _editProfile,
              showSubtitle: false,
            ),
            KListTile(
              title: 'Change Password',
              icon: Icons.key,
              onTapHandler: _changePassword,
              showSubtitle: false,
            ),
            KListTile(
              title: 'Logout',
              icon: Icons.logout,
              onTapHandler: _showLogoutOptions,
              showSubtitle: false,
            ),
          ],
        ),
      ),
    );
  }

  void _settings() {
    // Handle settings tap
  }

  void _changePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfile(
          editPasswordOnly: true,
        ),
      ),
    );
  }
}
