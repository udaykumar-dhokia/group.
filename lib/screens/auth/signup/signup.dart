import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group/components/toast/toast.dart';
import 'package:group/constants/colors/colors.dart';
import 'package:group/screens/auth/login/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:toastification/toastification.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
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

  Future<void> _signUp() async {
    final pass = _password.text;
    final key = encrypt.Key.fromLength(32);
    final iv = IV.fromLength(8);
    final encrypter = Encrypter(Salsa20(key));
    final encrypted = encrypter.encrypt(pass, iv: iv);

    if (_email.text.isNotEmpty ||
        _name.text.isNotEmpty ||
        _username.text.isNotEmpty ||
        _password.text.isNotEmpty ||
        _profileImage!.exists() == false) {
      try {
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email.text,
          password: _password.text,
        );
        User? user = userCredential.user;

        if (user != null) {
          String? profileImageUrl;
          if (_profileImage != null) {
            UploadTask uploadTask = FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child(user.uid)
                .putFile(_profileImage!);
            TaskSnapshot snapshot = await uploadTask;
            profileImageUrl = await snapshot.ref.getDownloadURL();
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.email)
              .set({
            'name': _name.text,
            'username': _username.text,
            'email': _email.text,
            'password': encrypted.base64,
            'profileImageUrl': profileImageUrl,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully signed up!')),
          );
        }
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

  Future<bool> checkUsernameAvailability(String username) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void _checkUsername(String username) async {
    bool exists = await checkEmailAvailability(username);
    setState(() {
      _isUsernameTaken = exists;
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
                  image: DecorationImage(image: AssetImage("assets/back.png"), alignment: Alignment.topCenter)
              ),
            ),
            // BackdropFilter(
            //   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            //   child: Container(
            //     color: Colors.black.withOpacity(0.1),
            //   ),
            // ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
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
                    "Login",
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
                  top: MediaQuery.of(context).size.height / 9.5, left: 10),
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
                  top: MediaQuery.of(context).size.height / 6.5, left: 10),
              child: Text(
                "SignUp",
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
              initialChildSize: 0.7,
              minChildSize: 0.7,
              maxChildSize: 0.7,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return Scaffold(
                  backgroundColor: transparent,
                  resizeToAvoidBottomInset: true,
                  body: Container(
                    decoration: const BoxDecoration(
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
                              if (_profileImage != null)
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: FileImage(_profileImage!),
                                )
                              else
                                Stack(children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: grey.withOpacity(0.5),
                                    child: Stack(children: [
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.person,
                                          size: 40,
                                          color: primary,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: grey,
                                            shape: BoxShape.circle,
                                          ),
                                          child: GestureDetector(
                                            onTap: getPermission,
                                            child: const Icon(
                                              Icons.add,
                                            ),
                                          ),
                                        ),
                                      )
                                    ]),
                                  ),
                                ]),
                              const SizedBox(
                                height: 20,
                              ),
                              _textField('Name', TextInputType.text,
                                  _showPassword, () {}, _name),
                              const SizedBox(
                                height: 10,
                              ),
                              _textField('Username', TextInputType.text,
                                  _showPassword, () {}, _username),
                              if (_isUsernameTaken)
                                Text(
                                  'Username already taken',
                                  style: GoogleFonts.barlow(
                                    textStyle: TextStyle(
                                      color: red,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
                                    ),
                                  ),
                                ),
                              if (!_isUsernameTaken && _username.text.isNotEmpty)
                                Center(
                                  child: Text(
                                    '${_username.text} is available',
                                    style: GoogleFonts.barlow(
                                      textStyle: TextStyle(
                                        color: primary,
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
                              _textField('Email', TextInputType.emailAddress,
                                  _showPassword, () {}, _email),
                              if (_isEmailTaken)
                                Text(
                                  'Email already exists',
                                  style: GoogleFonts.barlow(
                                    textStyle: TextStyle(
                                      color: red,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.03,
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
                                  if (_name.text.isEmpty ||
                                      _username.text.isEmpty ||
                                      _email.text.isEmpty ||
                                      _password.text.isEmpty) {
                                    ToastUtil.showToast(
                                        context,
                                        'Error',
                                        ToastificationType.error,
                                        "Please fill all the required fields");
                                  } else if (_isEmailTaken) {
                                    ToastUtil.showToast(
                                        context,
                                        "Email Address",
                                        ToastificationType.info,
                                        "This email is already in use.");
                                  } else {
                                    _signUp();
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
                                    "Sign Up",
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
          } else if (label == "Username") {
            _checkUsername(value);
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
