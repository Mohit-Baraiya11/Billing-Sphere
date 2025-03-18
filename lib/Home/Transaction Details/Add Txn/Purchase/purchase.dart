import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';
import '../../../Prefered_underline_appbar.dart';
import '../Sale Transaction/Add_Items_to_Sale.dart';

class Purchase extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Purchase();
}

class _Purchase extends State<Purchase> {
  var time = DateTime.now();
  var invoice_no = 0;
  String? enteredText;
  String? selectedPaymentType = "Cash";
  String? Country = "Gujrat";
  bool isChecked = false;


  //controlllers
  TextEditingController description_controller = TextEditingController();
  TextEditingController customer_controller = TextEditingController();
  TextEditingController phonenumber_controller = TextEditingController();
  TextEditingController total_amount = TextEditingController();
  TextEditingController paid_money = TextEditingController();
  TextEditingController balance_due = TextEditingController();


  String? selectedState;

  String? image;

  Future<void> savePaymentInData(String userId) async {
    DatabaseReference paymentInRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/");

    // Generate a unique transaction ID
    String transactionId = paymentInRef.push().key!;

    // Prepare payment data
    Map<String, dynamic> paymentData = {
      "type": "purchase",
      "invoice_no": invoice_no,
      "date": "${time.day}/${time.month}/${time.year}",
      "party_name": customer_controller.text ?? "",
      "phone": phonenumber_controller.text,
      "total_amount":total_amount.text,
      "paid_amount": paid_money.text ?? "",
      "balance_due": balance_due.text,
      "paymentType": selectedPaymentType,
      "description": description_controller.text,
      "Image": image ?? "Null",
    };

    // Store the main payment data under the transaction ID
    await paymentInRef.child(transactionId).set(paymentData);

    // Reference to store items within the same transaction
    DatabaseReference itemsRef = paymentInRef.child(transactionId).child("items");

    // Store each item inside the "items" node under the same transaction
    for (var i = 0; i < addedItems.length; i++) {
      String itemId = itemsRef.push().key!; // Generate unique item ID
      await itemsRef.child(itemId).set({
        "itemName": addedItems[i]["itemName"],
        "quantity": addedItems[i]["quantity"],
        "unit": addedItems[i]["unit"],
        "rate": addedItems[i]["rate"],
        "tax": addedItems[i]["tax"],
        "discount": addedItems[i]["discount"],
        "subtotal": addedItems[i]["subtotal"],
      });
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase Data & Items Saved Successfully!')),
    );
  }


  bool isExpanded = false;

