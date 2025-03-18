import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';


class Payment_in_Detail extends StatefulWidget{
  String transactionId;
  Payment_in_Detail({required this.transactionId});
  @override
  State<StatefulWidget> createState() => _Payment_in_Detail(transactionId: this.transactionId);
}


class _Payment_in_Detail extends State<Payment_in_Detail> {

  String transactionId;
  _Payment_in_Detail({required this.transactionId});


  Map<String, dynamic>? transactionData; // Store fetched transaction
  bool isLoading = true; // Loading state

  var time = DateTime.now();
  int invoice_no = 0;

  TextEditingController customer_controller = TextEditingController();
  TextEditingController phonenumber_controller = TextEditingController();


  TextEditingController received_money = TextEditingController();
  String? selectedPaymentType = "Cash";
  String? Country = "Gujrat";

  //description
  TextEditingController description_controller = TextEditingController();

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

  void fetchTransactionDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("users/$userId/Transactions/${transactionId}");

    // Fetch data once
    DatabaseEvent event = await ref.once();

    if (event.snapshot.value != null) {
      setState(() {
        transactionData = Map<String, dynamic>.from(event.snapshot.value as Map);
        isLoading = false;

        // Assign values to controllers
        customer_controller.text = transactionData?["customer"] ?? "Null";
        phonenumber_controller.text = transactionData?["phone"] ?? "N/A";
        description_controller.text = transactionData?["description"] ?? "No Description";
        received_money.text = transactionData?["received"] ?? "0";
        selectedPaymentType = transactionData?["paymentType"] ?? "";
        invoice_no = transactionData?["invoice_no"] ?? 0;
        image = transactionData?["Image"] ?? null;
      });
    } else {
      print("Transaction not found");
      setState(() {
        isLoading = false;
      });
    }
  }
  void updateTransaction() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference transactionRef =
    FirebaseDatabase.instance.ref("users/$userId/Transactions/${widget.transactionId}");
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

    try {
      DatabaseEvent event = await transactionRef.once();
      if (event.snapshot.value == null) {
        print("Transaction not found!");
        return;
      }

      Map<dynamic, dynamic> oldTransaction = event.snapshot.value as Map<dynamic, dynamic>;

      // 🟢 Get old transaction details
      double oldAmount = double.tryParse(oldTransaction["total_amount"].toString()) ?? 0.0;
      String oldBankName = oldTransaction["paymentType"] ?? "";
      String transactionId = widget.transactionId;
      String oldPhoneNumber = oldTransaction["phone"] ?? "";

      // 🟢 Get the new transaction details
      double newAmount = double.tryParse(received_money.text) ?? 0.0;
      String newBankName = selectedPaymentType ?? oldBankName;
      String newPhoneNumber = phonenumber_controller.text;
      String newCustomerName = customer_controller.text;

      // 🟢 Check for changes
      bool amountChanged = oldAmount != newAmount;
      bool paymentTypeChanged = oldBankName != newBankName;
      bool phoneChanged = oldPhoneNumber != newPhoneNumber;

      // 🟢 Update Transaction Data
      Map<String, dynamic> updatedData = {
        "transactionId": transactionId,
        "type": "payment-in",
        "invoice_no": invoice_no ?? "0",
        "date": "${time.day}/${time.month}/${time.year}",
        "customer": newCustomerName,
        "phone": newPhoneNumber,
        "total_amount": received_money.text,
        "received": received_money.text,
        "paymentType": newBankName,
        "description": description_controller.text,
        "Image": image ?? "Null",
      };

      await transactionRef.update(updatedData);
      print("✅ Transaction updated successfully!");

      // 🟢 Update Party Details
      if (amountChanged || phoneChanged) {
        await updatePartyTransaction(userId, transactionId, oldPhoneNumber, oldAmount, newPhoneNumber, newCustomerName, newAmount);
      }

      // 🟢 Update Bank Transaction if needed
      if (amountChanged || paymentTypeChanged) {
        await updateBankTransaction(userId, transactionId, oldBankName, oldAmount, newBankName);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction updated successfully!")),
      );

      setState(() {
        transactionData = updatedData;
      });

    } catch (error) {
      print("❌ Error updating transaction: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update transaction!")),
      );
    }
  }
  void deleteTransaction() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("users/$userId/Transactions/${widget.transactionId}");

    try {
      await ref.remove(); // Delete the transaction from Firebase
      print("Transaction deleted successfully");

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction deleted successfully!")),
      );

      // Navigate back to the previous screen
      Navigator.pop(context);
    } catch (error) {
      print("Error deleting transaction: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete transaction!")),
      );
    }
  }
  void showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: Text("Delete Transaction"),
        content: Text("Are you sure you want to delete this transaction? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text("Cancel",style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              deleteTransaction(); // Call delete function
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  Future<void> updateBankTransaction(
      String userId,
      String transactionId,
      String oldPaymentType,
      double oldAmount,
      String newPaymentType) async
  {

    DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$userId");

    // 🔹 Get the new amount directly from the text controller
    double newAmount = double.tryParse(received_money.text) ?? 0.0;
    double amountDifference = newAmount - oldAmount;

    // 🔹 Define references for old and new transactions
    DatabaseReference oldRef = (oldPaymentType == "Cash")
        ? userRef.child("Bank_accounts/Cash/Cash_transaction")
        : userRef.child("Bank_accounts/Bank/$oldPaymentType/Bank_transaction");

    DatabaseReference newRef = (newPaymentType == "Cash")
        ? userRef.child("Bank_accounts/Cash/Cash_transaction")
        : userRef.child("Bank_accounts/Bank/$newPaymentType/Bank_transaction");

    // 🔹 Delete the old transaction
    await oldRef.child(transactionId).remove();
    print("✅ Old transaction removed successfully.");

    // 🔹 Adjust old balance (subtract old amount)
    DatabaseReference oldBalanceRef = (oldPaymentType == "Cash")
        ? userRef.child("Bank_accounts/Cash/total_balance")
        : userRef.child("Bank_accounts/Bank/$oldPaymentType/total_balance");

    DatabaseEvent oldBalanceEvent = await oldBalanceRef.once();
    if (oldBalanceEvent.snapshot.value != null) {
      double oldBalance = double.parse(oldBalanceEvent.snapshot.value.toString());
      await oldBalanceRef.set(oldBalance - oldAmount);
      print("🔻 Old balance updated: ${oldBalance - oldAmount}");
    }

    // 🔹 Get current timestamp
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    // 🔹 Prepare new transaction data
    Map<String, dynamic> newTransactionData = {
      "transactionId": transactionId,
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "amount": newAmount.toString(),
      "current_time": currentTime,
      "transaction": {
        "image": image ?? "Null",
        "current_time": currentTime,
        "customer": customer_controller.text,
        "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
        "description": description_controller.text,
        "invoice_no": invoice_no ?? "0",
        "paymentType": newPaymentType,
        "phone": phonenumber_controller.text,
        "received": received_money.text,
        "total_amount": received_money.text,
        "type": "payment-in",
      },
    };

    // 🔹 Add the new transaction
    await newRef.child(transactionId).set(newTransactionData);
    print("✅ New transaction added successfully.");

    // 🔹 Adjust new balance (add new amount)
    DatabaseReference newBalanceRef = (newPaymentType == "Cash")
        ? userRef.child("Bank_accounts/Cash/total_balance")
        : userRef.child("Bank_accounts/Bank/$newPaymentType/total_balance");

    DatabaseEvent newBalanceEvent = await newBalanceRef.once();
    double newBalance = (newBalanceEvent.snapshot.value != null)
        ? double.parse(newBalanceEvent.snapshot.value.toString())
        : 0.0;

    await newBalanceRef.set(newBalance + newAmount);
    print("🔺 New balance updated: ${newBalance + newAmount}");
  }
  Future<void> updatePartyTransaction(
      String userId,
      String transactionId,
      String oldPhoneNumber,
      double oldAmount,
      String newPhoneNumber,
      String newCustomerName,
      double newAmount
      ) async
  {
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

    // 🟢 Adjust old party's total_amount
    if (oldPhoneNumber.isNotEmpty) {
      DatabaseReference oldPartyRef = partiesRef.child(oldPhoneNumber);
      DatabaseEvent oldPartyEvent = await oldPartyRef.once();

      if (oldPartyEvent.snapshot.value != null) {
        Map<dynamic, dynamic> oldPartyData = oldPartyEvent.snapshot.value as Map<dynamic, dynamic>;
        double existingAmount = double.tryParse(oldPartyData["total_amount"].toString()) ?? 0.0;
        double newTotal = existingAmount - oldAmount;
        await oldPartyRef.update({"total_amount": newTotal.toString()});
      }

      // 🔴 Remove the transaction from the old party
      await oldPartyRef.child("transactions").child(transactionId).remove();
    }

    // 🟢 Update new party's total_amount
    DatabaseReference newPartyRef = partiesRef.child(newPhoneNumber);
    DatabaseEvent newPartyEvent = await newPartyRef.once();

    double newTotalAmount = newAmount;
    if (newPartyEvent.snapshot.value != null) {
      Map<dynamic, dynamic> newPartyData = newPartyEvent.snapshot.value as Map<dynamic, dynamic>;
      double existingAmount = double.tryParse(newPartyData["total_amount"].toString()) ?? 0.0;
      newTotalAmount += existingAmount;
    }

    // 🟢 Save the new party details
    Map<String, dynamic> partyData = {
      "name": newCustomerName,
      "phone": newPhoneNumber,
      "total_amount": newTotalAmount.toString(),
    };

    await newPartyRef.set(partyData);

    // 🟢 Add updated transaction inside `Parties/transactions`
    Map<String, dynamic> transactionData = {
      "transactionId": transactionId,
      "date": DateFormat('dd/MM/yyyy').format(DateTime.now()),
      "amount": newAmount.toString(),
      "customer": newCustomerName,
      "phone": newPhoneNumber,
      "description": description_controller.text,
      "invoice_no": invoice_no ?? "0",
      "paymentType": selectedPaymentType,
      "received": received_money.text,
      "total_amount": received_money.text,
      "type": "payment-in",
    };

    await newPartyRef.child("transactions").child(transactionId).set(transactionData);
    print("✅ Party transaction updated successfully!");
  }



  bool is_readyonly = true;
  @override
  void initState() {
    super.initState();
    fetchTransactionDetails();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('Payment - In'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(0.5),
            )),
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
          updateTransaction();
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
                                  if(is_readyonly==false){
                                    showInvoiceSheet(context, (newInvoice) {
                                      setState(() {
                                        invoice_no = newInvoice;
                                      });
                                    });
                                  }
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
                                  if(is_readyonly==false){
                                    showInvoiceSheet(context, (newInvoice) {
                                      setState(() {
                                        invoice_no = newInvoice;
                                      });
                                    });
                                  }
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
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          TextField(
                            readOnly: is_readyonly,
                            controller: customer_controller,
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
                                phonenumber_controller.text = value;
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
                        ],
                      ),
                    ),


                    Container(
                      color: Colors.white12,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Recieved",
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
                                        controller: received_money,
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
                          if (received_money != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Total Amount",
                                      style: TextStyle(fontSize: 16, color: Colors.green),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15, // Fixed width for rupee symbol
                                    child: Icon(Icons.currency_rupee,
                                        size: 15, color: Colors.green),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child:TextField(
                                        controller: received_money,
                                        style: TextStyle(color: Colors.green),
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

                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    //container for some whiere space
                    Container(height: 20,color: Colors.white,),
                    SizedBox(height: 10,),

                    //payment type
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
                                          if(is_readyonly==false){
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
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    //description and attach image
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      color: Colors.white,
                      child: SizedBox(
                        height:75,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: is_readyonly,
                                controller:description_controller,
                                onChanged: (String value){
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
                                if(is_readyonly==false){
                                  uploadImage();
                                }
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
