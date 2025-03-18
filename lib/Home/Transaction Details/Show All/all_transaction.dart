import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class All_Transaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AllTransaction();
}

 class AllTransaction extends State<All_Transaction> {
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

  String? selected_transaction = "All Transactions";
  final List<String> Item_Transaction = [
    'All Transactions',
    'Purchase',
    'Expense',
    'Sale',
    'Party To Party [Paid]',
    'Party To Party [Rcvd]',
    'Payment-In',
    'Payment-Out',
    'Credit Note',
    'Debit Note',
    'Sale [Cancelled]',
    'Purchase (Job Work)',
    'Sale Order',
    'Purchase Order',
    'Estimate',
    'Delivery Challan',
    'Sale FA',
    'Purchase FA',
    'Journal Entry'
  ];

  String selected_party = "All Party";
  final List<String> Item_party = [
    "Mohit",
    "All Party"
  ];
  List<String> filtered_Party = [];

  @override
  void initState() {
    super.initState();
    filtered_Party =  Item_party;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text(
          "All Transaction",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
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
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: selected_timeDuration,
                    hint: Text(
                      'This month',
                      style: TextStyle(fontSize: 12),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selected_timeDuration = newValue;
                      });
                    },
                    items: time_duration_option
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    underline: Container(),
                  ),
                  Container(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                    size: 20,
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
                ],
              ),
              Divider(),
              Align(
                alignment: Alignment.topLeft,
                child: DropdownButton<String>(
                  value: selected_transaction,
                  hint: Text(
                    'Select Transaction',
                    style: TextStyle(fontSize: 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selected_transaction = newValue;
                    });
                  },
                  items: Item_Transaction.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  underline: Container(),
                ),
              ),
              Divider(),
              Row(
                children: [
                  Text("Party Name",style: TextStyle(fontSize: 12,color: Colors.blueAccent),),
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(
                        text: selected_party,
                      ),
                      style: TextStyle(fontSize: 12), // Font size for TextField input
                      decoration: InputDecoration(
                        suffixIcon: DropdownButton<String>(
                          icon: Icon(Icons.arrow_drop_down),
                          underline: Container(),
                          onChanged: (value) {
                            setState(() {
                              filtered_Party = Item_party
                                  .where((item) =>
                                  item.toLowerCase().contains(value?.toLowerCase() ?? ''))
                                  .toList();
                              selected_party = value!;
                            });
                          },
                          items: Item_party.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: 12, // Font size for dropdown items
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                    itemBuilder: (context,index){
                      return Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(1, 1),
                            ),
                          ]
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                 children: [
                                   Align(alignment: Alignment.topLeft,child: Text("Mohit",style: TextStyle(fontSize: 12,color: Colors.black),)),
                                   Align(alignment: Alignment.topLeft,child: Text("24/01/2025",style: TextStyle(fontSize: 12,color: Colors.grey),)),
                                 ],
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                                child: Align(
                                    alignment:Alignment.topCenter,
                                    child: Text("Sale 1",style: TextStyle(fontSize: 12,color: Colors.black),)
                                ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Column(
                                  children: [
                                    Text("Total : ₹100",style: TextStyle(fontSize: 12,color: Colors.black),),
                                    Text("Balance : ₹50",style: TextStyle(fontSize: 12,color: Colors.grey),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  itemCount: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
