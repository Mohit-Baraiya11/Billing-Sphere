import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/BottomNavbar_save_buttons.dart';
import '../Home/Prefered_underline_appbar.dart';

class Add_new_item extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Addnewitem();
}

class Addnewitem extends State<Add_new_item> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedTaxType = "Without Tax";
  String selectedDiscountType = "Percentage";

  TextEditingController _dateController = TextEditingController();
  TextEditingController _taxrate = TextEditingController();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    _dateController.text = formattedDate;

    _taxrate.text = "none";

    _tabController = TabController(length: 2, vsync: this); // Changed length to 2
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Item Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: Prefered_underline_appbar(),
      ),
      bottomNavigationBar: BottomNavbarSaveButton(
        leftButtonText: 'Cancel',
        rightButtonText: 'Save',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.red,
        onLeftButtonPressed: () {},
        onRightButtonPressed: () {},
      ),
      body: Container(
        color: Colors.blue[50],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name with Button
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.white,
                child: Column(
                  children: [
                    // Item name
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Item Name",
                                hintText: "Item Name",
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                    ),

                    // Item code / Barcode
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "Item Code / Barcode",
                                hintText: "Item Code / Barcode",
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                    ),

                    // Item Category
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                showModalBottomSheet(
                                   backgroundColor: Colors.white,
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context){
                                      return Container(
                                        color: Colors.white,
                                        child: FractionallySizedBox(
                                          heightFactor: 0.85,
                                            child:Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Select Category",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                                    IconButton(
                                                        onPressed: (){
                                                          Navigator.pop(context);
                                                          },
                                                        icon: Icon(Icons.close)
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                                TextField(
                                                  readOnly: true,
                                                  decoration: InputDecoration(
                                                    prefixIcon: Icon(FlutterRemix.search_2_line,color: Colors.blueAccent,),
                                                    hintText: "search Category",
                                                    suffixIcon: Icon(Remix.arrow_down_s_fill),
                                                    floatingLabelStyle: TextStyle(color: Colors.blue),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                    ),
                                                    focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                                      );
                                    }
                                );
                              },
                              child: TextField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: "Item Category",
                                  suffixIcon: Icon(Remix.arrow_down_s_fill),
                                  floatingLabelStyle: TextStyle(color: Colors.blue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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

                    // HSN / SAC Code
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: "HSN / SAC Code",
                                hintText: "HSN / SAC Code",
                                suffixIcon: Icon(FlutterRemix.search_line, color: Colors.blueAccent),
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController, // Use the _tabController here
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.red, width: 3.0),
                        insets: EdgeInsets.symmetric(horizontal: -50.0),
                      ),
                      indicatorColor: Colors.red,
                      indicatorWeight: 2.0,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: 'Pricing'),
                        Tab(text: 'Stock'),
                      ],
                    ),
                    Container(
                      height: 540,
                      child: TabBarView(
                        controller: _tabController, // Use the _tabController here
                        children: [
                          // Pricing Tab
                          Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Sale Price", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 16),
                                      TextField(
                                        decoration: InputDecoration(
                                          labelText: "Sale Price",
                                          hintText: "Sale Price",
                                          floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                          labelText: "Disc On Sale Price",
                                          hintText: "Disc On Sale Prices",
                                          floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                      SizedBox(height: 10),
                                      Text("+ Add Wholesale Price", style: TextStyle(color: Colors.blueAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.blue[50],
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Purchase Price", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: "Purchase Item",
                                                hintText: "Purchase Item",
                                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.blue[50],
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Taxes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _taxrate,
                                              decoration: InputDecoration(
                                                labelText: "Tax Rate",
                                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Stock Tab
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 16),
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: "Opening Stock",
                                      hintText: "Ex:300",
                                      floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                          controller: _dateController,
                                          readOnly: true,
                                          keyboardType: TextInputType.datetime,
                                          decoration: InputDecoration(
                                            labelText: "As of Date",
                                            suffixIcon: Icon(FlutterRemix.calendar_2_line),
                                            floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "At Price/Unit",
                                            hintText: "Ex:2000",
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
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.datetime,
                                          decoration: InputDecoration(
                                            labelText: "Min Stock Qty",
                                            hintText: "Ex:5",
                                            floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "Item Location",
                                            hintText: "Item Location",
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
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}