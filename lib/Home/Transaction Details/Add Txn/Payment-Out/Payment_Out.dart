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

class Payment_Out extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PaymentOut();
}

class PaymentOut extends State<Payment_Out> {

  var time = DateTime.now();
  var invoice_no = 0;
  String? selectedPaymentType = "Cash";
  String? Country = "Gujrat";
  bool isChecked = false;

  String? selectedState;
  //controlllers
  TextEditingController party_name_controller = TextEditingController();
  TextEditingController phonenumber_controller = TextEditingController();
  TextEditingController paid_money = TextEditingController();
  TextEditingController balance_due = TextEditingController();
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


  Future<void> savePaymentOutData(String userId) async {
    DatabaseReference paymentOutRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/");
    DatabaseReference bankAccountRef;
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

    // Generate a unique transaction ID
    String transactionId = paymentOutRef.push().key!;

    if (selectedPaymentType == "Cash") {
      bankAccountRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash/Cash_transaction");
    } else {
      bankAccountRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank/$selectedPaymentType/Bank_transaction");
    }

    if (invoice_no != null &&
        party_name_controller.text.isNotEmpty &&
        phonenumber_controller.text.isNotEmpty &&
        paid_money.text.isNotEmpty &&
        selectedPaymentType != null &&
        description_controller.text.isNotEmpty) {

      // Reference to total balance (Cash or Bank)
      DatabaseReference totalBalanceRef;
      if (selectedPaymentType == "Cash") {
        totalBalanceRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash/total_balance");
      } else {
        totalBalanceRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank/$selectedPaymentType/total_balance");
      }

      // Fetch the current total balance
      DatabaseEvent event = await totalBalanceRef.once();
      double totalBalance = 0;
      if (event.snapshot.value != null) {
        totalBalance = double.tryParse(event.snapshot.value.toString()) ?? 0.0;
      }

      double paidAmount = double.tryParse(paid_money.text) ?? 0.0;
      double newTotalBalance = totalBalance - paidAmount; // ✅ Deduct the amount

      int currentTime = DateTime.now().millisecondsSinceEpoch;

      // ✅ Prepare Payment-Out Data
      Map<String, dynamic> paymentData = {
        "transactionId": transactionId,
        "type": "payment-out",
        "invoice_no": invoice_no,
        "date": "${time.day}/${time.month}/${time.year}",
        "party_name": party_name_controller.text,
        "phone": phonenumber_controller.text,
        "paid_amount": paid_money.text,
        "balance_due": balance_due.text,
        "paymentType": selectedPaymentType,
        "description": description_controller.text,
        "Image": image ?? "Null",
        "current_time": currentTime,
      };

      // ✅ Save Payment-Out Transaction
      await paymentOutRef.child(transactionId).set(paymentData);

      // ✅ Save Bank or Cash Transaction
      Map<String, dynamic> bankTransactionData = {
        "transactionId": transactionId,
        "date": "${time.day}/${time.month}/${time.year}",
        "amount": paid_money.text,
        "current_time": currentTime,
        "transaction": paymentData,
      };

      await bankAccountRef.child(transactionId).set(bankTransactionData);
      await totalBalanceRef.set(newTotalBalance); // ✅ Update the total balance after deduction

      // ✅ Update Party Transaction (Deduct the amount)
      String partyName = party_name_controller.text;
      String phoneNumber = phonenumber_controller.text;

      DatabaseReference partyRef = partiesRef.child(phoneNumber);
      DatabaseEvent partyEvent = await partyRef.once();

      double totalAmount = -paidAmount; // ✅ Deduct the paid amount

      if (partyEvent.snapshot.exists) {
        Map<dynamic, dynamic> partyData = partyEvent.snapshot.value as Map<dynamic, dynamic>;
        double existingAmount = double.tryParse(partyData["total_amount"].toString()) ?? 0.0;
        totalAmount += existingAmount;
      }

      Map<String, dynamic> partyData = {
        "name": partyName,
        "phone": phoneNumber,
        "total_amount": totalAmount.toString(), // ✅ Deducted amount
      };

      await partyRef.update(partyData); // ✅ Update party balance

      // ✅ Append New Transaction Instead of Overwriting
      await partyRef.child("transactions/$transactionId").set(paymentData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment-Out Data Saved Successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter required details!")),
      );
    }
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
        title: Text('Payment-Out'),
        bottom: Prefered_underline_appbar(),
      ),
      bottomNavigationBar:BottomNavbarSaveButton(
        leftButtonText: 'cencle',
        rightButtonText: 'save',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.blueAccent,
        onLeftButtonPressed: (){
          Navigator.pop(context);
        },
        onRightButtonPressed: () async {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await savePaymentOutData(user.uid);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User not logged in!')),
            );
          }
        },
      ),
      // Prevent layout shifting when the keyboard opens
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
                                    });                                       },
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
                              controller:party_name_controller,
                              onChanged: (value){
                                setState(() {
                                  party_name_controller.text = value;
                                });
                              },
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
                              controller: phonenumber_controller,
                              onChanged: (value){
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
                                      "Paid",
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
                                          controller: paid_money,
                                          onChanged: (value) {
                                            setState(() {
                                              paid_money.text = value;
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

                            if (paid_money.text!= null && paid_money.text.isNotEmpty)
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
                                          controller: paid_money,
                                          style: TextStyle(color: Colors.green),
                                          onChanged: (value) {
                                            setState(() {
                                              paid_money.text = value;
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