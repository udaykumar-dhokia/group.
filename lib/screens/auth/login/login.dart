import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group/components/bottombar/bottombar.dart';
import 'package:group/components/toast/toast.dart';
import 'package:group/constants/colors/colors.dart';
import 'package:group/screens/auth/signup/signup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController _name = TextEditingController();
  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _mobile = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool _showPassword = true;
  bool _isLoading = false;
  bool _isEmailTaken = false;
  bool _isUsernameTaken = false;
  final _picker = ImagePicker();
  File? _profileImage;

  void getPermission() async {
    PermissionStatus result;
    result = await Permission.storage.request();

    if (result.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _profileImage = File(pickedFile.path);
        }
      });
    } else if (result.isDenied) {
      result = await Permission.storage.request();
      if (result.isDenied) {
        await openAppSettings();
      }
    }
  }

  Future<void> _Login() async {

    if (_email.text.isNotEmpty ||
        _password.text.isNotEmpty) {
      try {
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> BottomBar()));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<bool> checkEmailAvailability(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _checkEmail(String email) async {
    bool exists = await checkEmailAvailability(email);
    setState(() {
      _isEmailTaken = exists;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: white,
                image: DecorationImage(image: AssetImage("assets/back.png"))
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUp(),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 15),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 15, right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: white,
                  ),
                  child: Text(
                    "SignUp",
                    style: GoogleFonts.barlow(
                      textStyle: TextStyle(
                        color: black,
                        decoration: TextDecoration.none,
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 9, left: 10),
              child: Text(
                "Group.",
                style: GoogleFonts.barlow(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.1,
                    decoration: TextDecoration.none,
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 6, left: 10),
              child: Text(
                "Login & continue exploring your groups",
                style: GoogleFonts.barlow(
                  textStyle: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    decoration: TextDecoration.none,
                    color: black.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.5,
              maxChildSize: 0.7,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Scaffold(
                  backgroundColor: transparent,
                  resizeToAvoidBottomInset: true,
                  body: Container(
                    decoration:  const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: white,
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 50, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _textField('Email', TextInputType.emailAddress,
                                  _showPassword, () {}, _email),
                              if (!_isEmailTaken && _email.text.isNotEmpty)
                                Center(
                                  child: Text(
                                    'No such email exists',
                                    style: GoogleFonts.barlow(
                                      textStyle: TextStyle(
                                        color: red,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.03,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField(
                                'Password',
                                TextInputType.text,
                                _showPassword,
                                () {
                                  setState(
                                    () {
                                      _showPassword = !_showPassword;
                                    },
                                  );
                                },
                                _password,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (
                                      _email.text.isEmpty ||
                                      _password.text.isEmpty) {
                                    ToastUtil.showToast(
                                        context,
                                        'Error',
                                        ToastificationType.error,
                                        "Please fill all the required fields");
                                  } else if (!_isEmailTaken) {
                                    ToastUtil.showToast(
                                        context,
                                        "Email Address",
                                        ToastificationType.info,
                                        "No such email exists.");
                                  } else {
                                    _Login();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 18, bottom: 18),
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: black,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Login",
                                    style: GoogleFonts.barlow(
                                      textStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            BackdropFilter(
              filter: _isLoading
                  ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(),
            ),
            Center(
              child: _isLoading ? CircularProgressIndicator() : null,
            ),
          ],
        ),
      ),
    );
  }

  TextFormField _textField(String label, TextInputType type, bool showPassword,
          VoidCallback toggleVisibility, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        keyboardType: type,
        cursorColor: black,
        onChanged: (value) {
          if (label == 'Email') {
            _checkEmail(value);
          }
        },
        obscureText: label == "Password" ? showPassword : false,
        decoration: InputDecoration(
          suffixIcon: label == "Password"
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      toggleVisibility();
                    });
                  },
                  icon: showPassword
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                )
              : null,
          filled: true,
          fillColor: black.withOpacity(0.1),
          label: Text(label),
          labelStyle: GoogleFonts.barlow(
            textStyle: TextStyle(
              color: black,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(),
          ),
        ),
      );
}
