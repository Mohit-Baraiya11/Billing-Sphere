import 'package:billing_sphere/Home/Prefered_underline_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';

class Party_Statement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PartyStatement();
}

class PartyStatement extends State<Party_Statement> {
  var time = DateTime.now();

  String? selected_timeDuration = "This week";
  final List<String> time_duration_option = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This Financial Year',
    'custom'
  ];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light, // Light icons (for dark backgrounds)
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0, // Removes shadow
        foregroundColor: Colors.black,
        title: Text('Party Statement', style: TextStyle(color: Colors.black)),
        bottom: Prefered_underline_appbar(),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          SizedBox(width: 10,),

        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0,right: 8.0,top: 4,bottom: 4),
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
                      Divider(),
                    ],
                  ),

            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Colors.blue.shade200, Colors.blue.shade50],
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Debit",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹ 50.00",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                      Text(
                                        "Total Credit",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "₹ 50.00",
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                Text(
                                  "Closing Debit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "₹ 50.00",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Transaction Details Table
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Txns Type",
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Sale Amount",
                                  style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "Profit/Loss",
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Colors.black12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Sale",),
                                              SizedBox(height: 2),
                                              Text(
                                                "24 JAN, 25 - Sale 1",
                                                style: TextStyle(color: Colors.grey, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text("₹ 50.00",),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              "₹ 50.00",
                                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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