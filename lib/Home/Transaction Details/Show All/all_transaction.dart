import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class All_Transaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AllTransaction();
}

class AllTransaction extends State<All_Transaction> {
  var firstDate = DateTime.now();
  var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  String? selected_transaction = "All Transactions";
  final List<String> Item_Transaction = [
    "All Transactions",
    "Payment-in",
    "Payment-out",
    "Sale",
    "Purchase",
    "Expense"
  ];

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions");

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
      List<Map<String, dynamic>> transactionList = [];

      data.forEach((key, value) {
        transactionList.add(Map<String, dynamic>.from(value));
      });

      setState(() {
        transactions = transactionList;
        filteredTransactions = transactionList; // Initialize filtered list
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        // Filter by date range
        int transactionTime = transaction["current_time"] ?? 0;
        DateTime transactionDate = DateTime.fromMillisecondsSinceEpoch(transactionTime);
        bool isWithinDateRange = transactionDate.isAfter(firstDate) && transactionDate.isBefore(lastDate);

        // Filter by transaction type (case-insensitive comparison)
        bool matchesType = selected_transaction == "All Transactions" ||
            transaction["type"]?.toLowerCase() == selected_transaction?.toLowerCase();

        return isWithinDateRange && matchesType;
      }).toList();
    });
  }

  void _select_firstDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        firstDate = picked;
      });
      applyFilters(); // Apply filters after selecting the date
    }
  }

  void _select_lastDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        lastDate = picked;
      });
      applyFilters(); // Apply filters after selecting the date
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xFF0078AA),
        backgroundColor: Color(0xFF0078AA),
        title: Text(
          "All Transaction",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          SizedBox(width: 10,),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.blue,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _select_firstDate(context),
                    child: Text(
                      '${firstDate.day}/${firstDate.month}/${firstDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'to',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _select_lastDate(context),
                    child: Text(
                      '${lastDate.day}/${lastDate.month}/${lastDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                ],
              ),
              Divider(),
              Align(
                alignment: Alignment.topLeft,
                child: DropdownButton<String>(
                  value: selected_transaction,
                  hint: Text(
                    'Select Transaction',
                    style: TextStyle(fontSize: 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selected_transaction = newValue;
                    });
                    applyFilters(); // Apply filters after selecting transaction type
                  },
                  items: Item_Transaction.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
                  underline: Container(),
                ),
              ),
              Divider(),
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                  child: Text(
                    "No Transactions Found",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    var transaction = filteredTransactions[index];
                    return Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      transaction["customer"] ?? "N/A",
                                      style: TextStyle(fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      transaction["date"] ?? "N/A",
                                      style: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                transaction["type"] ?? "N/A",
                                style: TextStyle(fontSize: 12, color: Colors.black),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                children: [
                                  Text(
                                    "Total : ₹${transaction["total_answer"] ?? "0"}",
                                    style: TextStyle(fontSize: 12, color: Colors.black),
                                  ),
                                  Text(
                                    "Balance : ₹${transaction["balance_due"] ?? "0"}",
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}