import 'package:billing_sphere/Compony%20Detail%20Page/Business_Details.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_account_list.dart';
import 'package:billing_sphere/Dashboard/Item/Items.dart';
import 'package:billing_sphere/Home/Sale_Report.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/profit&loss.dart';
import 'package:billing_sphere/Menu/Reminder.dart';
import 'package:billing_sphere/Menu/to_do_list.dart';
import 'package:billing_sphere/User%20Login%20Module/sign_up.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:remixicon/remixicon.dart';

import 'ReportPage.dart';

class Menu extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() =>_Menu();
}
class _Menu extends State<Menu>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Business",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),

                  //To do list
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('To do list', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.file_list_3_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>To_do_list()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),

                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Sale Report', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.shopping_cart_2_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Sale_Report()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),


                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Inventory', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.stack_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Items()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),



                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Business Profile', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.profile_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Business_Details()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),
                ],
              ),
            ),
            SizedBox(height: 10,),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Cash & Bank",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),

                  //To do list
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Bank Account', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.bank_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Bank_Account_List()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),

                  //Reminder
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Cash in Hand', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.cash_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Reminder()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),

                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Log Out', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.logout_circle_line),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      _showLogoutConfirmationDialog(context); // Call the dialog function
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  // Add this method inside your _TransactionDetailsTab class
  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          backgroundColor: Colors.white,
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions:[
            TextButton(
              child: Text('No',style: TextStyle(fontSize: 14,color: Colors.black),),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Yes',style: TextStyle(fontSize: 14,color: Colors.black),),
              onPressed: () async {
                await _logoutUser(); // Perform logout
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

// Add this method inside your _TransactionDetailsTab class to handle logout
  Future<void> _logoutUser() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Sign out from Google
      await FirebaseAuth.instance.signOut(); // Sign out from Firebase
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Sign_Up()));
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }
}