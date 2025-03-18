import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';

import 'BottomNavbar_save_buttons.dart';

class Sale_Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SaleReport();
}

class SaleReport extends State<Sale_Report> {
  var time = DateTime.now();

  String _selectedDuration = 'Select Duration';
  void _showTimeDurationBottomSheet() {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('One Day'),
                onTap: () {
                  setState(() {
                    _selectedDuration = 'One Day';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('One Week'),
                onTap: () {
                  setState(() {
                    _selectedDuration = 'One Week';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('One Month'),
                onTap: () {
                  setState(() {
                    _selectedDuration = 'One Month';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('One Year'),
                onTap: () {
                  setState(() {
                    _selectedDuration = 'One Year';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color? blue_50 = Colors.blue[50];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: Prefered_underline_appbar(),
        foregroundColor: Colors.black,
        title: Text('Sale Report', style: TextStyle(color: Colors.black)),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          Container(
            height: 30,
            width: 50,
            child: Image.asset("Assets/Images/xls.png"),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                                onTap: _showTimeDurationBottomSheet,
                                child: Row(
                                  children: [
                                    Text(_selectedDuration,),
                                    SizedBox(width: 10,),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                                ),
                            VerticalDivider(thickness: 1,),
                            Row(
                              children: [
                                Icon(FlutterRemix.calendar_2_line,size: 16,color: Colors.blue,),
                                SizedBox(width: 10,),
                                Text("Date", style: TextStyle(fontSize: 16)),
                                TextButton(
                                  onPressed: () async {
                                    DateTime? selectedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (selectedDate != null) {
                                      setState(() {
                                        time = selectedDate;
                                      });
                                    }
                                  },
                                  child: Text(
                                    "${time.day}/${time.month}/${time.year}",
                                    style: TextStyle(fontSize: 16,),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey,thickness: 0.8,),

                      Padding(
                        padding: const EdgeInsets.only(left: 8.0,right: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text("Filters Applied :")
                                ),
                                SizedBox(
                                  height: 30,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        side: BorderSide(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      onPressed: (){},
                                      child: Row(
                                        children: [
                                          Icon(FlutterRemix.filter_2_line,size: 15,color: Colors.blue,),
                                          Text("Filters")
                                        ],
                                      )),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    height: 30,
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          backgroundColor: Color(0xFFE8E8E8FF),
                                        ),
                                        onPressed: (){},
                                        child: Center(child: Text("Txns Type - Sale & Cr. Note",style: TextStyle(fontSize: 11,color: Colors.black),))
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                    child: TextButton(
                                        style: TextButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.grey,
                                            width: 1,
                                          ),
                                          backgroundColor: Color(0xFFE8E8E8FF),
                                        ),
                                        onPressed: (){},
                                        child: Center(child: Text("party - All party",style: TextStyle(fontSize: 11,color: Colors.black),))
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),

            Expanded(
              flex: 4,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.blue.shade100,Colors.blue.shade50]
                    )
                ),
                padding: EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("No of Txns"),
                                  Text("4"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total Sale"),
                                  Text("₹50000"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Balance Due"),
                                  Text(
                                    "₹ 4750",
                                    style: TextStyle(color: Colors.greenAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Mohit",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "SALE 1",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          "21 Jan, 25",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Amount",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "₹ 100.00",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Balance",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          "₹ 50.00",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

