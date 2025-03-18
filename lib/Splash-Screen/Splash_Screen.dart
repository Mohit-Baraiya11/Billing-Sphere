import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_signup/main.dart';
import '../User Login Module/sign_up.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashScreen();
  }
}

class _SplashScreen extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 4), () {
      // Check if the user is already signed in
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is signed in, navigate to the home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        // No user is signed in, navigate to the sign-up page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Sign_Up()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFF262626),
        child: Center(
          child: CircleAvatar(
            radius: 70,
            backgroundColor: Colors.red,
            child: Container(
              child: Image(
                image: AssetImage("Assets/Images/Vyapar_logo.png"),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
