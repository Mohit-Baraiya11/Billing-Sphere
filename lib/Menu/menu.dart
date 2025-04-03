import 'package:billing_sphere/Compony%20Detail%20Page/Business_Details.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_account_list.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/profit&loss.dart';
import 'package:billing_sphere/Menu/Reminder.dart';
import 'package:billing_sphere/Menu/to_do_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

                  //Reminder
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Reminder', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.alarm_fill, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Reminder()));
                    },
                  ),
                  Divider(color: Colors.grey.shade200,thickness: 1,),


                  /// Reports
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text('Reports', style: TextStyle(fontSize: 15)),
                    leading: Icon(Remix.file_list_line, color: Colors.black),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportPage()));
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
                    leading: Icon(Remix.logout_circle_line,),
                    trailing: Icon(Remix.arrow_right_s_line, color: Colors.blue),
                    onTap: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context)=>Profit_and_loss()));
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
}