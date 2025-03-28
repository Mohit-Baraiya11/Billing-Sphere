import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../../../BottomNavbar_save_buttons.dart';
import '../../../Party Details/Add_new_party.dart';
import '../../../Prefered_underline_appbar.dart';


class P2P_Transfer extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => P2PTransfer();
}


class P2PTransfer extends State<P2P_Transfer> {
  var time = DateTime.now();

  final FocusNode _partyFieldFocusNode = FocusNode();
  final TextEditingController _partyController = TextEditingController();
  String searchQuery = "";
  List<Map<String, dynamic>> parties = [
    {"name": "Jayraj R. K.", "phone": "+919773222157", "balance": 200},
    {"name": "Mayur", "phone": "8536907412", "balance": -500},
    {"name": "Mohit", "phone": "7096395426", "balance": 1400},
  ];
  List<Map<String, dynamic>> filteredParties = [];
  bool showOptions = false;

  final FocusNode _partyFieldFocusNode_2 = FocusNode()..addListener(() {
  });

  final TextEditingController _partyController_2 = TextEditingController();
  String searchQuery_2 = "";
  List<Map<String, dynamic>> parties_2 = [
    {"name": "Jayraj R. K.", "phone": "+919773222157", "balance": 200},
    {"name": "Mayur", "phone": "8536907412", "balance": -500},
    {"name": "Mohit", "phone": "7096395426", "balance": 1400},
  ];
  List<Map<String, dynamic>> filteredParties_2 = [];
  bool showOptions_2 = false;



  int selectedIndex_payment = 0;
  late int selectedIndex_payment_2 = 1;

  @override
  void initState() {
    super.initState();

    _partyFieldFocusNode.addListener(() {
      if (_partyFieldFocusNode.hasFocus) {
        setState(() {
          showOptions = true;
          filteredParties = parties;
        });
      } else {
        setState(() {
          showOptions = true; // Hide options when unfocused
        });
      }
    });

    _partyFieldFocusNode_2.addListener(() {
      if (_partyFieldFocusNode_2.hasFocus) {
        setState(() {
          showOptions_2 = true;
          filteredParties_2 = parties_2;
        });
      } else {
        setState(() {
          showOptions_2 = false; // Hide options when unfocused
        });
      }
    });

  }

