import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';

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
          //xls
          Container(
            height: 30,
            width: 50,
            child: Image.asset("Assets/Images/xls.png"),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                        onPressed: (){
                                          ThemeChanged(context);
                                        },
                                        child: Center(child: Text("Theme - Acounting View",style: TextStyle(fontSize: 11,color: Colors.black),))
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
                    colors: [Colors.blue.shade100, Colors.blue.shade50],
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Center(
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search,color: Colors.blue,size: 30,),
                            suffixIcon: IconButton(
                                onPressed: (){},
                                icon: Icon(Icons.close)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        if(selectedTheme=="Vyapar View")
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
                        if(selectedTheme=="Vyapar View")
                              SizedBox(width: 10),
                        if(selectedTheme=="Vyapar View")
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
                        if(selectedTheme=="Vyapar View")
                               SizedBox(width: 10),

                        if(selectedTheme=="Accounting View")
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

  String selectedTheme = "Vyapar View";


  void ThemeChanged(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevents unnecessary space
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// **Header Section**
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Filters",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(Icons.close),
                      ),
                    ],
                  ),
                  Divider(),

                  /// **Theme Selection in Row**
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 12.0),
                        child: Text(
                          "By Theme",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(width: 24), // Space between text and radio buttons

                      Expanded(
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text('Vyapar View'),
                              value: 'Vyapar View',
                              groupValue: selectedTheme,
                              activeColor: Colors.blue, // Selected color
                              onChanged: (String? value) {
                                setState(() {
                                  selectedTheme = value!;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: Text('Accounting View'),
                              value: 'Accounting View',
                              groupValue: selectedTheme,
                              activeColor: Colors.blue, // Selected color
                              onChanged: (String? value) {
                                setState(() {
                                  selectedTheme = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  /// **Bottom Buttons**
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300], // Light grey
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedTheme = "Vyapar View"; // Reset to default
                            });
                          },
                          child: Text("Reset"),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Red button
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          onPressed: () {
                            print("${selectedTheme}");
                            Navigator.of(context).pop(selectedTheme);
                          },
                          child: Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

