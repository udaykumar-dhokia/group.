import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flashy_tab_bar2/flashy_tab_bar2.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:group/constants/colors/colors.dart";
import "package:group/screens/homepage/homepage.dart";

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _selectedIndex = 0;

  User? user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> userData = {};
  bool isLoading = true;

  void getUser() async {
    final data = await FirebaseFirestore.instance.collection("users").doc(user!.email).get();
    if (data.exists) {
      setState(() {
        userData = data.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: white,
        body: Center(child: CircularProgressIndicator(color: black,)),
      );
    }

    List<Widget> tabItems = [
      Homepage(userData: userData),
      const Center(child: Text("2")),
      const Center(child: Text("3")),
    ];

    return Scaffold(
      bottomNavigationBar: FlashyTabBar(
        animationCurve: Curves.ease,
        backgroundColor: black,
        selectedIndex: _selectedIndex,
        iconSize: 30,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: [
          FlashyTabBarItem(
            icon: const Icon(Icons.groups),
            title: Text('Groups', style: GoogleFonts.barlow()),
            inactiveColor: white,
            activeColor: white,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.search_rounded),
            title: Text('Search', style: GoogleFonts.barlow()),
            inactiveColor: white,
            activeColor: white,
          ),
          FlashyTabBarItem(
            icon: const Icon(Icons.settings),
            title: Text('Settings', style: GoogleFonts.barlow()),
            inactiveColor: white,
            activeColor: white,
          ),
        ],
      ),
      body: Center(
        child: tabItems[_selectedIndex],
      ),
    );
  }
}
