import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../Home/Prefered_underline_appbar.dart';

class Purchase_Report extends StatefulWidget {
  @override
  _PurchaseReportState createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<Purchase_Report> {
  var firstDate = DateTime.now();
  var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  String? selectedTimeDuration = "This week";
  final List<String> timeDurationOptions = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This Financial Year',
    'Custom'
  ];

  void _selectFirstDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != firstDate)
      setState(() {
        firstDate = picked;
      });
  }

  void _selectLastDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lastDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != lastDate)
      setState(() {
        lastDate = picked;
      });
  }

  void _showTimeSelectionModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.48,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade200, thickness: 1),
              ListView.separated(
                shrinkWrap: true,
                itemCount: timeDurationOptions.length,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(color: Colors.grey.shade200, thickness: 1);
                },
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(timeDurationOptions[index]),
                    trailing: selectedTimeDuration == timeDurationOptions[index]
                        ? Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedTimeDuration = timeDurationOptions[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('Purchase Report', style: TextStyle(color: Colors.black)),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
            icon: Container(
                height: 25,
                width: 25,
                child: Image.asset("Assets/Images/pdf.png")
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
                height: 25,
                width: 25,
                child: Image.asset("Assets/Images/xls.png")
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showTimeSelectionModal(context);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Text("$selectedTimeDuration"),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _selectFirstDate(context),
                    child: Text(
                      '${firstDate.day}/${firstDate.month}/${firstDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'to',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _selectLastDate(context),
                    child: Text(
                      '${lastDate.day}/${lastDate.month}/${lastDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(FlutterRemix.calendar_2_line, color: Colors.blueAccent, size: 15),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Total Sale"),
                                  Text("₹500.00"),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Balance Due"),
                                  Text(
                                    "₹ 4750",
                                    style: TextStyle(color: Color(0xFF38C782)),
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
                            padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
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
                                      crossAxisAlignment: CrossAxisAlignment.end,
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
                                Container(
                                  width: MediaQuery.of(context).size.width*0.5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Amount",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "₹ 100.00",
                                            style: TextStyle(
                                              fontSize: 14,
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
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "₹ 50.00",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
          ],
        ),
      ),
    );
  }
}