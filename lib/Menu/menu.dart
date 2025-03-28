import 'package:billing_sphere/Compony%20Detail%20Page/Business_Details.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/profit&loss.dart';
import 'package:billing_sphere/Menu/Reminder.dart';
import 'package:billing_sphere/Menu/to_do_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
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
      backgroundColor: Colors.blue[50], // Light blue background
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: EdgeInsets.all(10),
          height: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "My Business",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              //To do list
              ListTile(
                title: Text('To do list', style: TextStyle(fontSize: 15)),
                leading: Icon(FlutterRemix.file_list_3_line, color: Colors.black),
                trailing: Icon(FlutterRemix.arrow_right_s_line, color: Colors.blue),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>To_do_list()));
                },
              ),

              //Reminder
              ListTile(
                title: Text('Reminder', style: TextStyle(fontSize: 15)),
                leading: Icon(Remix.alarm_fill, color: Colors.black),
                trailing: Icon(FlutterRemix.arrow_right_s_line, color: Colors.blue),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Reminder()));
                },
              ),

              /// Reports
              ListTile(
                title: Text('Reports', style: TextStyle(fontSize: 15)),
                leading: Icon(FlutterRemix.file_list_line, color: Colors.black),
                trailing: Icon(FlutterRemix.arrow_right_s_line, color: Colors.blue),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportPage()));
                },
              ),


              ListTile(
                title: Text('Business Profile', style: TextStyle(fontSize: 15)),
                leading: Icon(FlutterRemix.profile_line, color: Colors.black),
                trailing: Icon(FlutterRemix.arrow_right_s_line, color: Colors.blue),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>Business_Details()));
                },
              ),

              ListTile(
                title: Text('Profit & Loss', style: TextStyle(fontSize: 15)),
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.trending_up, size: 40), // Profit Icon
                    Icon(Icons.trending_down,size: 40), // Loss Icon
                  ],
                ),
                  trailing: Icon(FlutterRemix.arrow_right_s_line, color: Colors.blue),
                onTap: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>Profit_and_loss()));
                },
              ),


            ],
          ),
        ),
      ),
    );
  }
}