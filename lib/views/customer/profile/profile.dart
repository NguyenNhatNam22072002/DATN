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
  var firebase = FirebaseFirestore.instance;
  var auth = FirebaseAuth.instance;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? credential;
  var isLoading = true;
  var isInit = true;

  // fetch user credentials
  _fetchUserDetails() async {
    credential = await firebase.collection('customers').doc(userId).get();
    setState(() {
      isLoading = false;
    });
  }

  showLogoutOptions() {
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
        content: const Text(
          'Are you sure you want to log out?',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => _logout(),
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

  _logout() {
    auth.signOut();
    Navigator.of(context).pushNamed(RouteManager.accountType);
  }

  _editProfile() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => const EditProfile(),
          ),
        )
        .then(
          (value) => setState(
            () {},
          ),
        );
  }

  _settings() {
    Navigator.of(context).pushNamed('');
  }

  _changePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfile(
          editPasswordOnly: true,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    if (isInit) {
      _fetchUserDetails();
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);

    return isLoading
        ? const Center(
            child: LoadingWidget(
              size: 50,
            ),
          )
        : CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading:
                    false, // Set to false to remove the back button
                title: Center(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25, // Adjust the font size as needed
                    ),
                  ),
                ),
                expandedHeight: 50,
                backgroundColor: Colors.white, // Set the color you prefer
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
                        duration: const Duration(
                          milliseconds: 300,
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: primaryColor,
                              backgroundImage: NetworkImage(
                                credential!['image'],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              credential!['fullname'],
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
                            colors: [
                              primaryColor,
                              Colors.black26,
                            ],
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
                                credential!['image'],
                              ),
                            ),
                            Text(
                              credential!['fullname'],
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
                      SizedBox(
                        height: 10,
                      ),
                      Container(
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
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.lightGreen,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(30),
                                      bottomLeft: Radius.circular(30),
                                    ),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(RouteManager.ordersScreen),
                                child: const Text(
                                  'Order',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed(RouteManager.wishList),
                                child: const Text(
                                  'Wishlist',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.lightGreen,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      bottomRight: Radius.circular(30),
                                    ),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CustomerMainScreen(index: 4),
                                  ),
                                ),
                                child: const Text(
                                  'Cart',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const KDividerText(title: 'Account Information'),
                      const SizedBox(height: 10),
                      Container(
                        height: size.height / 3.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            KListTile(
                              title: 'Email Address',
                              subtitle: credential!['email'],
                              icon: Icons.email,
                            ),
                            KListTile(
                              title: 'Phone Number',
                              subtitle: credential!['phone'] == ""
                                  ? 'Not set yet'
                                  : credential!['phone'],
                              icon: Icons.phone,
                            ),
                            KListTile(
                              title: 'Delivery Address',
                              subtitle: credential!['address'] == ""
                                  ? 'Not set yet'
                                  : credential!['address'],
                              icon: Icons.location_pin,
                            ),
                          ],
                        ),
                      ),
                      // const KDividerText(title: 'Account Settings'),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 24),
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
                                onTapHandler: showLogoutOptions,
                                showSubtitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
  }
}
