
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

class Expenses_Details extends StatefulWidget {

  String transactionId;
  Expenses_Details({required this.transactionId});
  @override
  State<StatefulWidget> createState() => _Expenses_Details(transactionId: this.transactionId);
}

class _Expenses_Details extends State<Expenses_Details> {
  String transactionId;
  _Expenses_Details({required this.transactionId});

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
      double amount = double.tryParse(row['amount']) ?? 0.0;
      total += amount;
    }
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

  bool is_readyonly = true;



  void fetchExpensesData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/$transactionId");

    try {
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        Map<String, dynamic> data = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          description_controller.text = data['description'] ?? "";
          expense_category_controller.text = data['expenses_category'] ?? "";
          total_price.text = (data['total_amount'] != null && data['total_amount'] != "")
              ? data['total_amount']
              : "0.00"; // Default value

          selectedPaymentType = data['paymentType'] ?? "Cash";
          invoice_no = int.tryParse(data['invoice_no'].toString()) ?? 0;
          image = data['Image'] ?? null;

          // Handle items safely
          if (data.containsKey('items') && data['items'] is List) {
            tableRows = (data['items'] as List).map((e) {
              return {
                'itemName': e['itemName'] ?? "",
                'qty': e['qty'].toString(), // Ensure it's a string
                'rate': e['rate'].toString(),
                'amount': e['amount'].toString(),
              };
            }).toList();
          } else {
            tableRows = [
              {'itemName': '', 'qty': '0', 'rate': '0.00', 'amount': '0.00'},
            ];
          }
        });

        print("Expense data fetched successfully!");
      } else {
        print("No expense transaction found!");
      }
    } catch (error) {
      print("Error fetching expense data: $error");
    }
  }
  Future<void> updateExpenseData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DatabaseReference expenseRef = FirebaseDatabase.instance.ref("users/$userId/Transactions/$transactionId");
    DatabaseReference cashRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash");
    DatabaseReference cashTransactionsRef = cashRef.child("Cash_transaction");
    DatabaseReference bankAccountsRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank");

    // Fetch the old transaction data before updating
    DatabaseEvent event = await expenseRef.once();
    if (!event.snapshot.exists) {
      print("Transaction not found!");
      return;
    }

    Map<String, dynamic> oldData = Map<String, dynamic>.from(event.snapshot.value as Map);
    String oldPaymentType = oldData['paymentType'] ?? "Cash";
    double oldTotalAmount = double.tryParse(oldData['total_amount'].toString()) ?? 0.0;

    // Get new values from UI
    String? newPaymentType = selectedPaymentType;
    double newTotalAmount = double.tryParse(total_price.text) ?? 0.0;

    // Filter out empty rows
    List<Map<String, dynamic>> filteredItems = tableRows.where((row) {
      return row['itemName'].toString().trim().isNotEmpty &&
          row['qty'].toString().trim().isNotEmpty &&
          row['rate'].toString().trim().isNotEmpty &&
          row['amount'].toString().trim().isNotEmpty;
    }).toList();

    Map<String, dynamic> updatedData = {
      "description": description_controller.text,
      "expenses_category": expense_category_controller.text,
      "total_amount": total_price.text.isNotEmpty ? total_price.text : "0.00",
      "paymentType": newPaymentType,
      "invoice_no": invoice_no.toString(),
      "Image": image ?? "",
      "items": filteredItems, // Only non-empty rows
    };

    try {
      // **STEP 1: Restore Old Amount if Payment Type Changes**
      if (oldPaymentType != newPaymentType) {
        if (oldPaymentType == "Cash") {
          // Restore amount to Cash total_balance (outside Cash_transaction)
          DatabaseEvent cashEvent = await cashRef.once();
          if (cashEvent.snapshot.value != null) {
            Map<dynamic, dynamic> cashData = cashEvent.snapshot.value as Map<dynamic, dynamic>;
            double currentCashBalance = double.tryParse(cashData["total_balance"].toString()) ?? 0.0;
            await cashRef.update({"total_balance": (currentCashBalance + oldTotalAmount).toString()});
          }
          // Remove old transaction from Cash_transaction
          await cashTransactionsRef.child(transactionId).remove();
        } else {
          // Restore amount to the old Bank's total_balance
          DatabaseReference oldBankRef = bankAccountsRef.child(oldPaymentType);
          DatabaseEvent bankEvent = await oldBankRef.once();
          if (bankEvent.snapshot.value != null) {
            Map<dynamic, dynamic> bankData = bankEvent.snapshot.value as Map<dynamic, dynamic>;
            double currentBankBalance = double.tryParse(bankData["total_balance"].toString()) ?? 0.0;
            await oldBankRef.update({"total_balance": (currentBankBalance + oldTotalAmount).toString()});
          }
          // Remove old transaction from the old bank transactions
          await oldBankRef.child("transactions").child(transactionId).remove();
        }
      }

      // **STEP 2: Update Expense Data**
      await expenseRef.update(updatedData);

      // **STEP 3: Deduct Amount from the New Payment Type**
      if (newPaymentType == "Cash") {
        // Deduct from Cash total_balance
        DatabaseEvent cashEvent = await cashRef.once();
        if (cashEvent.snapshot.value == null) {
          await cashRef.set({"total_balance": "0"});
        }
        DatabaseEvent updatedCashEvent = await cashRef.once();
        if (updatedCashEvent.snapshot.value != null) {
          Map<dynamic, dynamic> cashData = updatedCashEvent.snapshot.value as Map<dynamic, dynamic>;
          double currentCashBalance = double.tryParse(cashData["total_balance"].toString()) ?? 0.0;
          await cashRef.update({"total_balance": (currentCashBalance - newTotalAmount).toString()});
        }
        // Save expense transaction inside Cash_transaction
        await cashTransactionsRef.child(transactionId).set({
          "transactionId": transactionId,
          "type": "expenses",
          "amount": "-$newTotalAmount",
          "date": "${time.day}/${time.month}/${time.year}",
          "category": expense_category_controller.text.trim(),
          "description": description_controller.text.trim(),
          "paymentType": "Cash",
        });
      } else {
        // Deduct from selected Bank total_balance
        DatabaseReference selectedBankRef = bankAccountsRef.child(newPaymentType!);
        DatabaseEvent updatedBankEvent = await selectedBankRef.once();
        if (updatedBankEvent.snapshot.value != null) {
          Map<dynamic, dynamic> bankData = updatedBankEvent.snapshot.value as Map<dynamic, dynamic>;
          double currentBankBalance = double.tryParse(bankData["total_balance"].toString()) ?? 0.0;
          await selectedBankRef.update({"total_balance": (currentBankBalance - newTotalAmount).toString()});
        }
        // Save expense transaction inside selected bank transactions
        await selectedBankRef.child("transactions").child(transactionId).set({
          "transactionId": transactionId,
          "type": "expenses",
          "amount": "-$newTotalAmount",
          "date": "${time.day}/${time.month}/${time.year}",
          "category": expense_category_controller.text.trim(),
          "description": description_controller.text.trim(),
          "paymentType": "Bank",
        });
      }

      print("Expense data updated successfully!");

      // Show success Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Expense data updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      print("Error updating expense data: $error");

      // Show error Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update expense data!"),
          backgroundColor: Colors.red,
        ),
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

  @override
  void initState() {
    super.initState();
    fetchExpensesData();
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
          updateExpenseData();
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
                                .where((category) => category.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                                .toList()
                              ..add('+ Add Expense Category');
                          },
                          onSelected: (String selection) {
                            if (selection == '+ Add Expense Category') {
                              _showAddCategoryDialog();
                            }
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController,
                              FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            return TextField(
                              focusNode: focusNode,
                              controller: expense_category_controller,
                              readOnly: is_readyonly, // Controlled by i_readonly
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
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                "Billed Items",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Text("Delete Column", style: TextStyle(fontSize: 15)),
                          ],
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
                                                  controller: TextEditingController(text: tableRows[index]['itemName']),
                                                  readOnly: is_readyonly,
                                                  onTap: () {
                                                    if (!is_readyonly && index == tableRows.length - 1) {
                                                      _addNewRow();
                                                    }
                                                  },
                                                  onChanged: (value) {
                                                    if (!is_readyonly) {
                                                      setState(() {
                                                        tableRows[index]['itemName'] = value;
                                                      });
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                                                controller: TextEditingController(text: tableRows[index]['qty']),
                                                readOnly: is_readyonly,
                                                keyboardType: TextInputType.number,
                                                onTap: () {
                                                  if (!is_readyonly && index == tableRows.length - 1) {
                                                    _addNewRow();
                                                  }
                                                },
                                                onChanged: (value) {
                                                  if (!is_readyonly) {
                                                    setState(() {
                                                      tableRows[index]['qty'] = value;
                                                      double qty = double.tryParse(value) ?? 0.0;
                                                      double rate = double.tryParse(tableRows[index]['rate']) ?? 0.0;
                                                      tableRows[index]['amount'] = (qty * rate).toStringAsFixed(2);
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                                                controller: TextEditingController(text: tableRows[index]['rate']),
                                                readOnly: is_readyonly,
                                                keyboardType: TextInputType.number,
                                                onTap: () {
                                                  if (!is_readyonly && index == tableRows.length - 1) {
                                                    _addNewRow();
                                                  }
                                                },
                                                onChanged: (value) {
                                                  if (!is_readyonly) {
                                                    setState(() {
                                                      tableRows[index]['rate'] = value;
                                                      double qty = double.tryParse(tableRows[index]['qty']) ?? 0.0;
                                                      double rate = double.tryParse(value) ?? 0.0;
                                                      tableRows[index]['amount'] = (qty * rate).toStringAsFixed(2);
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(vertical: 8.0),
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
                                              tableRows[index]['amount'],
                                              style: TextStyle(color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                DataRow(
                                  cells: <DataCell>[
                                    DataCell(
                                      Container(
                                        height: 45,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Text(
                                            'Total',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Container(height: 45, color: Colors.grey[200], child: Center(child: Text('-')))),
                                    DataCell(Container(height: 45, color: Colors.grey[200], child: Center(child: Text('-')))),
                                    DataCell(
                                      Container(
                                        height: 45,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Text(
                                            _calculateTotal().toStringAsFixed(2),
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
                                  readOnly: is_readyonly,
                                  controller: total_price,
                                  onChanged: (value) {
                                    setState(() {
                                      total_price.text = value;
                                    });
                                  },
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.end,
                                  decoration: InputDecoration(
                                    hintText: "${_calculateTotal()}",
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
                                        if(is_readyonly!=true) {
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