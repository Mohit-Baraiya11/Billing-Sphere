
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';
import '../../../Prefered_underline_appbar.dart';
import '../Sale Transaction/Add_Items_to_Sale.dart';

class Add_new_Sales extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddNewSales();
}

class AddNewSales extends State<Add_new_Sales> {
  var time = DateTime.now();
  var invoice_no = 0;

  TextEditingController customer_controller = TextEditingController();
  // String? customer_name;

  TextEditingController phonenumber_controller = TextEditingController();

  TextEditingController received_money = TextEditingController();
  TextEditingController balance_due = TextEditingController();

  TextEditingController description_controller = TextEditingController();

  TextEditingController total_amount = TextEditingController();
  String? selectedPaymentType = "Cash";

  String? Country = "Gujrat";
  bool isChecked = false;

  String type = "Credit";
  String? image;
  bool isExpanded = true;
  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      if(base64Image!=null){
        setState(() {
          image = base64Image;
        });
      }
    }
  }


  double calculateTotalQuantity() {
    return addedItems.fold(0.0, (sum, item) => sum + (double.tryParse(item["quantity"].toString()) ?? 0.0));
  }

  double calculateTotalDiscount() {
    return addedItems.fold(0.0, (sum, item) {
      double subtotal = (double.tryParse(item["rate"].toString()) ?? 0.0) * (double.tryParse(item["quantity"].toString()) ?? 0.0);
      double discount = double.tryParse(item["discount"].toString()) ?? 0.0;
      return sum + (subtotal * discount / 100);
    });
  }

  double calculateTotalTax() {
    return addedItems.fold(0.0, (sum, item) {
      double subtotal = (double.tryParse(item["rate"].toString()) ?? 0.0) * (double.tryParse(item["quantity"].toString()) ?? 0.0);
      double discount = double.tryParse(item["discount"].toString()) ?? 0.0;
      double discountedSubtotal = subtotal - (subtotal * discount / 100);
      double tax = double.tryParse(item["tax"].toString()) ?? 0.0;
      return sum + (discountedSubtotal * tax / 100);
    });
  }

  double calculateTotalFinalAmount() {
    return addedItems.fold(0.0, (sum, item) {
      double rate = double.tryParse(item["rate"].toString()) ?? 0.0;
      double quantity = double.tryParse(item["quantity"].toString()) ?? 0.0;
      double subtotal = rate * quantity;
      double discount = double.tryParse(item["discount"].toString()) ?? 0.0;
      double discountAmt = (subtotal * discount) / 100;
      double tax = double.tryParse(item["taxValue"].toString()) ?? 0.0;
      double taxAmt = ((subtotal - discountAmt) * tax) / 100;
      total_amount.text = (sum + (subtotal - discountAmt + taxAmt)).toString();
      return sum + (subtotal - discountAmt + taxAmt);
    });
  }
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

  void calculateBalanceDue() {
    double totalAmount = total_amount.text.isNotEmpty ? double.tryParse(total_amount.text) ?? 0.0 : 0.0;
    double receivedMoney = received_money.text.isNotEmpty ? double.tryParse(received_money.text) ?? 0.0 : 0.0;

    double balanceDue = totalAmount - receivedMoney;
    setState(() {
      balance_due.text = balanceDue.toStringAsFixed(2); // Format to 2 decimal places
    });
  }

  Future<void> saveSaleData(String userId) async {
    DatabaseReference paymentInRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/");
    DatabaseReference bankAccountRef;
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

    // Generate a unique transaction ID
    String transactionId = paymentInRef.push().key!;

    if (selectedPaymentType == "Cash") {
      bankAccountRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash/Cash_transaction");
    } else {
      bankAccountRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank/$selectedPaymentType/Bank_transaction");
    }

    if (invoice_no != null &&
        customer_controller.text.isNotEmpty &&
        phonenumber_controller.text.isNotEmpty &&
        received_money.text.isNotEmpty &&
        selectedPaymentType != null &&
        description_controller.text.isNotEmpty) {

      DatabaseReference totalBalanceRef;
      if (selectedPaymentType == "Cash") {
        totalBalanceRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash/total_balance");
      } else {
        totalBalanceRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank/$selectedPaymentType/total_balance");
      }

      DatabaseEvent event = await totalBalanceRef.once();
      double totalBalance = 0;
      if (event.snapshot.value != null) {
        totalBalance = double.parse(event.snapshot.value.toString());
      }

      double totalAmount = double.tryParse(total_amount.text) ?? 0.0;
      double receivedAmount = double.tryParse(received_money.text) ?? 0.0;
      double balanceDue = double.tryParse(balance_due.text) ?? 0.0; // Negative in Parties
      double newTotalBalance = totalBalance + receivedAmount;

      int currentTime = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> paymentData = {
        "transactionId": transactionId,
        "type": "sale",
        "invoice_no": invoice_no,
        "date": "${time.day}/${time.month}/${time.year}",
        "customer": customer_controller.text,
        "phone": phonenumber_controller.text,
        "total_amount": totalAmount.toString(),
        "received": receivedAmount.toString(),
        "balance_due": balanceDue.toString(),
        "paymentType": selectedPaymentType,
        "description": description_controller.text,
        "Image": image ?? null,
        "current_time": currentTime,
      };

      await paymentInRef.child(transactionId).set(paymentData);

      // ✅ Store each item inside the "items" node under the same transaction
      DatabaseReference itemsRef = paymentInRef.child(transactionId).child("items");
      for (var i = 0; i < addedItems.length; i++) {
        // Generate the key in the format "item_0", "item_1", etc.
        String itemKey = "item_$i";

        // Save the item with the custom key
        await itemsRef.child(itemKey).set({
          "itemName": addedItems[i]["itemName"],
          "quantity": addedItems[i]["quantity"],
          "unit": addedItems[i]["unit"],
          "rate": addedItems[i]["rate"],
          "taxValue": addedItems[i]["taxValue"],
          "discount": addedItems[i]["discount"],
          "subtotal": addedItems[i]["subtotal"],
        });
      }

      // ✅ Update Bank Transaction
      Map<String, dynamic> bankTransactionData = {
        "transactionId": transactionId,
        "date": "${time.day}/${time.month}/${time.year}",
        "amount": received_money.text,
        "current_time": currentTime,
        "transaction": paymentData,
      };

      await bankAccountRef.child(transactionId).set(bankTransactionData);
      await totalBalanceRef.set(newTotalBalance);

      // ✅ Update the 'Parties' node
      String customerName = customer_controller.text;
      String phoneNumber = phonenumber_controller.text;

      DatabaseReference partyQuery = partiesRef.child(phoneNumber);
      DatabaseEvent partyEvent = await partyQuery.once();

      double totalPartyAmount = -balanceDue; // Deduct the due amount from total_amount

      if (partyEvent.snapshot.value != null) {
        Map<dynamic, dynamic> partyData = partyEvent.snapshot.value as Map<dynamic, dynamic>;
        double existingAmount = double.parse(partyData["total_amount"].toString());
        totalPartyAmount += existingAmount;
      }

      Map<String, dynamic> partyData = {
        "name": customerName,
        "phone": phoneNumber,
        "total_amount": totalPartyAmount.toString(),
      };

      await partiesRef.child(phoneNumber).update(partyData); // ✅ Update without overwriting transactions

      // ✅ Append transaction under Parties/{phone}/transactions
      await partiesRef.child(phoneNumber).child("transactions").update({
        transactionId: paymentData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale Data, Items & Bank Updated Successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter required details!")),
      );
    }
  }



  @override
  void initState() {
    super.initState();

    // Add listeners to update balance when text changes
    total_amount.addListener(calculateBalanceDue);
    received_money.addListener(calculateBalanceDue);
  }

  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    total_amount.dispose();
    received_money.dispose();
    balance_due.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('Sale', style: TextStyle(color: Colors.black)),
        bottom:Prefered_underline_appbar(),
      ),
       bottomNavigationBar:
       BottomNavbarSaveButton(
         leftButtonText: 'cencle',
         rightButtonText: 'save',
         leftButtonColor: Colors.white,
         rightButtonColor: Colors.blueAccent,
         onLeftButtonPressed: (){},
         onRightButtonPressed: ()async{
           User? user = FirebaseAuth.instance.currentUser;
           if (user != null) {
             await saveSaleData(user.uid);
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('User not logged in!')),
             );
           }
         },
       ),
      body: Container(
        color:  Color(0xFFE8E8E8),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
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
                              showInvoiceSheet(context, (newInvoice) {
                                setState(() {
                                  invoice_no = newInvoice;
                                });
                              });
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
                              showInvoiceSheet(context, (newInvoice) {
                                setState(() {
                                  invoice_no = newInvoice;
                                });
                              });                            },
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
                  child: Column(
                    children: [
                      TextField(
                        controller:customer_controller,
                        onChanged: (String value){
                          setState(() {
                            customer_controller.text = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Customer",
                          hintText: "Customer name",
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
                        keyboardType: TextInputType.phone,
                        controller: phonenumber_controller,
                        onChanged: (String value){
                          setState(() {
                            phonenumber_controller.text=value;
                          });
                        },
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
                    ],
                  ),
                ),

                //Billed Items
            // Billed Items Section
            if (addedItems.isNotEmpty)
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Expand/Collapse Header
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

                    // Items List (Expandable)
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
                          padding: EdgeInsets.all(12),
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: addedItems.length,
                                itemBuilder: (context, index) {
                                  // Convert values safely
                                  double rate = double.tryParse(addedItems[index]["rate"].toString()) ?? 0.0;
                                  double quantity = double.tryParse(addedItems[index]["quantity"].toString()) ?? 0.0;
                                  double subtotal = rate * quantity;
                                  double discount = double.tryParse(addedItems[index]["discount"].toString()) ?? 0.0;
                                  double tax = double.tryParse(addedItems[index]["taxValue"].toString()) ?? 0.0;

                                  double discountAmt = (subtotal * discount) / 100;
                                  double taxAmt = ((subtotal - discountAmt) * tax) / 100;
                                  double finalAmount = subtotal - discountAmt + taxAmt;

                                  return GestureDetector(
                                    onTap: () async {
                                      final updatedItem = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Add_Items_to_Sale(
                                            title: "Edit Item",
                                            existingItem: addedItems[index], // Pass the item data
                                          ),
                                        ),
                                      );

                                      // If the user saves the edited item, update the list
                                      if (updatedItem != null) {
                                        setState(() {
                                          addedItems[index] = updatedItem; // Update the item in the list
                                        });
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Item Row with Delete Button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text("#${index + 1}  ${addedItems[index]["itemName"]}",
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            ),
                                            Text("₹ ${finalAmount.toStringAsFixed(2)}",
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                setState(() {
                                                  addedItems.removeAt(index); // ✅ Remove item
                                                });
                                              },
                                            ),
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
                                              "₹ ${discountAmt.toStringAsFixed(2)}",
                                              style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 5),

                                        // Tax Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("GST (${tax.toString()}%):", style: TextStyle(color: Colors.grey[600])),
                                            Text(
                                              "₹ ${taxAmt.toStringAsFixed(2)}",
                                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Divider(color: Colors.grey[300]),

                              // ✅ Total Calculation Section
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Discount: ₹ ${calculateTotalDiscount().toStringAsFixed(2)}"),
                                  Text("Total Tax: ₹ ${calculateTotalTax().toStringAsFixed(2)}"),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Total Qty: ${calculateTotalQuantity()}"),
                                  Text(
                                    "Total Amount: ₹ ${calculateTotalFinalAmount().toStringAsFixed(2)}",
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



               //total amount
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
                                    readOnly: addedItems.isNotEmpty,
                                    controller: total_amount,
                                    onChanged: (value) {
                                      setState(() {
                                        total_amount.text = value;
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

                      if (total_amount.text != null && total_amount.text.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child:Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "Received",
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
                                      controller: received_money,
                                      onChanged: (value) {
                                        setState(() {
                                          received_money.text = value;
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

                      if (total_amount.text != null && total_amount.text!.isNotEmpty)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                "Balance Due",
                                style: TextStyle(fontSize: 16, color: Colors.green),
                              ),
                            ),
                            SizedBox(
                              width: 15, // Fixed width for rupee symbol
                              child: Icon(Icons.currency_rupee, size: 15, color: Colors.green),
                            ),
                            Expanded(
                              flex: 1,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "${balance_due.text}",
                                  style: TextStyle(color: Colors.green, fontSize: 16),
                                ),
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
                                    onTap: (){
                                      select_payment_method(context);
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
                                  controller: description_controller,
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
                                  uploadImage();
                                }, // Show the dialog on tap
                                child: Container(
                                  width: 75,
                                  height: 75,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue, width: 1.5),
                                    borderRadius: BorderRadius.circular(8.0),
                                    color: Colors.grey[100],
                                  ),
                                  child: image!=null?Image.memory(base64Decode(image!)):Icon(Remix.folder_image_line),
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
    );
  }
  void select_payment_method(BuildContext context) {
    // Fetch bank accounts from Firebase
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }
    String userId = user.uid;

    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child('$userId')
        .child('Bank_accounts')
        .child('Bank');

    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Payment Type", style: TextStyle(fontSize: 22)),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Remix.close_line),
                      ),
                    ],
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1),
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
                  // Fetch and display bank accounts
                  FutureBuilder(
                    future: ref.once(),
                    builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                        return Text('No bank accounts found');
                      } else {
                        // Parse the bank accounts data
                        Map<dynamic, dynamic> banks = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                        return Column(
                          children: banks.entries.map((entry) {
                            var bank = entry.value;
                            return ListTile(
                              leading: Icon(Icons.account_balance, color: Colors.blue),
                              title: Text(bank['bank_name']),
                              subtitle: Text("Account Holder: ${bank['holder_name']}"),
                              onTap: () {
                                setState(() {
                                  selectedPaymentType = bank['bank_name'];
                                });
                                Navigator.pop(context);
                              },
                              tileColor: selectedPaymentType == bank['bank_name']
                                  ? Colors.grey[200]
                                  : null,
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
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
  }
  void showInvoiceSheet(BuildContext context, Function(int) updateInvoice) {
    int? localInvoiceNo = invoice_no; // Temporary variable

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                              child: Icon(Icons.cancel, size: 30),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              localInvoiceNo = int.tryParse(val) ?? 0;
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Invoice No",
                            hintText: "Enter Invoice No",
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
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: () {
                              updateInvoice(localInvoiceNo!);
                              Navigator.pop(context);
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
}