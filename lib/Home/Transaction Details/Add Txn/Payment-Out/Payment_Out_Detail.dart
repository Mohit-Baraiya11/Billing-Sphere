import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:remixicon/remixicon.dart';

import '../../../BottomNavbar_save_buttons.dart';


class Payment_Out_Detail extends StatefulWidget{
  String transactionId;
  Payment_Out_Detail({required this.transactionId});
  @override
  State<StatefulWidget> createState() => _Payment_Out_Detail(transactionId: this.transactionId);
}


class _Payment_Out_Detail extends State<Payment_Out_Detail> {

  String transactionId;
  _Payment_Out_Detail({required this.transactionId});


  Map<String, dynamic>? transactionData; // Store fetched transaction
  bool isLoading = true; // Loading state

  var time = DateTime.now();
  var invoice_no;

  TextEditingController partyname_controller = TextEditingController();
  TextEditingController phonenumber_controller = TextEditingController();
  TextEditingController paid_amount = TextEditingController();
  TextEditingController balance_due = TextEditingController();

  String? selectedPaymentType = "Cash";
  String? Country = "Gujrat";

  //description
  TextEditingController description_controller = TextEditingController();

  String? image;

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
        partyname_controller.text = transactionData?["party_name"] ?? "Null";
        phonenumber_controller.text = transactionData?["phone"] ?? "N/A";
        description_controller.text = transactionData?["description"] ?? "No Description";
        paid_amount.text = transactionData?["paid_amount"] ?? "0";
        balance_due.text = transactionData?["paid_amount"]??"";
        selectedPaymentType = transactionData?["paymentType"] ?? "Cash";
        invoice_no = transactionData?["invoice_no"]?.toString() ?? "0";
        image = transactionData?["Image"] ?? "Null";
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
    DatabaseReference ref = FirebaseDatabase.instance
        .ref("users/$userId/Transactions/${widget.transactionId}");

    // Create a new updated map with all fields
    Map<String, dynamic> updatedData = {
      "invoice_no": invoice_no ?? "0",
      "date": "${time.day}/${time.month}/${time.year}",
      "party_name": partyname_controller.text,
      "phone": phonenumber_controller.text,
      "paid_amount": paid_amount.text, // Corrected
      "balance_due": balance_due.text, // Corrected
      "paymentType": selectedPaymentType,
      "description": description_controller.text,
      "Image": image ?? "Null",
    };

    try {
      await ref.update(updatedData); // Update entire transaction node
      print("Transaction updated successfully");

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction updated successfully!")),
      );

      // Update local state to reflect changes immediately
      setState(() {
        transactionData = updatedData;
      });

    } catch (error) {
      print("Error updating transaction: $error");
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
        backgroundColor: Colors.white,
        title: Text('Payment - Out'),
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
                      child: Column(
                        children: [
                          SizedBox(height: 16),
                          TextField(
                            readOnly: is_readyonly,
                            controller: partyname_controller,
                            onChanged: (String value){
                              setState(() {
                                partyname_controller.text = value;
                              });
                            },
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
                                        readOnly: is_readyonly,
                                        controller: paid_amount,
                                        onChanged: (value){
                                          setState(() {
                                            paid_amount.text = value;
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
                          if (paid_amount.text != null && paid_amount.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
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
                                    child: Icon(Icons.currency_rupee,
                                        size: 15, color: Colors.green),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child:TextField(
                                        readOnly: true,
                                        controller: balance_due,
                                        style: TextStyle(color: Colors.green),
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
                                          if(is_readyonly==false)
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
                                if(is_readyonly==false)
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

