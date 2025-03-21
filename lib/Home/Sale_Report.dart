import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Sale_Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SaleReport();
}

class SaleReport extends State<Sale_Report> {
  var time = DateTime.now();
  String _selectedDuration = 'Select Duration';
  List<Map<String, dynamic>> sales = [];
  int totalSales = 0;
  double totalSaleAmount = 0.0;
  double totalBalanceDue = 0.0;

  @override
  void initState() {
    super.initState();
    fetchSales();
  }

  void fetchSales({DateTime? selectedDate}) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions");

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> transactions = event.snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> salesList = [];

      transactions.forEach((key, value) {
        if (value["type"] == "sale") {
          // Convert Firebase timestamp to DateTime
          int currentTime = value["current_time"] ?? 0;
          DateTime saleDate = DateTime.fromMillisecondsSinceEpoch(currentTime);

          // Apply date filter if a date is selected
          if (selectedDate == null ||
              (saleDate.year == selectedDate.year &&
                  saleDate.month == selectedDate.month &&
                  saleDate.day == selectedDate.day)) {
            salesList.add(Map<String, dynamic>.from(value));
          }
        }
      });

      // Sort sales by current_time (newest first)
      salesList.sort((a, b) {
        int timeA = a["current_time"] ?? 0;
        int timeB = b["current_time"] ?? 0;
        return timeB.compareTo(timeA); // Sort in descending order
      });

      setState(() {
        sales = salesList;
        totalSales = salesList.length;

        // Initialize totals to 0
        totalSaleAmount = 0.0;
        totalBalanceDue = 0.0;

        // Loop through each sale and add to the totals
        for (var item in salesList) {
          totalSaleAmount += double.parse(item["received"] ?? "0");
          totalBalanceDue += double.parse(item["balance_due"] ?? "0");
        }
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
        title: Text('Sale Report', style: TextStyle(color: Colors.black)),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _showTimeDurationBottomSheet,
                        child: Row(
                          children: [
                            Text(_selectedDuration),
                            SizedBox(width: 10,),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                      VerticalDivider(thickness: 1,),
                      Row(
                        children: [
                          Icon(FlutterRemix.calendar_2_line, size: 16, color: Colors.blue,),
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
                                fetchSales(selectedDate: selectedDate); // Apply date filter
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
              ],
            ),
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.center,
                        colors: [Colors.blue.shade200, Colors.blue.shade50]
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
                                  Text("$totalSales"),
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
                                  Text("₹$totalSaleAmount"),
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
                                    "₹$totalBalanceDue",
                                    style: TextStyle(color: Colors.greenAccent),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: sales.isEmpty
                            ? Center(
                          child: Text(
                            "No Sale Data Found",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                            : ListView.builder(
                          shrinkWrap: true,
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            var sale = sales[index];
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
                                        sale["customer"] ?? "N/A",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "SALE ${index + 1}",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            sale["date"] ?? "N/A",
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
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    child: Row(
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
                                              "₹ ${sale["total_amount"] ?? "0.00"}",
                                              style: TextStyle(
                                                fontSize: 14,
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
                                              "₹ ${sale["balance_due"] ?? "0.00"}",
                                              style: TextStyle(
                                                fontSize: 14,
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