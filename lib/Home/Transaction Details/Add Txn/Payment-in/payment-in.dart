import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';


class Payment_in extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => PaymentIn();
}


class PaymentIn extends State<Payment_in> {
  var time = DateTime.now();
  int invoice_no = 0;

  TextEditingController customer_controller = TextEditingController();
  // String? customer_name;

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

  Future<void> savePaymentInData(String userId) async {
    DatabaseReference paymentInRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/");
    DatabaseReference bankAccountRef;
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref("users/$userId/Parties");

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

      double receivedAmount = double.parse(received_money.text);
      double newTotalBalance = totalBalance + receivedAmount;

      int currentTime = DateTime.now().millisecondsSinceEpoch;

      Map<String, dynamic> paymentData = {
        "transactionId": transactionId,
        "type": "payment-in",
        "invoice_no": invoice_no,
        "date": "${time.day}/${time.month}/${time.year}",
        "customer": customer_controller.text,
        "phone": phonenumber_controller.text,
        "total_amount": received_money.text,
        "received": received_money.text,
        "paymentType": selectedPaymentType,
        "description": description_controller.text,
        "Image": image ?? null,
        "current_time": currentTime,
      };

      await paymentInRef.child(transactionId).set(paymentData);

      Map<String, dynamic> bankTransactionData = {
        "transactionId": transactionId,
        "date": "${time.day}/${time.month}/${time.year}",
        "amount": received_money.text,
        "current_time": currentTime,
        "transaction": paymentData,
      };

      await bankAccountRef.child(transactionId).set(bankTransactionData);
      await totalBalanceRef.set(newTotalBalance);

      // Check if the party already exists
      String customerName = customer_controller.text;
      String phoneNumber = phonenumber_controller.text;

      DatabaseReference partyQuery = partiesRef.child(phoneNumber);
      DatabaseEvent partyEvent = await partyQuery.once();

      double totalAmount = receivedAmount;

      if (partyEvent.snapshot.value != null) {
        Map<dynamic, dynamic> partyData = partyEvent.snapshot.value as Map<dynamic, dynamic>;
        double existingAmount = double.parse(partyData["total_amount"].toString());
        totalAmount += existingAmount;
      }

      Map<String, dynamic> partyData = {
        "name": customerName,
        "phone": phoneNumber,
        "total_amount": totalAmount.toString(),
      };

      await partiesRef.child(phoneNumber).update(partyData); // ✅ This updates party details without overwriting transactions

      // ✅ Use update instead of set to append the new transaction instead of replacing existing ones
      await partiesRef.child(phoneNumber).child("transactions").update({
        transactionId: paymentData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment-In Data Saved Successfully!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter required details!")),
      );
    }
  }

  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> fetchParties(String query) async {
    List<Map<String, dynamic>> partyList = [];
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
    }
    else {
      String userId = user.uid;
      final snapshot = await _databaseRef.child("users").child(userId).child(
          "Parties").get();

      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Map<String, dynamic> parties = Map<String, dynamic>.from(
            snapshot.value as Map);

        parties.forEach((key, value) {
          if (value is Map) {
            final partyData = Map<String, dynamic>.from(value);

            final String name = partyData["name"] ?? "";
            final String phone = partyData["phone"] ?? "";

            if (name.toLowerCase().contains(query.toLowerCase()) ||
                phone.contains(query)) {
              partyList.add({
                "name": name,
                "phone": phone,
              });
            }
          }
        });
      }
    }

    return partyList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light, // Light icons (for dark backgrounds)
        ),
        backgroundColor: Colors.white,
        title: Text('Payment - In'),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              height: 1,
              color: Colors.grey.withOpacity(0.5),
            )),
      ),
      bottomNavigationBar:
      BottomNavbarSaveButton(
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
                            SizedBox(height: 16),
                            TypeAheadField<Map<String, dynamic>>(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: customer_controller,
                                decoration: InputDecoration(
                                  labelText: "Customer",
                                  hintText: "Enter customer name",
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
                              suggestionsCallback: (pattern) async {
                                List<Map<String, dynamic>> results = await fetchParties(pattern);
                                return results.isNotEmpty ? results : []; // Returns an empty list if no matches
                              },
                              itemBuilder: (context, Map<String, dynamic> suggestion) {
                                return Material(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      suggestion["name"],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    trailing: Text(
                                      suggestion["phone"],
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                );
                              },
                              onSuggestionSelected: (Map<String, dynamic> suggestion) {
                                customer_controller.text = suggestion["name"];
                                phonenumber_controller.text = suggestion["phone"];
                              },
                              noItemsFoundBuilder: (context) => SizedBox.shrink(), // Hides "No items found"
                            ),

                            SizedBox(height: 16),
                            TextField(
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
                            if (received_money != null && received_money.text.isNotEmpty)
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