  @override
  void dispose() {
    _partyFieldFocusNode.dispose();
    _partyController.dispose();

    _partyFieldFocusNode_2.dispose();
    _partyController_2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredParties = parties
        .where((party) => party["name"]
        .toLowerCase()
        .contains(searchQuery.toLowerCase()))
        .toList();
    List<Map<String, dynamic>> filteredParties_2 = parties_2
        .where((party) => party["name"]
        .toLowerCase()
        .contains(searchQuery_2.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Party To Party Transfer',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
            icon: Icon(FlutterRemix.settings_2_line),
            onPressed: () {
              // Add settings functionality here
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbarSaveButton(leftButtonText: 'save & new', rightButtonText: 'save', leftButtonColor: Colors.white,rightButtonColor: Colors.blueAccent,onLeftButtonPressed: (){},onRightButtonPressed: (){},),
      body: Container(
        color:  Color(0xFFE8E8E8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker Section
            Container(
              padding: EdgeInsets.only(left: 8,right: 8,top: 8),
              child: GestureDetector(
                onTap: () async {
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
                child: Row(
                  children: [
                    Text("Date: ",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("${DateTime.now().toLocal()}".split(' ')[0],
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),

            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                    SizedBox(
                    height: 50,
                    child: TextField(
                      focusNode: _partyFieldFocusNode,
                      controller: _partyController,
                      decoration: InputDecoration(
                        hintText: "party",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                          filteredParties = parties
                              .where((party) => party["name"]
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  if (showOptions)
                    Expanded(
                      child: filteredParties.isEmpty
                          ? ListTile(
                        title: Text("No matching parties found"),
                        trailing: TextButton(
                          onPressed: () {
                            // Navigate to Add New Party Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Add_new_Party(),
                              ),
                            );
                          },
                          child: Text(
                            "Add new party",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: filteredParties.length,
                        itemBuilder: (context, index) {
                          final party = filteredParties[index];
                          return ListTile(
                            title: Text(party["name"]),
                            subtitle: Text(party["phone"]),
                            trailing: Text(
                              "${party["balance"] < 0 ? '🔺' : '🔻'} ${party["balance"].abs()}",
                              style: TextStyle(
                                color: party["balance"] < 0 ? Colors.red : Colors.green,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _partyController.text = party["name"];
                                showOptions = false;
                                _partyFieldFocusNode.unfocus();
                              });
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[200], // Background for the toggle container
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Received Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex_payment = 0;
                                    selectedIndex_payment_2 = 1;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20), // Adjusted height and width
                                  constraints: BoxConstraints(minWidth: 60), // Ensures a wider button
                                  decoration: BoxDecoration(
                                    color: selectedIndex_payment == 0 ? Colors.green : Colors.transparent,
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Received",
                                      style: TextStyle(
                                        color: selectedIndex_payment == 0 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Paid Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex_payment = 1;
                                    selectedIndex_payment_2 = 0;

                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20), // Adjusted height and width
                                  constraints: BoxConstraints(minWidth: 40), // Ensures a wider button
                                  decoration: BoxDecoration(
                                    color: selectedIndex_payment == 1 ? Colors.deepOrange : Colors.transparent,
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Paid",
                                      style: TextStyle(
                                        color: selectedIndex_payment == 1 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Amount",
                                hintText: "Amount",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20,),

            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: TextField(
                      focusNode: _partyFieldFocusNode_2,
                      controller: _partyController_2,
                      decoration: InputDecoration(
                        hintText: "Party*",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery_2 = value;
                          filteredParties = parties_2
                              .where((party) => party["name"]
                              .toLowerCase()
                              .contains(searchQuery_2.toLowerCase()))
                              .toList();
                        });
                      },
                    ),
                  ),
                  if (showOptions_2)
                    Expanded(
                      child: filteredParties_2.isEmpty
                          ? ListTile(
                        title: Text("No matching parties found"),
                        trailing: TextButton(
                          onPressed: () {
                            // Navigate to Add New Party Page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Add_new_Party(),
                              ),
                            );
                          },
                          child: Text(
                            "Add new party",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      )
                          : ListView.builder(
                        itemCount: filteredParties_2.length,
                        itemBuilder: (context, index) {
                          final party = filteredParties_2[index];
                          return ListTile(
                            title: Text(party["name"]),
                            subtitle: Text(party["phone"]),
                            trailing: Text(
                              "${party["balance"] < 0 ? '🔺' : '🔻'} ${party["balance"].abs()}",
                              style: TextStyle(
                                color: party["balance"] < 0 ? Colors.red : Colors.green,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _partyController_2.text = party["name"];
                                showOptions_2 = false;
                                _partyFieldFocusNode_2.unfocus();
                              });
                            },
                          );
                        },
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.grey[200], // Background for the toggle container
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Received Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex_payment_2 = 0;
                                    selectedIndex_payment = 1;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20), // Adjusted height and width
                                  constraints: BoxConstraints(minWidth: 60), // Ensures a wider button
                                  decoration: BoxDecoration(
                                    color: selectedIndex_payment_2 == 0 ? Colors.green : Colors.transparent,
                                    borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Received",
                                      style: TextStyle(
                                        color: selectedIndex_payment_2 == 0 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Paid Button
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex_payment_2 = 1;
                                    selectedIndex_payment = 0;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 2, horizontal: 20), // Adjusted height and width
                                  constraints: BoxConstraints(minWidth: 40), // Ensures a wider button
                                  decoration: BoxDecoration(
                                    color: selectedIndex_payment_2 == 1 ? Colors.deepOrange : Colors.transparent,
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(30),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Paid",
                                      style: TextStyle(
                                        color: selectedIndex_payment_2 == 1 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Amount",
                                hintText: "Amount",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      height:75,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Description",
                                hintText: 'Add Note',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blue, width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.0,
                                  horizontal: 16.0,
                                ),
                              ),
                              maxLines: 3, // Allows multi-line input
                            ),
                          ),
                          SizedBox(width: 10.0),
                          GestureDetector(
                            onTap:(){
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: Text("Camera"),
                                          onTap: () {
                                            Navigator.pop(context); // Close the dialog
                                          },
                                        ),
                                        Divider(),
                                        ListTile(
                                          title: Text("Gallery"),
                                          onTap: () {
                                            Navigator.pop(context); // Close the dialog
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }, // Show the dialog on tap
                            child: Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue, width: 1.5),
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey[100],
                              ),
                              child: Icon(FlutterRemix.camera_line),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  }
}
