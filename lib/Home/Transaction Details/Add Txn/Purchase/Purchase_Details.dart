import 'dart:convert';
import 'dart:io';

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

class Purchase_Details extends StatefulWidget {
  String transactionId;
  Purchase_Details({required this.transactionId});
  @override
  State<StatefulWidget> createState() => _Purchase_Details(transactionId: this.transactionId);
}

class _Purchase_Details extends State<Purchase_Details> {

  String transactionId;
  _Purchase_Details({required this.transactionId});

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
  void fetchPurchaseData() async {
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
          customer_controller.text = data['party_name'] ?? "";
          phonenumber_controller.text = data['phone'] ?? "";
          total_amount.text = data["total_amount"] ?? "";
          paid_money.text = data['paid_amount'] ?? "";
          balance_due.text = data['balance_due'] ?? "";
          description_controller.text = data['description'] ?? "";
          invoice_no = int.tryParse(data['invoice_no'].toString()) ?? 0;
          selectedPaymentType = data['paymentType'] ?? "Cash";
          image = data['Image'];
          Country = "Gujrat";

          existingItems = (data['items'] as Map).entries.map((e) {
            return {
              'discount': e.value['discount'],
              'itemName': e.value['itemName'],
              'quantity': e.value['quantity'],
              'rate': e.value['rate'],
              'subtotal': e.value['subtotal'],
              'tax': e.value['tax'],
              'unit': e.value['unit'],
            };
          }).toList();
        });

        print("Purchase data fetched successfully!");
      } else {
        print("No purchase transaction found!");
      }
    } catch (error) {
      print("Error fetching purchase data: $error");
    }
  }
  void updatePurchaseData() async {
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
      // Fetch old transaction data
      DatabaseEvent event = await transactionRef.once();
      DataSnapshot snapshot = event.snapshot;
      if (!snapshot.exists) {
        print("Transaction not found");
        return;
      }

      Map<String, dynamic> oldData = Map<String, dynamic>.from(snapshot.value as Map);
      String oldPaymentType = oldData['paymentType'] ?? "Cash";
      double oldPaidAmount = double.tryParse(oldData['paid_amount']?.toString() ?? "0.0") ?? 0.0;
      double oldBalanceDue = double.tryParse(oldData['balance_due']?.toString() ?? "0.0") ?? 0.0;

      // Fetch new transaction values
      double newPaidAmount = double.tryParse(paid_money.text) ?? 0.0;
      double newBalanceDue = double.tryParse(balance_due.text) ?? 0.0;
      String? newPaymentType = selectedPaymentType;
      String phoneNumber = phonenumber_controller.text;

      // Fetch bank balances
      double cashBalance = 0.0, bankBalance = 0.0;

      DatabaseEvent bankEvent = await bankRef.once();
      if (bankEvent.snapshot.exists) {
        Map<String, dynamic> bankData = Map<String, dynamic>.from(bankEvent.snapshot.value as Map);
        cashBalance = double.tryParse(bankData['Cash']?['total_balance']?.toString() ?? "0.0") ?? 0.0;

        if (newPaymentType != "Cash") {
          bankBalance = double.tryParse(bankData['Bank']?[newPaymentType]?['total_balance']?.toString() ?? "0.0") ?? 0.0;
        }
      }

      // ✅ **Reverse Old Payment Effect**
      if (oldPaymentType == "Cash") {
        cashBalance += oldPaidAmount;
        await bankRef.child("Cash/Cash_transaction/${widget.transactionId}").remove();
      } else {
        await bankRef.child("Bank/$oldPaymentType/bank_transaction/${widget.transactionId}").remove();
        bankBalance += oldPaidAmount;
      }

      // ✅ **Add New Payment Effect**
      if (newPaymentType == "Cash") {
        cashBalance -= newPaidAmount;
        await bankRef.child("Cash/Cash_transaction/${widget.transactionId}").set({
          "amount": newPaidAmount,
          "type": "Purchase",
          "date": DateTime.now().toIso8601String()
        });
      } else {
        // ✅ Deduct from the new bank account balance
        bankBalance -= newPaidAmount;
        await bankRef.child("Bank/$newPaymentType/bank_transaction/${widget.transactionId}").set({
          "amount": newPaidAmount,
          "type": "Purchase",
          "date": DateTime.now().toIso8601String()
        });
      }

      // ✅ **Update Bank Balances**
      await bankRef.child("Cash").update({"total_balance": cashBalance});
      if (newPaymentType != "Cash") {
        await bankRef.child("Bank/$newPaymentType").update({"total_balance": bankBalance});
      }

      // ✅ **Update Party Transaction**
      await updatePartyTransaction(userId, phoneNumber, oldBalanceDue, newBalanceDue, newPaidAmount);

      // ✅ **Update Purchase Transaction**
      await transactionRef.update({
        "party_name": customer_controller.text,
        "phone": phoneNumber,
        "total_amount": total_amount.text,
        "paid_amount": newPaidAmount.toString(),
        "balance_due": newBalanceDue.toString(),
        "description": description_controller.text,
        "invoice_no": invoice_no,
        "paymentType": newPaymentType,
        "Image": image ?? "Null",
        "items": existingItems
      });

      print("Purchase transaction updated successfully");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Transaction updated successfully!")));
      Navigator.pop(context);
    } catch (error) {
      print("Error updating transaction: $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update transaction!")));
    }
  }

  Future<void> updatePartyTransaction(
      String userId,
      String partyId,
      double oldBalanceDue,
      double newBalanceDue,
      double newPaidAmount) async
  {

    DatabaseReference partyRef = FirebaseDatabase.instance.ref("users/$userId/Parties/$partyId");
    DatabaseEvent partyEvent = await partyRef.once();

    double totalPartyAmount = 0.0;

    if (partyEvent.snapshot.exists) {
      Map<dynamic, dynamic> partyData = partyEvent.snapshot.value as Map<dynamic, dynamic>;
      double existingPartyAmount = double.tryParse(partyData["total_amount"].toString()) ?? 0.0;

      // ✅ Reverse the effect of the previous transaction
      totalPartyAmount = existingPartyAmount - oldBalanceDue;

      // ✅ Apply the new balance_due
      totalPartyAmount += newBalanceDue;
    } else {
      // ✅ If it's a new party, set the balance_due directly
      totalPartyAmount = newBalanceDue;
    }

    // ✅ Update Party Details
    await partyRef.update({
      "total_amount": totalPartyAmount.toString(),
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        title: Text("Delete Transaction"),
        content: Text("Are you sure you want to delete this transaction? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteTransaction();
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    fetchPurchaseData();
    total_amount.addListener(calculateBalanceDue);
    paid_money.addListener(calculateBalanceDue);
  }
  void calculateBalanceDue() {
    double totalAmount = total_amount.text.isNotEmpty ? double.tryParse(total_amount.text) ?? 0.0 : 0.0;
    double receivedMoney = paid_money.text.isNotEmpty ? double.tryParse(paid_money.text) ?? 0.0 : 0.0;

    double balanceDue = totalAmount - receivedMoney;
    setState(() {
      balance_due.text = balanceDue.toStringAsFixed(2); // Format to 2 decimal places
    });
  }
  @override
  void dispose() {
    // Clean up controllers to avoid memory leaks
    total_amount.dispose();
    paid_money.dispose();
    balance_due.dispose();
    super.dispose();
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
      bottomNavigationBar: is_readyonly==true?
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
          updatePurchaseData();
          setState(() {
            is_readyonly = true;
          });
        },
      ),
      body: Container(
        color:  Color(0xFFE8E8E8),
        child: Column(
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

                  ///Textfields
                  Container(
                    color: Colors.white,
                    padding: EdgeInsets.all(16),
                    child:Column(
                      children: [
                        TextField(
                          readOnly:is_readyonly,
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
                          readOnly:is_readyonly,
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
                        SizedBox(height: 16),
                      ],
                    ),
                  ),

                  ///Billed Items
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
                                        double rate = double.tryParse(existingItems[index]["rate"].toString()) ?? 0.0;
                                        double quantity = double.tryParse(existingItems[index]["quantity"].toString()) ?? 0.0;
                                        double discount = double.tryParse(existingItems[index]["discount"].toString()) ?? 0.0;
                                        double tax = double.tryParse(existingItems[index]["taxValue"].toString()) ?? 0.0;

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
                                                  existingItem: {
                                                    'discount': existingItems[index]['discount'].toString(),
                                                    'itemName': existingItems[index]['itemName'].toString(),
                                                    'quantity': existingItems[index]['quantity'].toString(),
                                                    'rate': existingItems[index]['rate'].toString(),
                                                    'subtotal': subtotal.toString(),
                                                    'tax': existingItems[index]['tax'].toString(),
                                                    'taxValue': existingItems[index]['taxValue'].toString(),
                                                    'unit': existingItems[index]['unit'].toString(),
                                                  },
                                                ),
                                              ),
                                            );

                                            if (updatedItem != null) {
                                              setState(() {
                                                existingItems[index] = {
                                                  'discount': double.tryParse(updatedItem['discount'].toString()) ?? 0.0,
                                                  'itemName': updatedItem['itemName'] ?? "",
                                                  'quantity': double.tryParse(updatedItem['quantity'].toString()) ?? 0.0,
                                                  'rate': double.tryParse(updatedItem['rate'].toString()) ?? 0.0,
                                                  'subtotal': double.tryParse(updatedItem['subtotal'].toString()) ?? 0.0,
                                                  'tax': double.tryParse(updatedItem['tax'].toString()) ?? 0.0,
                                                  'taxValue': double.tryParse(updatedItem['taxValue'].toString()) ?? 0.0,
                                                  'unit': updatedItem['unit'] ?? "",
                                                };
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
                                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                    ),
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


                  ///total amount
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
                                    readOnly:is_readyonly,
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
                                        readOnly:is_readyonly,
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

                  ///payment type
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0,right: 16,bottom: 30,top: 16),
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

        ],
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