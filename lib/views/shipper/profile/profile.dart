import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoes_shop/api/apis.dart';
import 'package:shoes_shop/views/components/flashing_funds.dart';
import '../../../constants/color.dart';
import '../../../controllers/route_manager.dart';
import '../../../resources/assets_manager.dart';
import '../../widgets/k_tile.dart';
import '../../widgets/loading_widget.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  final bool flashFunds;

  const ProfileScreen({Key? key, this.flashFunds = false}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseFirestore _firebase = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final String _userId;
  DocumentSnapshot? _credential;
  var earnings = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _userId = _auth.currentUser!.uid;
    _fetchUserDetails();
  }

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

  _logout() async {
    await APIs.updateActiveStatus(false);
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
    Size size = MediaQuery.of(context).size;

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
                        _buildAvailableFunds(), // Update this line to include flashing logic
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

  Widget _buildAvailableFunds() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: widget.flashFunds
          ? FlashingFunds(
              earnings: earnings,
              key: UniqueKey(),
            )
          : Chip(
              label: FittedBox(
                child:
                    Text('Available Funds: \$${earnings.toStringAsFixed(2)}'),
              ),
              avatar: const Icon(Icons.monetization_on),
              backgroundColor: Colors.white,
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
          borderRadius: label == 'Manage Orders'
              ? const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
              : label == 'Earnings'
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
      height: 440,
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
            title: 'City',
            subtitle: _credential!['city'] == ""
                ? 'Not set yet'
                : _credential!['city'],
            icon: Icons.location_city,
            onTapHandler: _editProfile,
          ),
          KListTile(
            title: 'State',
            subtitle: _credential!['state'] == ""
                ? 'Not set yet'
                : _credential!['state'],
            icon: Icons.location_on,
            onTapHandler: _editProfile,
          ),
          KListTile(
            title: 'Country',
            subtitle: _credential!['country'] == ""
                ? 'Not set yet'
                : _credential!['country'],
            icon: Icons.flag,
            onTapHandler: _editProfile,
          ),
          KListTile(
            title: 'Vehicle Type',
            subtitle: _credential!['vehicleType'] == ""
                ? 'Not set yet'
                : _credential!['vehicleType'],
            icon: Icons.directions_car,
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
        height: 230,
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