  List<Map<String, dynamic>> addedItems = [];
  void _navigateToAddItemScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Add_Items_to_Sale(title: "Add Item")),
    );

    if (result != null) {
      setState(() {
        print(result);
        addedItems.add(result); // Add new item to the list
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    balance_due.text = "0";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Purchase'),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Add settings functionality here
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavbarSaveButton(
        leftButtonText: 'cencle',
        rightButtonText: 'save',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.blueAccent,
        onLeftButtonPressed: (){},
        onRightButtonPressed: () async {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await savePaymentInData(user.uid);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not logged in!')),
            );
          }
        },
      ),
      body: Container(
        color:  Color(0xFFE8E8E8),        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color:Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0,right: 16.0,bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showInvoiceSheet(context);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Recipt No.",style: TextStyle(color: Colors.grey),),
                                      Row(
                                        children: [
                                          Text("$invoice_no"),
                                          SizedBox(width: 5,),
                                          Icon(
                                            Remix.arrow_down_s_line,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 25,
                                child: VerticalDivider(
                                  color: Colors.grey.shade300,
                                  thickness: 2,
                                  width: 20,
                                ),
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showInvoiceSheet(context);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
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
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Date",style: TextStyle(color: Colors.grey),),
                                            Row(
                                              children: [
                                                Text(
                                                  "${time.day}/${time.month}/${time.year}",
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                                Icon(
                                                  Remix.arrow_down_s_line,
                                                  size: 20,
                                                  color: Colors.grey,
                                                ),
                                              ],
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
                      ),
                      SizedBox(height: 15,),

                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(16),
                        child:Column(
                          children: [
                            TextField(
                              onChanged: (value){
                                setState(() {
                                  customer_controller.text = value;
                                });
                              },
                              controller:customer_controller,
                              decoration: InputDecoration(
                                labelText: "Party Name",
                                hintText: "Party name",
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
                            //Phone number
                            TextField(
                              keyboardType: TextInputType.phone,
                              onChanged: (value){
                                setState(() {
                                  phonenumber_controller.text = value;
                                });
                              },
                              controller: phonenumber_controller,
                              decoration: InputDecoration(
                                labelText: "Phone Number",
                                hintText: "Phone number",
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
                            SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: () {
                                _navigateToAddItemScreen(context);
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blueAccent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: Colors.blueAccent),
                                  SizedBox(width: 8),
                                  Text("Add Items", style: TextStyle(color: Colors.blueAccent)),
                                  SizedBox(width: 8),
                                  Text("(Optional)", style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                      ),

                      if(!addedItems.isEmpty)
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Billed Items Header (Click to Expand/Collapse)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Billed Items",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Icon(
                                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                      )
                                    ],
                                  ),
                                ),
                              ),

                              // Content Section (Shown only when expanded)
                              if (isExpanded)
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 5,
                                        spreadRadius: 2,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12), // Inner padding
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true, // Allows ListView to take only required height
                                          physics: NeverScrollableScrollPhysics(), // Prevents nested scrolling issues
                                          itemCount: addedItems.length,
                                          itemBuilder: (context, index) {
                                            // Convert values safely
                                            double rate = double.tryParse(addedItems[index]["rate"].toString()) ?? 0.0;
                                            double quantity = double.tryParse(addedItems[index]["quantity"].toString()) ?? 0.0;
                                            double subtotal = rate * quantity; // Correct calculation
                                            double discount = double.tryParse(addedItems[index]["discount"].toString()) ?? 0.0;

                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Item Row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("#${index + 1}  ${addedItems[index]["itemName"]}",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                    Text("₹ ${subtotal.toStringAsFixed(2)}",
                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                                SizedBox(height: 5),

                                                // Item Subtotal
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text("Item Subtotal:", style: TextStyle(color: Colors.grey[600])),
                                                    Text(
                                                      "$rate ${addedItems[index]["unit"]} x $quantity = ₹ ${subtotal.toStringAsFixed(2)}",
                                                      style: TextStyle(color: Colors.grey[600]),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 5),

                                                // Discount Row
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    RichText(
                                                      text: TextSpan(
                                                        text: "Discount (%): ",
                                                        style: TextStyle(color: Colors.orange[700], fontSize: 14),
                                                        children: [
                                                          TextSpan(
                                                            text: discount.toString(),
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      "₹ ${((subtotal * discount) / 100).toStringAsFixed(2)}", // Corrected discount calculation
                                                      style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),

                                                SizedBox(height: 5),

                                                // Tax Row
                                                Text(
                                                  "${addedItems[index]["tax"]}",
                                                  style: TextStyle(color: Colors.grey[600]),
                                                ),

                                                SizedBox(height: 10),
                                              ],
                                            );
                                          },
                                        ),
                                        Divider(color: Colors.grey[300]),

                                        // Total Details
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Total Disc: 9.0"),
                                            Text("Total Tax Amt: 0.0"),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("Total Qty: 10.0"),
                                            Text(
                                              "Subtotal: 91.00",
                                              style: TextStyle(fontWeight: FontWeight.bold),
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

                      Container(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                             Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Total Amount",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15, // Fixed width for rupee symbol
                                    child: Icon(Icons.currency_rupee, size: 15),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Stack(
                                      children: [
                                        // Dotted Border (Only Bottom)
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: DottedBorder(
                                            color: Colors.grey,
                                            strokeWidth: 1.5, // Border thickness
                                            dashPattern: [5, 3], // Dotted pattern
                                            borderType: BorderType.Rect, // Rectangle border
                                            padding: EdgeInsets.zero, // No padding inside
                                            customPath: (size) => Path()
                                              ..moveTo(0, size.height) // Start from bottom-left
                                              ..lineTo(size.width, size.height), // Draw to bottom-right
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 0, // Invisible container to align with textfield
                                            ),
                                          ),
                                        ),

                                        // TextField
                                        TextField(
                                          controller: total_amount,
                                          onChanged: (value) {
                                            setState(() {
                                               total_amount.text= value;
                                            });
                                          },
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.end,
                                          decoration: InputDecoration(
                                            border: InputBorder.none, // Removes default border
                                            contentPadding: EdgeInsets.only(bottom: 5), // Align text properly
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                            if (total_amount != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          activeColor: Colors.blueAccent,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isChecked = value!;
                                            });
                                          },
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Paid",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        SizedBox(width: 65,),
                                        SizedBox(
                                          width: 15, // Fixed width for rupee symbol
                                          child: Icon(Icons.currency_rupee, size: 15),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Stack(
                                            children: [
                                              // Dotted Border (Only Bottom)
                                              Positioned(
                                                bottom: 0,
                                                left: 0,
                                                right: 0,
                                                child: DottedBorder(
                                                  color: Colors.grey,
                                                  strokeWidth: 1.5, // Border thickness
                                                  dashPattern: [5, 3], // Dotted pattern
                                                  borderType: BorderType.Rect, // Rectangle border
                                                  padding: EdgeInsets.zero, // No padding inside
                                                  customPath: (size) => Path()
                                                    ..moveTo(0, size.height) // Start from bottom-left
                                                    ..lineTo(size.width, size.height), // Draw to bottom-right
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    height: 0, // Invisible container to align with textfield
                                                  ),
                                                ),
                                              ),

                                              // TextField
                                              TextField(
                                                controller: paid_money,
                                                onChanged: (value) {
                                                  setState(() {
                                                     paid_money.text= value;
                                                  });
                                                },
                                                keyboardType: TextInputType.number,
                                                textAlign: TextAlign.end,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none, // Removes default border
                                                  contentPadding: EdgeInsets.only(bottom: 5), // Align text properly
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Balance Due",
                                    style: TextStyle(fontSize: 16,color: Color(0xFF38C782)),
                                  ),
                                ),
                                SizedBox(
                                  width: 15, // Fixed width for rupee symbol
                                  child: Icon(Icons.currency_rupee, size: 15,color: Color(0xFF38C782),),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Stack(
                                    children: [

                                      // TextField
                                      TextField(
                                        readOnly: true,
                                        controller: balance_due,
                                        style: TextStyle(color: Color(0xFF38C782)),
                                        onChanged: (value) {
                                          setState(() {
                                            balance_due.text= value;
                                          });
                                        },
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.end,
                                        decoration: InputDecoration(
                                          border: InputBorder.none, // Removes default border
                                          contentPadding: EdgeInsets.only(bottom: 5), // Align text properly
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
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0,right: 16,bottom: 16,top: 16),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Payment Type", style: TextStyle(fontSize: 15, color: Colors.black)),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              backgroundColor: Colors.white,
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (context) {
                                                return StatefulBuilder(
                                                  builder: (context, setStateModal) { // Use setStateModal for local state changes
                                                    return Padding(
                                                      padding: const EdgeInsets.all(16.0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text("Payment Type",style: TextStyle(fontSize: 22),),
                                                          ListTile(
                                                            leading: Icon(Icons.money, color: Colors.green),
                                                            title: Text("Cash"),
                                                            onTap: () {
                                                              setState(() {
                                                                selectedPaymentType = "Cash";
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            tileColor: selectedPaymentType == "Cash"
                                                                ? Colors.grey[200]
                                                                : null,
                                                          ),
                                                          ListTile(
                                                            leading: Icon(Icons.receipt_long, color: Colors.yellow),
                                                            title: Text("Cheque"),
                                                            onTap: () {
                                                              setState(() {
                                                                selectedPaymentType = "Cheque";
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            tileColor: selectedPaymentType == "Cheque"
                                                                ? Colors.grey[200]
                                                                : null,
                                                          ),
                                                          Divider(),
                                                          ListTile(
                                                            leading: Icon(Icons.add, color: Colors.blue),
                                                            title: Text("Add Bank A/c"),
                                                            onTap: () {
                                                              // Handle "Add Bank A/c" logic
                                                              Navigator.pop(context);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                selectedPaymentType == "Cash"
                                                    ? Icons.money
                                                    : selectedPaymentType == "Cheque"
                                                    ? Icons.receipt_long
                                                    : Icons.help_outline, // Default icon when null
                                                color: selectedPaymentType == "Cash"
                                                    ? Colors.green
                                                    : selectedPaymentType == "Cheque"
                                                    ? Colors.yellow
                                                    : Colors.grey, // Default color when null
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                selectedPaymentType ?? "Select", // Fallback if null
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Icon(Icons.arrow_drop_down, color: Colors.grey),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text("+Add Payment Type",style: TextStyle(color: Colors.blueAccent,fontSize: 16),),
                                  )
                              ),
                              SizedBox(height: 10,),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("State", style: TextStyle(fontSize: 15, color: Colors.black)),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.topRight,
                                            child: GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  backgroundColor: Colors.white,
                                                  context: context,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                                  ),
                                                  builder: (context) {
                                                    return StatefulBuilder(
                                                      builder: (context, setStateModal) {
                                                        return Padding(
                                                          padding: const EdgeInsets.all(16.0),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Text(
                                                                "Select State",
                                                                style: TextStyle(fontSize: 22),
                                                              ),
                                                              Divider(),
                                                              Expanded(
                                                                child: ListView(
                                                                  children: [
                                                                    for (var state in [
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
                                                                      "Andaman and Nicobar Islands",
                                                                      "Chandigarh",
                                                                      "Dadra and Nagar Haveli and Daman and Diu",
                                                                      "Delhi",
                                                                      "Jammu and Kashmir",
                                                                      "Ladakh",
                                                                      "Lakshadweep",
                                                                      "Puducherry"
                                                                    ])
                                                                      ListTile(
                                                                        title: Text(state),
                                                                        onTap: () {
                                                                          setState(() {
                                                                            Country = state;
                                                                          });
                                                                          Navigator.pop(context);
                                                                        },
                                                                        tileColor: Country == state
                                                                            ? Colors.grey[200]
                                                                            : null,
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    Country ?? "Select", // Fallback if null
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  Icon(Icons.arrow_drop_down, color: Colors.grey),
                                                ],
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
                      ),
                      SizedBox(height: 10,),

                      //description and image
                      Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(left: 16,right: 16.0,top: 8,bottom: 8),
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
                                        onChanged: (value){
                                          setState(() {
                                            description_controller.text = value;
                                          });
                                        },
                                        controller:description_controller,
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
                      SizedBox(height: 10,),

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

List<String> PrefixName = ["None"];
List<int> PrefixNumber = [0];

int _selectedButton = 0;
String? newPrefix;

void showInvoiceSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 2.0,
              right: 2.0,
              top: 10.0,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              "Change Receipt No.",
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.cancel,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Invoice Prefix",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: PrefixName.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedButton = index;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: index == _selectedButton
                                              ? Colors.redAccent
                                              : Colors.grey,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        color: index == _selectedButton
                                            ? Colors.red[50]
                                            : Colors.transparent,
                                      ),
                                      child: Text(
                                        '${PrefixName[index]}',
                                        style: TextStyle(
                                          color: index == _selectedButton
                                              ? Colors.redAccent
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    'Add Prefix',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  backgroundColor: Colors.white,
                                  content: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: SizedBox(
                                      width: 600,
                                      child: TextField(
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          labelText: "Prefix Name",
                                          hintText: "e.g. INV",
                                          border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.blueAccent,
                                                width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0),
                                            borderSide: BorderSide(
                                                color: Colors.grey, width: 1.0),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          newPrefix = value;
                                        },
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        if (newPrefix != null &&
                                            newPrefix!.isNotEmpty) {
                                          setState(() {
                                            PrefixName.add(newPrefix!);
                                            newPrefix = null;
                                          });
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                        "Save",
                                        style: TextStyle(color: Colors.blueAccent),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.grey[50],
                            ),
                            child: Text(
                              'Add Prefix',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Invoice No",
                          hintText: "Invoice No",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                            BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                            BorderSide(color: Colors.grey, width: 1.0),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            // Save logic
                          },
                          child: Text("SAVE"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}