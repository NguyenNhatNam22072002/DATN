import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../constants/color.dart';
import '../../../constants/enums/fields.dart';
import '../../../helpers/image_picker.dart';
import '../../widgets/loading_widget.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    Key? key,
    this.editPasswordOnly = false,
  }) : super(key: key);
  final bool editPasswordOnly;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  final _passwordController = TextEditingController();
  var obscure = true; // password obscure value
  File? profileImage;
  final _auth = FirebaseAuth.instance;
  final firebase = FirebaseFirestore.instance;
  var userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot? credential;
  var isLoading = true;
  var isInit = true;
  var changePassword = false;

  // Fetch shipper credentials
  _fetchUserDetails() async {
    credential = await firebase.collection('shippers').doc(userId).get();
    _emailController.text = credential!['email'];
    _fullnameController.text = credential!['fullname'];
    _phoneController.text = credential!['phone'];
    _cityController.text = credential!['city'];
    _stateController.text = credential!['state'];
    _countryController.text = credential!['country'];
    _vehicleTypeController.text = credential!['vehicleType'];
    setState(() {
      isLoading = false;
    });
  }

  // Toggle password obscure
  _togglePasswordObscure() {
    setState(() {
      obscure = !obscure;
    });
  }

  // Custom text field for all form fields
  Widget kTextField(
    TextEditingController controller,
    String hint,
    String label,
    Field field,
    bool obscureText,
  ) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: field == Field.email
          ? TextInputType.emailAddress
          : field == Field.phone
              ? TextInputType.phone
              : TextInputType.text,
      textInputAction:
          field == Field.password ? TextInputAction.done : TextInputAction.next,
      autofocus: field == Field.email ? true : false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: accentColor),
        suffixIcon: field == Field.password
            ? _passwordController.text.isNotEmpty
                ? IconButton(
                    onPressed: () => _togglePasswordObscure(),
                    icon: Icon(
                      obscure ? Icons.visibility : Icons.visibility_off,
                      color: primaryColor,
                    ),
                  )
                : const SizedBox.shrink()
            : const SizedBox.shrink(),
        hintText: hint,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 2,
            color: accentColor,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            width: 1,
            color: Colors.grey,
          ),
        ),
      ),
      validator: (value) {
        switch (field) {
          case Field.email:
            if (!value!.contains('@')) {
              return 'Email is not valid!';
            }
            if (value.isEmpty) {
              return 'Email cannot be empty';
            }
            break;

          case Field.fullname:
            if (value!.isEmpty || value.length < 3) {
              return 'Fullname is not valid';
            }
            break;

          case Field.phone:
            if (value!.isEmpty || value.length < 10) {
              return 'Phone number is not valid';
            }
            break;

          case Field.city:
            if (value!.isEmpty || value.length < 3) {
              return 'City name is not valid';
            }
            break;

          case Field.state:
            if (value!.isEmpty || value.length < 3) {
              return 'State name is not valid';
            }
            break;

          case Field.country:
            if (value!.isEmpty || value.length < 3) {
              return 'Country name is not valid';
            }
            break;

          case Field.vehicleType:
            if (value!.isEmpty) {
              return 'Vehicle type cannot be empty';
            }
            break;

          case Field.password:
            if (value!.isEmpty || value.length < 8) {
              return 'Password needs to be valid';
            }
            break;
        }
        return null;
      },
    );
  }

  // For selecting photo
  _selectPhoto(File image) {
    setState(() {
      profileImage = image;
    });
  }

  // Loading function
  isLoadingFnc() {
    setState(() {
      isLoading = true;
    });

    Timer(const Duration(seconds: 5), () {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    _passwordController.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      _fetchUserDetails();
    }
    setState(() {
      isInit = false;
    });
    super.didChangeDependencies();
  }

  // Snackbar for error message
  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        action: SnackBarAction(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Dismiss',
          textColor: Colors.white,
        ),
      ),
    );
  }

  Future _saveDetails() async {
    var valid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    if (!valid) {
      return null;
    }

    if (widget.editPasswordOnly || changePassword) {
      // Handle password change
      _auth.currentUser!.updatePassword(_passwordController.text.trim());
      isLoadingFnc();
    } else {
      // Handle profile edit
      var storageRef = FirebaseStorage.instance
          .ref()
          .child('shipper-images') // Use 'shipper-images' for storing images
          .child('$userId.jpg');
      File? file;
      if (profileImage != null) {
        file = File(profileImage!.path);
      }

      try {
        String downloadUrl = '';
        if (profileImage != null) {
          await storageRef.putFile(file!);
          // Obtain image download URL
          downloadUrl = await storageRef.getDownloadURL();
        } else {
          downloadUrl = credential![
              'image']; // Use existing image if no new image selected
        }

        // Persisting new details to Firebase
        _auth.currentUser!.updateEmail(_emailController.text.trim());
        await firebase.collection('shippers').doc(userId).update({
          "email": _emailController.text.trim(),
          "fullname": _fullnameController.text.trim(),
          "phone": _phoneController.text.trim(),
          "city": _cityController.text.trim(),
          "state": _stateController.text.trim(),
          "country": _countryController.text.trim(),
          "vehicalType":
              _vehicleTypeController.text.trim(), // Changed to 'vehicalType'
          "image": downloadUrl,
        });
        isLoadingFnc();
      } on FirebaseException catch (e) {
        showSnackBar('Error occurred! ${e.message}');
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(builder: (context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(
              Icons.chevron_left,
              color: Colors.black,
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () => _saveDetails(),
        label: Text(
          widget.editPasswordOnly ? 'Change Password' : 'Save Details',
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
        icon: Icon(
          widget.editPasswordOnly ? Icons.key : Icons.save,
          color: Colors.black,
        ),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? const Center(
                child: LoadingWidget(
                  size: 40,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    widget.editPasswordOnly
                        ? const SizedBox.shrink()
                        : ProfileImagePicker(
                            selectImage: _selectPhoto,
                            isReg: false,
                            imgUrl: credential!['image'],
                          ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        widget.editPasswordOnly || changePassword
                            ? 'Change Password'
                            : 'Edit Profile Details',
                        style: const TextStyle(
                          color: accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          widget.editPasswordOnly
                              ? const SizedBox.shrink()
                              : Column(
                                  children: [
                                    kTextField(
                                      _emailController,
                                      _emailController.text,
                                      'Email Address',
                                      Field.email,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _fullnameController,
                                      _fullnameController.text,
                                      'Full Name',
                                      Field.fullname,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _phoneController,
                                      _phoneController.text,
                                      'Phone Number',
                                      Field.phone,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _cityController,
                                      _cityController.text,
                                      'City',
                                      Field.city,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _stateController,
                                      _stateController.text,
                                      'State',
                                      Field.state,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _countryController,
                                      _countryController.text,
                                      'Country',
                                      Field.country,
                                      false,
                                    ),
                                    const SizedBox(height: 15),
                                    kTextField(
                                      _vehicleTypeController,
                                      _vehicleTypeController.text,
                                      'Vehicle Type',
                                      Field.vehicleType,
                                      false,
                                    ),
                                  ],
                                ),
                          widget.editPasswordOnly
                              ? const SizedBox.shrink()
                              : Row(
                                  children: [
                                    Text(
                                      changePassword
                                          ? 'Don\'t change password'
                                          : 'Change Password',
                                      style:
                                          const TextStyle(color: accentColor),
                                    ),
                                    Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: accentColor,
                                      value: changePassword,
                                      onChanged: (value) => setState(
                                        () {
                                          changePassword = value!;
                                        },
                                      ),
                                      side: const BorderSide(
                                        color: accentColor,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ],
                                ),
                          changePassword || widget.editPasswordOnly
                              ? kTextField(
                                  _passwordController,
                                  '********',
                                  'Password',
                                  Field.password,
                                  obscure,
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 30),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
