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

class Expenses extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Expenses();
}

class _Expenses extends State<Expenses> {
  var time = DateTime.now();
  var invoice_no = 0;
  String? enteredText;
  String? selectedPaymentType = "Cash";
  String? Country = "Gujrat";
  bool isChecked = false;

  String? selectedState;

  final List<String> _expenseCategories = [
    'Rent',
    'Petrol',
    'Salary',
    'Tea',
    'Transport',
    'Maggie',
    'dhan',
  ];


  List<Map<String, dynamic>> tableRows = [
    {'itemName': '', 'qty': '', 'rate': '', 'amount': '0.00'},
  ];

  // Method to add a new row
  void _addNewRow() {
    setState(() {
      tableRows.add({'itemName': '', 'qty': '', 'rate': '', 'amount': '0.00'});
    });
  }

  // Method to calculate the total amount
  double _calculateTotal() {
    double total = 0.0;
    for (var row in tableRows) {
      double amount = double.tryParse(row['amount'].toString()) ?? 0.0;
      total += amount;
    }

    // Update total_price TextField
    setState(() {
      total_price.text = total.toStringAsFixed(2); // Format to 2 decimal places
    });

    return total;
  }

  String? selected_Expense_Value = "Indirect Expense";

  void _showAddCategoryDialog() {
    String newCategory = '';
    TextEditingController dropdownController = TextEditingController(
      text: selected_Expense_Value, // Display the selected value in the TextField
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: Text('Add Expense Category'),
          content: Container(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First TextField for entering a new category
                  TextField(
                    onChanged: (value) {
                      newCategory = value; // Capture input value
                    },
                    decoration: InputDecoration(
                      labelText: "Expense Category",
                      hintText: "Expense Category",
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
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0,bottom: 3.0,left: 10),
                      child: DropdownButton<String>(
                        value:selected_Expense_Value,
                        icon: Icon(Icons.arrow_drop_down),
                        items: [
                          DropdownMenuItem(child: Text("Indirect Expense"),value: "Indirect Expense",),
                          DropdownMenuItem(child: Text("Direct Expense"),value: "Direct Expense",),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            print("${selected_Expense_Value}");
                            selected_Expense_Value = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _expenseCategories.add(newCategory);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  TextEditingController total_price = TextEditingController();
  TextEditingController description_controller = TextEditingController();
  TextEditingController expense_category_controller = TextEditingController();

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


  Future<void> saveExpenseData(String userId) async {
    DatabaseReference userRef = FirebaseDatabase.instance.ref("users/$userId");
    DatabaseReference transactionsRef = userRef.child("Transactions");
    DatabaseReference cashRef = userRef.child("Bank_accounts/Cash");
    DatabaseReference cashTransactionRef = cashRef.child("Cash_transaction");
    DatabaseReference bankAccountsRef = userRef.child("Bank_accounts/Bank");

    // Generate a unique transaction ID
    String transactionId = transactionsRef.push().key!;

    // Convert total amount to double
    double totalAmount = double.tryParse(total_price.text) ?? 0.0;

    // Prepare expense data
    Map<String, dynamic> expenseData = {
      "transactionId": transactionId,
      "type": "expenses",
      "invoice_no": invoice_no ?? "0",
      "date": "${time.day}/${time.month}/${time.year}",
      "expenses_category": expense_category_controller.text.trim(),
      "amount": totalAmount.toString(),
      "paymentType": selectedPaymentType,
      "description": description_controller.text.trim(),
      "Image": image ?? "Null",
    };

    // Filter out empty items and create item list
    List<Map<String, dynamic>> itemsList = tableRows
        .where((row) => row['itemName'].toString().trim().isNotEmpty)
        .map((row) => {
      "itemName": row['itemName'],
      "qty": row['qty'],
      "rate": row['rate'],
      "amount": row['amount'],
    }).toList();

    // Save the main expense data in Transactions
    await transactionsRef.child(transactionId).set(expenseData);

    // Save the items list under the transaction
    await transactionsRef.child(transactionId).child("items").set(itemsList);

    // Ensure Cash node exists
    DatabaseEvent cashEvent = await cashRef.once();
    if (cashEvent.snapshot.value == null) {
      await cashRef.set({"total_balance": "0", "Cash_transaction": {}});
    }

    // Deduct from selected payment type
    if (selectedPaymentType == "Cash") {
      // Fetch current Cash balance **outside** Cash_transaction
      DataSnapshot cashSnapshot = (await cashRef.once()).snapshot;
      double currentCashBalance = double.tryParse(cashSnapshot.child("total_balance").value.toString()) ?? 0.0;
      double updatedCashBalance = currentCashBalance - totalAmount;

      // Update total_balance **outside** Cash_transaction
      await cashRef.update({"total_balance": updatedCashBalance.toString()});

      // Store transaction inside Cash_transaction
      await cashTransactionRef.child(transactionId).set({
        "transactionId": transactionId,
        "type": "expenses",
        "amount": "-$totalAmount",
        "date": "${time.day}/${time.month}/${time.year}",
        "category": expense_category_controller.text.trim(),
        "description": description_controller.text.trim(),
        "paymentType": "Cash",
      });

    } else {
      // Ensure selected Bank node exists
      DatabaseReference selectedBankRef = bankAccountsRef.child(selectedPaymentType!);
      DatabaseEvent bankEvent = await selectedBankRef.once();
      if (bankEvent.snapshot.value == null) {
        await selectedBankRef.set({"total_balance": "0"});
      }

      // Fetch current Bank balance
      DataSnapshot bankSnapshot = (await selectedBankRef.once()).snapshot;
      double currentBankBalance = double.tryParse(bankSnapshot.child("total_balance").value.toString()) ?? 0.0;
      double updatedBankBalance = currentBankBalance - totalAmount;

      // Update total_balance **outside** transactions
      await selectedBankRef.update({"total_balance": updatedBankBalance.toString()});

      // Store transaction inside Bank transactions
      await selectedBankRef.child("transactions").child(transactionId).set({
        "transactionId": transactionId,
        "type": "expenses",
        "amount": "-$totalAmount",
        "date": "${time.day}/${time.month}/${time.year}",
        "category": expense_category_controller.text.trim(),
        "description": description_controller.text.trim(),
        "paymentType": "Bank",
      });
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Expense Data & Items Saved Successfully!')),
    );
    Navigator.pop(context);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text('Expense'),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
            icon: Icon(FlutterRemix.settings_2_line),
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
        onLeftButtonPressed: (){
          Navigator.pop(context);
        },
        onRightButtonPressed: () async {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await saveExpenseData(user.uid);
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
                physics: BouncingScrollPhysics(),
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
                        padding: EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text.isEmpty) {
                                    return _expenseCategories;
                                  }
                                  return _expenseCategories
                                      .where((category) => category
                                      .toLowerCase()
                                      .contains(textEditingValue.text.toLowerCase()))
                                      .toList()
                                    ..add('+ Add Expense Category');
                                },
                                onSelected: (String selection) {
                                  if (selection == '+ Add Expense Category') {
                                    _showAddCategoryDialog();
                                  }
                                },
                                fieldViewBuilder: (BuildContext context,
                                    TextEditingController textEditingController,
                                    FocusNode focusNode,
                                    VoidCallback onFieldSubmitted) {
                                  return TextField(
                                    focusNode: focusNode,
                                    controller:expense_category_controller,
                                    onChanged: (value){
                                      setState(() {
                                        expense_category_controller.text = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Expense Category",
                                      hintText: "Type or select...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                      ),
                                    ),
                                  );
                                },
                                  optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4.0,
                                        child: Container(
                                          width: MediaQuery.of(context).size.width - 32, // Adjust the width dynamically
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final option = options.elementAt(index);
                                              return ListTile(
                                                title: Text(option),
                                                onTap: () {
                                                  onSelected(option);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                              ),
                            SizedBox(height: 30,),
                            Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Text("Billed Iitems",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),)
                                  ),
                                  Text("Delete Column",style: TextStyle(fontSize: 15),)
                                ]
                            ),
                            Center(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 1,
                                  headingRowHeight: 60,
                                  columns: <DataColumn>[
                                    DataColumn(
                                      label: Container(
                                        width: 90,
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(12.0),
                                        child: Text("Item Name"),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        width: 90,
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(12.0),
                                        child: Text("Qty"),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        width: 90,
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(12.0),
                                        child: Text("Rate"),
                                      ),
                                    ),
                                    DataColumn(
                                      label: Container(
                                        width: 90,
                                        color: Colors.grey[300],
                                        padding: EdgeInsets.all(12.0),
                                        child: Text("Amount"),
                                      ),
                                    ),
                                  ],
                                  rows: [
                                    // Editable rows
                                    for (int index = 0; index < tableRows.length; index++)
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(
                                            Center(
                                              child: Container(
                                                height: 45,
                                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                                color: Colors.grey[100],
                                                child: Center(
                                                  child: SizedBox(
                                                    width: 90,
                                                    child: TextField(
                                                      onTap: () {
                                                        if (index == tableRows.length - 1) {
                                                          _addNewRow();
                                                        }
                                                      },
                                                      onChanged: (value) {
                                                        setState(() {
                                                          tableRows[index]['itemName'] = value;
                                                        });
                                                      },
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        isDense: true,
                                                        contentPadding:
                                                        EdgeInsets.symmetric(vertical: 8.0),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              height: 45,
                                              margin: EdgeInsets.symmetric(vertical: 5.0),
                                              color: Colors.grey[100],
                                              child: Center(
                                                child: SizedBox(
                                                  width: 60,
                                                  child: TextField(
                                                    onTap: () {
                                                      if (index == tableRows.length - 1) {
                                                        _addNewRow();
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tableRows[index]['qty'] = value;
                                                        // Update the amount dynamically
                                                        double qty = double.tryParse(value) ?? 0.0;
                                                        double rate =
                                                            double.tryParse(tableRows[index]['rate']) ??
                                                                0.0;
                                                        tableRows[index]['amount'] =
                                                            (qty * rate).toStringAsFixed(2);
                                                      });
                                                    },
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(vertical: 8.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              height: 45,
                                              margin: EdgeInsets.symmetric(vertical: 5.0),
                                              color: Colors.grey[100],
                                              child: Center(
                                                child: SizedBox(
                                                  width: 60,
                                                  child: TextField(
                                                    onTap: () {
                                                      if (index == tableRows.length - 1) {
                                                        _addNewRow();
                                                      }
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        tableRows[index]['rate'] = value;
                                                        // Update the amount dynamically
                                                        double qty =
                                                            double.tryParse(tableRows[index]['qty']) ??
                                                                0.0;
                                                        double rate = double.tryParse(value) ?? 0.0;
                                                        tableRows[index]['amount'] =
                                                            (qty * rate).toStringAsFixed(2);
                                                      });
                                                    },
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      isDense: true,
                                                      contentPadding:
                                                      EdgeInsets.symmetric(vertical: 8.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              height: 45,
                                              margin: EdgeInsets.symmetric(vertical: 5.0),
                                              color: Colors.grey[100],
                                              child: Center(
                                                child: Text(
                                                  tableRows[index]['amount'], // Dynamic amount
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                    // Total Row
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Container(
                                            height: 45,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                'Total', // Label for total row
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            height: 45,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                '-', // No total for quantity
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            height: 45,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                '-', // No total for rate
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            height: 45,
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Text(
                                                _calculateTotal().toStringAsFixed(2), // Total amount
                                                style: TextStyle(fontWeight: FontWeight.bold),
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

                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 10,bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                "Total Price",
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
                                    readOnly: true,
                                    controller: total_price,
                                    onChanged: (value) {
                                      setState(() {
                                        total_price.text = value;
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
                      if (_calculateTotal() != null)
                      Container(
                          padding: EdgeInsets.all(16),
                          color: Colors.white,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Row(
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
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                            ],
                          ),
                        ),
                      SizedBox(height: 15,),

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