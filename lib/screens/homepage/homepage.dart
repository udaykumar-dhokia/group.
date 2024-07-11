import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:group/constants/colors/colors.dart';

class Homepage extends StatefulWidget {
  Map<String, dynamic> userData;
  Homepage({super.key, required this.userData});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: white,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.userData["name"], style: GoogleFonts.barlow(textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: width*0.05,)),),
                Text("@${widget.userData['username']}", style: GoogleFonts.barlow(textStyle: TextStyle(fontSize: width*0.04,)),),
              ],
            ),
            const SizedBox(width: 10,),
            GestureDetector(
              onTap: (){
                FirebaseAuth.instance.signOut();
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.userData["profileImageUrl"]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
