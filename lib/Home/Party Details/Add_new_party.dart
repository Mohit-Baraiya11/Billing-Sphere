import 'package:billing_sphere/Home/Prefered_underline_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../BottomNavbar_save_buttons.dart';


class Add_new_Party extends StatefulWidget{
  @override
  State<StatefulWidget> createState()=>AddnewParty();
}
class AddnewParty extends State<Add_new_Party>{

  TextEditingController enteredText = TextEditingController();
  String _selectedOption = 'To Receive';
  String selectedOption = "Unregistered/Consumer";
  String selectedState = "state";

  void _showGSTTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "GST Type",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(),
              ListTile(
                title: Text("Unregistered/Consumer"),
                onTap: () {
                  setState(() {
                    selectedOption = "Unregistered/Consumer";
                  });
                  Navigator.pop(context); // Close the BottomSheet
                },
              ),
              ListTile(
                title: Text("Registered - Regular"),
                onTap: () {
                  setState(() {
                    selectedOption = "Registered - Regular";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Registered - Composite"),
                onTap: () {
                  setState(() {
                    selectedOption = "Registered - Composite";
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
  void _showStateSelectionBottomSheet(BuildContext context) {
    final List<String> statesOfIndia = [
      "Andhra Pradesh",
      "Arunachal Pradesh",
      "Assam",
      "Bihar",
      "Chhattisgarh",
      "Goa",
      "Gujarat",
      "Haryana",
      "Himachal Pradesh",
      "Jharkhand",
      "Karnataka",
      "Kerala",
      "Madhya Pradesh",
      "Maharashtra",
      "Manipur",
      "Meghalaya",
      "Mizoram",
      "Nagaland",
      "Odisha",
      "Punjab",
      "Rajasthan",
      "Sikkim",
      "Tamil Nadu",
      "Telangana",
      "Tripura",
      "Uttar Pradesh",
      "Uttarakhand",
      "West Bengal",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select State",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: statesOfIndia.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(statesOfIndia[index]),
                      onTap: () {
                        setState(() {
                          selectedState = statesOfIndia[index];
                        });
                        Navigator.pop(context); // Close the BottomSheet
                      },
                    );
                  },
                ),
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
        backgroundColor: Colors.white,
        title: Text('Party To Party Transfer',style: TextStyle(fontSize: 20),),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
            icon: Icon(FlutterRemix.settings_2_line),
            onPressed: () {

            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbarSaveButton(leftButtonText: 'save & new', rightButtonText: 'save party', leftButtonColor: Colors.white,rightButtonColor: Colors.red,onLeftButtonPressed: (){},onRightButtonPressed: (){},),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextField(
                        controller:enteredText,
                        decoration: InputDecoration(
                          labelText: "Party Name",
                          hintText: "Party Name",
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
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          labelText: "GSTIN",
                          hintText: "GSTIN",
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
                      SizedBox(height: 16),
                      Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Contact Number",
                              hintText: "Contact Number",
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
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Opening Bal.",
                                    hintText: "Opening Bal.",
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
                              SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.datetime,
                                  decoration: InputDecoration(
                                    labelText: "As of Date",
                                    hintText: "As of Date",
                                    suffixIcon: Icon(
                                      FlutterRemix.calendar_2_line,
                                      color: Colors.blue,
                                    ),
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
                            ],
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'To Receive',
                                    activeColor: Colors.blue,
                                    groupValue: _selectedOption,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedOption = value!;
                                      });
                                    },
                                  ),
                                  Text('To Receive'),
                                ],
                              ),
                              Row(
                                children: [
                                  Radio<String>(
                                    value: 'To Pay',
                                    activeColor: Colors.blue,
                                    groupValue: _selectedOption,
                                    onChanged: (String? value) {
                                      setState(() {
                                        _selectedOption = value!;
                                      });
                                    },
                                  ),
                                  Text('To Pay'),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                TabBar(
                                  indicator: UnderlineTabIndicator(
                                    borderSide: BorderSide(color: Colors.red, width: 3.0), // Thickness of the underline
                                    insets: EdgeInsets.symmetric(horizontal: -50.0), // Extend the width of the indicator
                                  ),
                                  indicatorColor: Colors.red,
                                  indicatorWeight: 2.0,
                                  labelColor: Colors.red,
                                  unselectedLabelColor: Colors.grey,
                                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                                  tabs: [
                                    Tab(text: 'Addresses'),
                                    Tab(text: 'GST Details'),
                                  ],
                                ),
                                Container(
                                  height: 200, // Specify a height for TabBarView
                                  child: TabBarView(
                                    children: [
                                      Center(
                                        child:Column(
                                          children: [
                                            SizedBox(height: 16),
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: "Biiling Address",
                                                hintText: "Biiling Address",
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
                                            SizedBox(height: 16),
                                            TextField(
                                              decoration: InputDecoration(
                                                labelText: "Email Address",
                                                hintText: "Email Address",
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
                                          ],
                                        ),
                                      ),
                                      Center(
                                        child:Column(
                                          children: [
                                            SizedBox(height: 16),
                                            TextField(
                                              readOnly: true, // Prevent keyboard from opening
                                              controller: TextEditingController(text: selectedOption),
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.arrow_drop_down),
                                                labelText: "Select an Option",
                                                border: OutlineInputBorder(),
                                              ),
                                              onTap: () {
                                                _showGSTTypeBottomSheet(context); // Show the BottomSheet on tap
                                              },
                                            ),

                                            SizedBox(height: 16),
                                            TextField(
                                              readOnly: true, // Prevent keyboard from opening
                                              controller: TextEditingController(text: selectedState),
                                              decoration: InputDecoration(
                                                suffixIcon: Icon(Icons.arrow_drop_down),
                                                labelText: "State",
                                                border: OutlineInputBorder(),
                                              ),
                                              onTap: () {
                                                _showStateSelectionBottomSheet(context); // Show the BottomSheet on tap
                                              },
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
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}