//import 'dart:async';
//import 'dart:io';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cool_alert/cool_alert.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';
//import 'package:shoes_shop/views/widgets/kcool_alert.dart';
//import 'package:country_state_city_picker/country_state_city_picker.dart';
//import '../../../constants/color.dart';
//import '../../../constants/enums/account_type.dart';
//import '../../../constants/enums/fields.dart';
//import '../../../constants/enums/status.dart';
//import '../../../constants/firebase_refs/collections.dart';
//import '../../../controllers/auth_controller.dart';
//import '../../../controllers/route_manager.dart';
//import '../../../helpers/auth_error_formatter.dart';
//import '../../../helpers/shared_prefs.dart';
//import '../../../models/auth_result.dart';
//import '../../../resources/assets_manager.dart';
//import '../../widgets/loading_widget.dart';
//import '../../widgets/msg_snackbar.dart';
//import '../../../helpers/image_picker.dart';
//
//class ShipperAuthScreen extends StatefulWidget {
//  const ShipperAuthScreen({Key? key}) : super(key: key);
//
//  @override
//  State<ShipperAuthScreen> createState() => _ShipperAuthScreenState();
//}
//
//class _ShipperAuthScreenState extends State<ShipperAuthScreen> {
//  final _formKey = GlobalKey<FormState>();
//  final _emailController = TextEditingController();
//  final _nameController = TextEditingController();
//  final _passwordController = TextEditingController();
//  final _phoneController = TextEditingController();
//  final _vehicleTypeController = TextEditingController();
//  final _countryController = TextEditingController();
//  final _stateController = TextEditingController();
//  final _cityController = TextEditingController();
//
//  bool obscure = true;
//  bool isLogin = true;
//  File? profileImage;
//  bool isLoading = false;
//  final AuthController _authController = AuthController();
//  bool isActive = false;
//
//  void _togglePasswordObscure() {
//    setState(() {
//      obscure = !obscure;
//    });
//  }
//
//  Widget _buildTextField(
//    TextEditingController controller,
//    String hint,
//    String label,
//    Field field,
//    bool obscureText,
//  ) {
//    return TextFormField(
//      controller: controller,
//      obscureText: obscureText,
//      keyboardType: _getKeyboardType(field),
//      textInputAction: _getTextInputAction(field),
//      autofocus: field == Field.email,
//      decoration: InputDecoration(
//        labelText: label,
//        labelStyle: const TextStyle(color: accentColor),
//        suffixIcon: field == Field.password
//            ? _passwordController.text.isNotEmpty
//                ? IconButton(
//                    onPressed: _togglePasswordObscure,
//                    icon: Icon(
//                      obscure ? Icons.visibility : Icons.visibility_off,
//                      color: accentColor,
//                    ),
//                  )
//                : const SizedBox.shrink()
//            : const SizedBox.shrink(),
//        hintText: hint,
//        focusedBorder: OutlineInputBorder(
//          borderRadius: BorderRadius.circular(20),
//          borderSide: const BorderSide(width: 2, color: accentColor),
//        ),
//        border: OutlineInputBorder(
//          borderRadius: BorderRadius.circular(20),
//          borderSide: const BorderSide(width: 1, color: Colors.grey),
//        ),
//      ),
//      validator: (value) => _validateField(value, field),
//    );
//  }
//
//  TextInputType _getKeyboardType(Field field) {
//    switch (field) {
//      case Field.email:
//        return TextInputType.emailAddress;
//      case Field.phone:
//        return TextInputType.phone;
//      case Field.vehicleType:
//        return TextInputType.text;
//      default:
//        return TextInputType.text;
//    }
//  }
//
//  TextInputAction _getTextInputAction(Field field) {
//    return field == Field.password
//        ? TextInputAction.done
//        : TextInputAction.next;
//  }
//
//  String? _validateField(String? value, Field field) {
//    switch (field) {
//      case Field.email:
//        if (value == null || !value.contains('@')) return 'Email is not valid!';
//        if (value.isEmpty) return 'Email cannot be empty';
//        break;
//      case Field.fullname:
//        if (value == null || value.length < 3) return 'Full name is not valid';
//        break;
//      case Field.phone:
//        if (value == null || value.length < 10)
//          return 'Phone number is not valid';
//        break;
//      case Field.vehicleType:
//        if (value == null || value.length < 3)
//          return 'Vehicle type needs to be valid';
//        break;
//      case Field.password:
//        if (value == null || value.length < 8)
//          return 'Password needs to be valid';
//        break;
//    }
//    return null;
//  }
//
//  void _selectPhoto(File image) {
//    setState(() {
//      profileImage = image;
//    });
//  }
//
//  Future<void> _routingShipper() async {
//    var userId = FirebaseAuth.instance.currentUser!.uid;
//    var data = await FirebaseCollections.shippersCollection.doc(userId).get();
//    if (data['isApproved']) {
//      Timer(
//        const Duration(seconds: 2),
//        () => Navigator.of(context).pushNamedAndRemoveUntil(
//            RouteManager.shipperMainScreen, (route) => false),
//      );
//    }
//  }
//
//  Future<void> _isLoadingFnc() async {
//    setState(() {
//      isLoading = true;
//    });
//    await _routingShipper();
//    await setAccountType(accountType: AccountType.shipper);
//  }
//
//  void _completeAction() {
//    setState(() {
//      isLoading = false;
//    });
//    Navigator.pop(context);
//  }
//
//  Future<void> _handleAuth() async {
//    if (!_formKey.currentState!.validate()) {
//      displaySnackBar(
//        message: 'Form needs to be accurately filled',
//        status: Status.error,
//        context: context,
//      );
//      return;
//    }
//
//    _formKey.currentState!.save();
//    setState(() {
//      isLoading = true;
//    });
//
//    AuthResult? result;
//    if (isLogin) {
//      result = await _authController.signInUser(
//        _emailController.text.trim(),
//        _passwordController.text.trim(),
//      );
//    } else {
//      if (profileImage == null) {
//        displaySnackBar(
//          message: 'Profile image cannot be empty!',
//          status: Status.error,
//          context: context,
//        );
//        setState(() {
//          isLoading = false;
//        });
//        return;
//      }
//      result = await _authController.signUpUser(
//        email: _emailController.text.trim(),
//        fullname: _nameController.text.trim(),
//        phone: _phoneController.text.trim(),
//        password: _passwordController.text.trim(),
//        accountType: AccountType.shipper,
//        profileImage: profileImage!,
//        country: _countryController.text,
//        state: _stateController.text,
//        city: _cityController.text,
//        vehicleType: _vehicleTypeController.text.trim(),
//      );
//    }
//
//    if (result?.user == null) {
//      kCoolAlert(
//        message: result?.errorMessage ?? 'Unknown error',
//        context: context,
//        alert: CoolAlertType.error,
//        action: _completeAction,
//      );
//    } else {
//      _isLoadingFnc();
//    }
//  }
//
//  Future<void> _googleAuth() async {
//    setState(() {
//      isLoading = true;
//    });
//
//    try {
//      AuthResult? result =
//          await _authController.googleAuth(AccountType.shipper);
//
//      if (result?.user != null) {
//        _isLoadingFnc();
//      } else {
//        kCoolAlert(
//          message: result?.errorMessage ?? 'Unknown error',
//          context: context,
//          alert: CoolAlertType.error,
//          action: _completeAction,
//        );
//      }
//    } catch (e) {
//      kCoolAlert(
//        message: extractErrorMessage(e.toString()),
//        context: context,
//        alert: CoolAlertType.error,
//        action: _completeAction,
//      );
//    }
//  }
//
//  void _forgotPassword() {
//    Navigator.of(context).pushNamed(RouteManager.shipperForgotPass);
//  }
//
//  void _switchLog() {
//    setState(() {
//      isLogin = !isLogin;
//      _passwordController.text = "";
//    });
//  }
//
//  @override
//  void initState() {
//    _passwordController.addListener(() {
//      setState(() {});
//    });
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: SafeArea(
//        child: Padding(
//          padding: const EdgeInsets.all(18.0),
//          child: Center(
//            child: SingleChildScrollView(
//              child: Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.stretch,
//                children: [
//                  !isLogin
//                      ? ProfileImagePicker(selectImage: _selectPhoto)
//                      : Center(
//                          child: CircleAvatar(
//                            backgroundColor: Colors.white,
//                            radius: 60,
//                            child: Image.asset(AssetManager.loginImage),
//                          ),
//                        ),
//                  const SizedBox(height: 20),
//                  Center(
//                    child: Text(
//                      isLogin ? 'Shipper Signin' : 'Shipper Signup',
//                      style: const TextStyle(
//                        color: accentColor,
//                        fontSize: 18,
//                        fontWeight: FontWeight.w600,
//                      ),
//                    ),
//                  ),
//                  const SizedBox(height: 20),
//                  isLoading
//                      ? const Center(child: LoadingWidget(size: 70))
//                      : Form(
//                          key: _formKey,
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.stretch,
//                            children: [
//                              _buildTextField(
//                                _emailController,
//                                'doe_Shipper@gmail.com',
//                                'Email Address',
//                                Field.email,
//                                false,
//                              ),
//                              const SizedBox(height: 10),
//                              if (!isLogin) ...[
//                                _buildTextField(
//                                  _nameController,
//                                  'John Doe',
//                                  'Full Name',
//                                  Field.fullname,
//                                  false,
//                                ),
//                                const SizedBox(height: 10),
//                                _buildTextField(
//                                  _phoneController,
//                                  '+234-000-000-000',
//                                  'Phone Number',
//                                  Field.phone,
//                                  false,
//                                ),
//                              ],
//                              const SizedBox(height: 10),
//                              _buildTextField(
//                                _passwordController,
//                                '********',
//                                'Password',
//                                Field.password,
//                                obscure,
//                              ),
//                              if (!isLogin) ...[
//                                Padding(
//                                  padding: const EdgeInsets.only(left: 8.0),
//                                  child: SelectState(
//                                    onCountryChanged: (value) {
//                                      setState(() {
//                                        _countryController.text = value;
//                                      });
//                                    },
//                                    onStateChanged: (value) {
//                                      setState(() {
//                                        _stateController.text = value;
//                                      });
//                                    },
//                                    onCityChanged: (value) {
//                                      setState(() {
//                                        _cityController.text = value;
//                                      });
//                                    },
//                                  ),
//                                ),
//                                const SizedBox(height: 10),
//                                _buildTextField(
//                                  _vehicleTypeController,
//                                  'Motorcycle',
//                                  'Vehicle Type',
//                                  Field.vehicleType,
//                                  false,
//                                ),
//                                const SizedBox(height: 10),
//                                CheckboxListTile(
//                                  value: isActive,
//                                  onChanged: (value) {
//                                    setState(() {
//                                      isActive = value!;
//                                    });
//                                  },
//                                  title:
//                                      const Text('Are you an active Shipper?'),
//                                  checkboxShape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(10),
//                                  ),
//                                )
//                              ],
//                              const SizedBox(height: 10),
//                              Directionality(
//                                textDirection: TextDirection.rtl,
//                                child: ElevatedButton.icon(
//                                  style: ElevatedButton.styleFrom(
//                                    backgroundColor: Colors.green,
//                                    shape: RoundedRectangleBorder(
//                                      borderRadius: BorderRadius.circular(20),
//                                    ),
//                                    padding: const EdgeInsets.all(15),
//                                  ),
//                                  icon: Icon(
//                                    isLogin
//                                        ? Icons.person
//                                        : Icons.person_add_alt_1,
//                                    color: Colors.white,
//                                  ),
//                                  onPressed: _handleAuth,
//                                  label: Text(
//                                    isLogin
//                                        ? 'Signin Account'
//                                        : 'Signup Account',
//                                    style: const TextStyle(color: Colors.white),
//                                  ),
//                                ),
//                              ),
//                              const SizedBox(height: 10),
//                              ElevatedButton(
//                                style: ElevatedButton.styleFrom(
//                                  backgroundColor: Colors.white,
//                                  shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(20),
//                                  ),
//                                  padding: const EdgeInsets.all(15),
//                                ),
//                                onPressed: _googleAuth,
//                                child: Row(
//                                  mainAxisAlignment: MainAxisAlignment.center,
//                                  children: [
//                                    Image.asset(
//                                      'assets/images/google.png',
//                                      width: 20,
//                                    ),
//                                    const SizedBox(width: 20),
//                                    Text(
//                                      isLogin
//                                          ? 'Signin with Google'
//                                          : 'Signup with Google',
//                                      style: const TextStyle(
//                                        color: Colors.grey,
//                                        fontWeight: FontWeight.w600,
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                              Row(
//                                mainAxisAlignment:
//                                    MainAxisAlignment.spaceBetween,
//                                children: [
//                                  TextButton(
//                                    onPressed: _forgotPassword,
//                                    child: const Text(
//                                      'Forgot Password',
//                                      style: TextStyle(
//                                        color: accentColor,
//                                        fontWeight: FontWeight.w600,
//                                      ),
//                                    ),
//                                  ),
//                                  TextButton(
//                                    onPressed: _switchLog,
//                                    child: Text(
//                                      isLogin
//                                          ? 'New here? Create Account'
//                                          : 'Already a Shipper? Sign in',
//                                      style: const TextStyle(
//                                        color: accentColor,
//                                        fontWeight: FontWeight.w600,
//                                      ),
//                                    ),
//                                  )
//                                ],
//                              ),
//                            ],
//                          ),
//                        ),
//                ],
//              ),
//            ),
//          ),
//        ),
//      ),
//    );
//  }
//}
//