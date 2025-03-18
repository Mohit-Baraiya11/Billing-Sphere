import 'dart:async';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_signup/Home/Home.dart';

import '../main.dart';

var PhoneNumber;
var Country_phone_code;

class Sign_Up extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SignUp();
}

class SignUp extends State<Sign_Up> {
  Country? _selectedCountry = Country(
    countryCode: 'IN',
    phoneCode: '91',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9123456789',
    displayName: 'India',
    displayNameNoCountryCode: 'India',
    e164Key: '91-IN-0',
  );
  String Country_code = "+91";
  TextEditingController _phoneController = TextEditingController();
  FocusNode _phoneFocusNode = FocusNode(); // Create a FocusNode

  Color _buttonColor = Colors.grey;

  //sign up with mobile number
  Future<void> sendOTP(String phoneNumber, BuildContext context) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // This callback is triggered in two cases:
        // 1. Instant verification on Android.
        // 2. Auto-retrieval when SMS code is detected automatically.
        print("Verification completed automatically.");
        // Optionally sign in the user automatically if desired.
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle any errors that occur during verification.
        print("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        // OTP has been sent, navigate to the OTP verification page.
        print("OTP sent successfully. Verification ID: $verificationId");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Verifying_Otp(verificationId: verificationId),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when automatic code retrieval times out.
        print("Auto retrieval timeout. Verification ID: $verificationId");
      },
    );
  }

  //sign up with google account
  Future<UserCredential?> signUpWithGoogle(BuildContext context) async {
    try {
      // Ensure the previous account is signed out to force account selection
      await GoogleSignIn().signOut();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels, return null.
      if (googleUser == null) {
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);


        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-In Successful!')),
        );


      return userCredential;
    } catch (e) {
      print('Error during Google sign-in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-In Failed. Please try again.')),
      );
      return null;
    }
  }


  @override
  void initState() {
    super.initState();

    // Request focus on the phone number TextField when the widget is initialized
    Future.delayed(Duration.zero, () {
      _phoneFocusNode.requestFocus();
    });

    _phoneController.addListener(() {
      setState(() {
        _buttonColor =
        _phoneController.text.length == 10 ? Colors.red : Colors.grey;
      });
    });
  }

  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign up text
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Text(
                  "Sign up",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 8),
              // Sentences
              Row(
                children: [
                  Text(
                    "Get control of your business with ",
                    style: TextStyle(fontSize: 13, color: Colors.black38),
                  ),
                  Image.asset(
                    "Assets/Images/Vyapar_logo.png",
                    width: 15,
                    height: 15,
                    color: Colors.grey,
                  ),
                  Text(
                    " Vyapar",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  // Open country picker on tap
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    onSelect: (Country country) {
                      setState(() {
                        Country_code = "+${country.phoneCode}";
                        _selectedCountry = country;
                      });
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      if (_selectedCountry != null)
                        Image.asset(
                          'icons/flags/png/${_selectedCountry!.countryCode.toLowerCase()}.png',
                          package: 'country_icons',
                          width: 24,
                          height: 24,
                        )
                      else
                        Icon(Icons.flag, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        _selectedCountry != null
                            ? "${_selectedCountry!.name}"
                            : "Select Country",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              // TextField of phone number
              SizedBox(
                height: 50,
                child: TextField(
                  focusNode: _phoneFocusNode,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Enter Mobile Number",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefix: Text(
                      Country_code,
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent, // Focused border color
                        width: 1.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
              //Get otp button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor,
                  ),
                  onPressed: () {
                    if (_phoneController.text.length == 10) {
                      PhoneNumber = _phoneController.text;
                      Country_phone_code = Country_code;
                      String phoneNumber = Country_phone_code + _phoneController.text;
                      sendOTP(phoneNumber, context);
                    }
                  },
                  child: Text(
                    "Get Otp",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Or text
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 1, // Thickness of the line
                        color: Colors.grey, // Color of the line
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 17, // Font size
                          color: Colors.grey, // Font color
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 1, // Thickness of the line
                        color: Colors.grey, // Color of the line
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
              //sign in with google
              SizedBox(
                height: 50,
                width: double.infinity,
                child: TextButton(
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(
                      BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                  onPressed:()async{
                    UserCredential? credential = await signUpWithGoogle(context);
                    if(credential!=null){
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
                    }
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 80),
                      SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset("Assets/Images/google.png")),
                      SizedBox(width: 10),
                      Text(
                        "Sign in with google",
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}





class Verifying_Otp extends StatefulWidget {
  final String verificationId;
  Verifying_Otp({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => VerifyingOtp();
}

class VerifyingOtp extends State<Verifying_Otp> {
  TextEditingController _OtpeController = TextEditingController();
  FocusNode _OtpFocusNode = FocusNode();

  int _countdown = 30;
  Timer? _timer;
  bool _isResendButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _OtpFocusNode.requestFocus();
    });
    _startCountdown();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30; // Reset countdown to 30 seconds
      _isResendButtonEnabled = false; // Disable resend button
    });

    _timer?.cancel(); // Cancel any previous timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _isResendButtonEnabled = true; // Enable resend button
          timer.cancel(); // Stop the timer
        }
      });
    });
  }

  // Method to verify the OTP entered by the user
  Future<void> _verifyOTP() async {
    String smsCode = _OtpeController.text.trim();
    if (smsCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      // Sign in the user with the credential
      await FirebaseAuth.instance.signInWithCredential(credential);

      // If successful, navigate to the home page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // If there is an error, display a snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP. Please try again.")),
      );
    }
  }

  @override
  void dispose() {
    _OtpFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Text(
                  "Verifying Otp",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Otp sent to ",
                    style: TextStyle(fontSize: 13, color: Colors.black38),
                  ),
                  Text(
                    "${Country_phone_code}${PhoneNumber}",
                    style: TextStyle(fontSize: 13, color: Colors.black38),
                  ),
                  Text(
                    " Change ?",
                    style: TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 50,
                child: TextField(
                  focusNode: _OtpFocusNode,
                  controller: _OtpeController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Otp",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blueAccent, // Focused border color
                        width: 1.8,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Text(
                  "Resend Otp in ${_countdown}s",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _verifyOTP();
                  },
                  child: Text(
                    "Verify Otp",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}