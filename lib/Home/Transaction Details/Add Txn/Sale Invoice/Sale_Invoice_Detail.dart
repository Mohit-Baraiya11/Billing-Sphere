
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';
import '../../../Prefered_underline_appbar.dart';
import '../Sale Transaction/Add_Items_to_Sale.dart';

class Sale_Invoice_Detail extends StatefulWidget {
  String transactionId;
  Sale_Invoice_Detail({required this.transactionId});
  @override
  State<StatefulWidget> createState() => _Sale_Invoice_Detail(transactionId: this.transactionId);
}

class _Sale_Invoice_Detail extends State<Sale_Invoice_Detail> {

  String transactionId;
  _Sale_Invoice_Detail({required this.transactionId});

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
  bool isExpanded = false;

  bool is_readyonly = true;


  void _navigateToAddItemScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Add_Items_to_Sale(title: "Add Item")),
    );

    if (result != null) {
      setState(() {
        print(result);
        existingItems.add(result); // Add new item to the list
      });
    }
  }

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

  double calculateTotalQuantity(List<Map<String, dynamic>> existingItems) {
    return existingItems.fold(0.0, (sum, item) => sum + (double.tryParse(item["quantity"].toString()) ?? 0.0));
  }

  double calculateTotalDiscount(List<Map<String, dynamic>> existingItems) {
    return existingItems.fold(0.0, (sum, item) {
      double subtotal = (double.tryParse(item["rate"].toString()) ?? 0.0) * (double.tryParse(item["quantity"].toString()) ?? 0.0);
      double discount = double.tryParse(item["discount"].toString()) ?? 0.0;
      return sum + (subtotal * discount / 100);
    });
  }

  double calculateTotalTax(List<Map<String, dynamic>> existingItems) {
    return existingItems.fold(0.0, (sum, item) {
      double subtotal = (double.tryParse(item["rate"].toString()) ?? 0.0) * (double.tryParse(item["quantity"].toString()) ?? 0.0);
      double discount = double.tryParse(item["discount"].toString()) ?? 0.0;
      double discountedSubtotal = subtotal - (subtotal * discount / 100);
      double tax = double.tryParse(item["tax"].toString()) ?? 0.0;
      return sum + (discountedSubtotal * tax / 100);
    });
  }

  double calculateTotalFinalAmount(List<Map<String, dynamic>> existingItems) {
    return existingItems.fold(0.0, (sum, item) {
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


  List<Map<String, dynamic>> existingItems = []; // Store fetched items separately

  void fetchTransactionData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/${widget.transactionId}");

    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          customer_controller.text = data['customer'] ?? "";
          phonenumber_controller.text = data['phone'] ?? "";
          received_money.text = data['received'] ?? "";
          balance_due.text = data['balance_due'] ?? "";
          total_amount.text = data["total_amount"] ?? "";
          description_controller.text = data['description'] ?? "";
          invoice_no = int.tryParse(data['invoice_no'].toString()) ?? 0;
          selectedPaymentType = data['paymentType'] ?? "Cash";
          type = data['type'] ?? "Credit";
          image = data['Image'];
          isChecked = data['type'] == "Credit" ? false : true;

          // Store fetched items separately and convert numeric fields to double
          existingItems = [];
          if (data['items'] != null) {
            Map<String, dynamic> itemsMap = Map<String, dynamic>.from(data['items']);
            itemsMap.forEach((key, value) {
              existingItems.add({
                'discount': double.tryParse(value['discount'].toString()) ?? 0.0, // Convert to double
                'itemName': value['itemName'] ?? "", // Default value for itemName
                'quantity': double.tryParse(value['quantity'].toString()) ?? 0.0, // Convert to double
                'rate': double.tryParse(value['rate'].toString()) ?? 0.0, // Convert to double
                'subtotal': double.tryParse(value['subtotal'].toString()) ?? 0.0, // Convert to double
                'tax': double.tryParse(value['tax'].toString()) ?? 0.0, // Convert to double
                'taxValue': double.tryParse(value['taxValue'].toString()) ?? 0.0, // Convert to double
                'unit': value['unit'] ?? "", // Default value for unit
              });
            });
          }
        });

        print("Transaction data fetched successfully!");
      } else {
        print("No transaction found!");
      }
    } catch (error) {
      print("Error fetching transaction data: $error");
    }
  }
  void updateTransactionData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference transactionRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/${widget.transactionId}");
    DatabaseReference bankRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts");
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

    try {
      // Fetch existing transaction data
      DatabaseEvent event = await transactionRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (!snapshot.exists) {
        print("Transaction not found");
        return;
      }

      Map<String, dynamic> oldData = Map<String, dynamic>.from(snapshot.value as Map);
      String oldPaymentType = oldData['paymentType'] ?? "Cash";
      double oldReceivedAmount = double.tryParse(oldData['received'].toString()) ?? 0.0;
      double oldBalanceDue = double.tryParse(oldData['balance_due'].toString()) ?? 0.0;

      // Fetch new transaction values
      double newReceivedAmount = double.tryParse(received_money.text) ?? 0.0;
      double newBalanceDue = double.tryParse(balance_due.text) ?? 0.0;
      String? newPaymentType = selectedPaymentType;
      String phoneNumber = phonenumber_controller.text;

      // Fetch bank balances
      double oldBankBalance = 0.0, oldCashBalance = 0.0, newBankBalance = 0.0, newCashBalance = 0.0;

      DatabaseEvent bankEvent = await bankRef.once();
      if (bankEvent.snapshot.exists) {
        Map<String, dynamic> bankData = Map<String, dynamic>.from(bankEvent.snapshot.value as Map);
        oldCashBalance = double.tryParse(bankData['cash']?['total_balance']?.toString() ?? "0.0") ?? 0.0;
        oldBankBalance = double.tryParse(bankData[oldPaymentType]?['total_balance']?.toString() ?? "0.0") ?? 0.0;
        newBankBalance = double.tryParse(bankData[newPaymentType]?['total_balance']?.toString() ?? "0.0") ?? 0.0;
        newCashBalance = oldCashBalance; // Will update if needed
      }

      // ✅ **Remove the old transaction from the previous payment type**
      if (oldPaymentType == "Cash") {
        oldCashBalance -= oldReceivedAmount;
        await bankRef.child("Cash/Cash_transaction").child(widget.transactionId).remove();
      } else {
        oldBankBalance -= oldReceivedAmount;
        await bankRef.child("Bank/$oldPaymentType/Bank_transaction").child(widget.transactionId).remove();
      }

      // ✅ **Update the new payment type**
      if (newPaymentType == "Cash") {
        newCashBalance += newReceivedAmount;
        await bankRef.child("Cash/Cash_transaction").child(widget.transactionId).set({
          "amount": newReceivedAmount,
          "type": "Sale",
          "date": DateTime.now().toIso8601String(),
        });
      } else {
        newBankBalance += newReceivedAmount;
        await bankRef.child("Bank/$newPaymentType/Bank_transaction").child(widget.transactionId).set({
          "amount": newReceivedAmount,
          "type": "Sale",
          "date": DateTime.now().toIso8601String(),
        });
      }

      // ✅ **Update bank balances**
      await bankRef.child("Cash").update({"total_balance": newCashBalance});
      await bankRef.child("Bank/$newPaymentType").update({"total_balance": newBankBalance});

      // ✅ **Update the 'Parties' node**
      DatabaseReference partyRef = partiesRef.child(phoneNumber);
      DatabaseEvent partyEvent = await partyRef.once();
      double totalPartyAmount = 0.0;

      if (partyEvent.snapshot.exists) {
        Map<dynamic, dynamic> partyData = partyEvent.snapshot.value as Map<dynamic, dynamic>;
        double existingPartyAmount = double.tryParse(partyData["total_amount"].toString()) ?? 0.0;
        totalPartyAmount = existingPartyAmount + (oldBalanceDue - newBalanceDue);
      } else {
        totalPartyAmount = -newBalanceDue; // Initial party balance
      }

      // ✅ **Update Party Details**
      await partyRef.update({
        "name": customer_controller.text,
        "phone": phoneNumber,
        "total_amount": totalPartyAmount.toString(),
      });

      // ✅ **Append transaction under Parties/{phone}/transactions**
      await partyRef.child("transactions").update({
        widget.transactionId: {
          "customer": customer_controller.text,
          "phone": phoneNumber,
          "received": newReceivedAmount.toString(),
          "balance_due": newBalanceDue.toString(),
          "paymentType": newPaymentType,
        }
      });

      // ✅ **Prepare and update the transaction**
      Map<String, dynamic> updatedData = {
        "customer": customer_controller.text,
        "phone": phoneNumber,
        "received": newReceivedAmount.toString(),
        "balance_due": newBalanceDue.toString(),
        "description": description_controller.text,
        "invoice_no": invoice_no,
        "paymentType": newPaymentType,
        "type": type,
        "Image": image ?? "Null",
        "items": {
          for (int i = 0; i < existingItems.length; i++)
            "item_$i": {
              "discount": existingItems[i]['discount'],
              "itemName": existingItems[i]['itemName'],
              "quantity": existingItems[i]['quantity'],
              "rate": existingItems[i]['rate'],
              "subtotal": existingItems[i]['subtotal'],
              "tax": existingItems[i]['tax'],
              "unit": existingItems[i]['unit'],
            }
        }
      };

      await transactionRef.update(updatedData);

      print("Transaction updated successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction updated successfully!")));
      Navigator.pop(context);
    } catch (error) {
      print("Error updating transaction: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update transaction!")));
    }
  }
  Future<void> updatePartyTransaction(String userId, String partyId, double oldAmount, double newAmount) async {
    DatabaseReference partyRef = FirebaseDatabase.instance.ref("users/$userId/Parties/$partyId");
    DatabaseEvent partyEvent = await partyRef.once();

    if (partyEvent.snapshot.exists) {
      double partyTotalAmount = double.tryParse(partyEvent.snapshot.child("total_amount").value.toString()) ?? 0.0;
      partyTotalAmount -= oldAmount;
      partyTotalAmount += newAmount;

      await partyRef.update({"total_amount": partyTotalAmount});
    }
  }

  void deleteTransaction() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/${widget.transactionId}");

    try {
      await ref.remove();
      print("Transaction deleted successfully");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction deleted successfully!")));
      Navigator.pop(context);
    } catch (error) {
      print("Error deleting transaction: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete transaction!")));
    }
  }
  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Transaction"),
        content: Text("Are you sure you want to delete this transaction?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          TextButton(onPressed: () { Navigator.pop(context); deleteTransaction(); }, child: Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    fetchTransactionData();
    total_amount.addListener(calculateBalanceDue);
    received_money.addListener(calculateBalanceDue);
  }
  void calculateBalanceDue() {
    double totalAmount = total_amount.text.isNotEmpty ? double.tryParse(total_amount.text) ?? 0.0 : 0.0;
    double receivedMoney = received_money.text.isNotEmpty ? double.tryParse(received_money.text) ?? 0.0 : 0.0;

    double balanceDue = totalAmount - receivedMoney;
    setState(() {
      balance_due.text = balanceDue.toStringAsFixed(2); // Format to 2 decimal places
    });
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
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar:is_readyonly==true?
      BottomNavbarSaveButton(
        leftButtonText: 'Delete',
        rightButtonText: 'Edit',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.blueAccent,
        onLeftButtonPressed: (){
          showDeleteConfirmationDialog();
        },
        onRightButtonPressed: () async {
          setState(() {
            is_readyonly = false;
          });
        },
      ):BottomNavbarSaveButton(
        leftButtonText: 'Cencle',
        rightButtonText: 'Save',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.blueAccent,
        onLeftButtonPressed: (){
          setState(() {
            is_readyonly = true;
          });
        },
        onRightButtonPressed: () async {
          updateTransactionData();
          setState(() {
            is_readyonly = true;
          });
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
                            });                          },
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
                            });                          },
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
                      readOnly: is_readyonly,
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
                      readOnly: is_readyonly,
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
                        if(is_readyonly!=true) {
                          _navigateToAddItemScreen(context);
                        }
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
              if (existingItems.isNotEmpty)
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
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: existingItems.length,
                                  itemBuilder: (context, index) {
                                    // Debugging: Print the item to verify data types
                                    print("Item at index $index: ${existingItems[index]}");

                                    // Safely convert values to double
                                    double rate = (existingItems[index]["rate"] is String)
                                        ? double.tryParse(existingItems[index]["rate"]) ?? 0.0
                                        : (existingItems[index]["rate"] ?? 0.0).toDouble();

                                    double quantity = (existingItems[index]["quantity"] is String)
                                        ? double.tryParse(existingItems[index]["quantity"]) ?? 0.0
                                        : (existingItems[index]["quantity"] ?? 0.0).toDouble();

                                    double discount = (existingItems[index]["discount"] is String)
                                        ? double.tryParse(existingItems[index]["discount"]) ?? 0.0
                                        : (existingItems[index]["discount"] ?? 0.0).toDouble();

                                    double tax = (existingItems[index]["taxValue"] is String)
                                        ? double.tryParse(existingItems[index]["taxValue"]) ?? 0.0
                                        : (existingItems[index]["taxValue"] ?? 0.0).toDouble();

                                    // Calculate values
                                    double subtotal = rate * quantity;
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
                                              existingItem: existingItems[index], // Pass the item data
                                            ),
                                          ),
                                        );

                                        // If the user saves the edited item, update the list
                                        if (updatedItem != null) {
                                          setState(() {
                                            existingItems[index] = updatedItem; // Update the item in the list
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
                                                child: Text(
                                                    "#${index + 1}  ${existingItems[index]["itemName"]}",
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                              ),
                                              Text(
                                                "₹ ${finalAmount.toStringAsFixed(2)}",
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete, color: Colors.red),
                                                onPressed: () {
                                                  setState(() {
                                                    existingItems.removeAt(index); // Remove item
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
                                                "$rate ${existingItems[index]["unit"]} x $quantity = ₹ ${subtotal.toStringAsFixed(2)}",
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
                                              Text(
                                                "GST (${tax.toString()}%):",
                                                style: TextStyle(color: Colors.grey[600]),
                                              ),
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

                                // Total Calculation Section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Discount: ₹ ${calculateTotalDiscount(existingItems).toStringAsFixed(2)}"),
                                    Text("Total Tax: ₹ ${calculateTotalTax(existingItems).toStringAsFixed(2)}"),
                                  ],
                                ),
                                SizedBox(height: 5),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Qty: ${calculateTotalQuantity(existingItems)}"),
                                    Text(
                                      "Total Amount: ₹ ${calculateTotalFinalAmount(existingItems).toStringAsFixed(2)}",
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
                                readOnly: is_readyonly,
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

                    if (total_amount.text != null && total_amount.text!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                    readOnly: is_readyonly,
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
                                  onTap: () {
                                    if(is_readyonly!=true) {
                                      select_payment_method(context);
                                    }
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
                                        if(is_readyonly!=true) {
                                          showModalBottomSheet(
                                            backgroundColor: Colors.white,
                                            context: context,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .vertical(
                                                  top: Radius.circular(20)),
                                            ),
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context,
                                                    setStateModal) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .all(16.0),
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      children: [
                                                        Text(
                                                          "Select State",
                                                          style: TextStyle(
                                                              fontSize: 22),
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
                                                                  title: Text(
                                                                      state),
                                                                  onTap: () {
                                                                    setState(() {
                                                                      Country =
                                                                          state;
                                                                    });
                                                                    Navigator
                                                                        .pop(
                                                                        context);
                                                                  },
                                                                  tileColor: Country ==
                                                                      state
                                                                      ? Colors
                                                                      .grey[200]
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
                                        }
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
                                readOnly: is_readyonly,
                                controller:description_controller,
                                onChanged: (value){
                                  setState(() {
                                    description_controller.text = value;
                                  });
                                },
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
                            ),                          ],
                        ),
                      ),
                    ),
                    // Padding(
                    //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //     child: Container(
                    //       height: 70,
                    //       decoration: BoxDecoration(
                    //         border: Border.all(width: 1,color: Colors.grey),
                    //         borderRadius: BorderRadius.circular(5),
                    //       ),
                    //       child: Center(
                    //         child: Text("Attach document",style: TextStyle(fontSize: 11),),
                    //       ),
                    //     )
                    // ),
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