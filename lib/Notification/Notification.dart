

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';

class Notification_page extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => _Notification();
}

class _Notification extends State<Notification_page>
{
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child:  TabBar(
                labelColor: Color(0xFFC41E3A), // Active Tab Text Color
                unselectedLabelColor: Colors.black, // Inactive Tab Text Color
                indicator: BoxDecoration(
                  color: Color(0xFFFADBD8), // Light Red Background for Active Tab
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFFC41E3A)), // Red border
                ),
                indicatorPadding: EdgeInsets.symmetric(vertical: 8.0),
                overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove ripple effect
                tabs: [
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text("App Notifications", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                  Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text("All Transactions", style: TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
        ),
        body: TabBarView(
          children: [
            _appNotification(),
            _app_transactions(),
          ],
        ),
      ),
    );
  }

  // Empty State UI
  Widget _appNotification() {
    return Container(
      color: Colors.blue.shade50, // Light Blue Background
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.notifications_none, size: 40, color: Colors.grey),
            ),
            SizedBox(height: 10),
            Text(
              "No notifications as of yet. Come back later.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }


  String? selected_timeDuration = "This week";
  final List<String> time_duration_option = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This Financial Year',
    'custom'
  ];

  var firstDate = DateTime.now();
  var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  void _select_firstDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.monthsPerYear),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          firstDate = picked;
        });
      }
    });
  }
  void _select_lastDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          lastDate = picked;
        });
      }
    });
  }

  void _showTimeSelectionModal(BuildContext context) {
    List<String> durations = [
      "Today",
      "This Week",
      "This Month",
      "This Quarter",
      "This Financial Year",
      "Custom",
    ];

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: durations.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(durations[index]),
                    trailing: selected_timeDuration == durations[index]
                        ? Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () {
                      setState(() {
                        selected_timeDuration = durations[index];
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
  Widget _app_transactions() {
    return Scaffold(
      body: Container(
        color: Colors.blue.shade50, // Light Blue Background
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  GestureDetector(
                    onTap: (){
                      _showTimeSelectionModal(context);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Text("${selected_timeDuration}"),
                          SizedBox(width: 50,),
                          Icon(Icons.arrow_drop_down,color: Colors.blueAccent,),
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
                    onTap: () => _select_firstDate(context),
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
                    onTap: () => _select_lastDate(context),
                    child: Text(
                      '${lastDate.day}/${lastDate.month}/${lastDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 20,),
                  Icon(FlutterRemix.calendar_2_line,color: Colors.blueAccent,size: 15,),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Parties',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 20,
                        child: VerticalDivider()
                    ),
                    IconButton(
                        onPressed: (){},
                        icon: Icon(FlutterRemix.filter_line,color: Colors.blueAccent,)
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              "No Transactions to show",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

}