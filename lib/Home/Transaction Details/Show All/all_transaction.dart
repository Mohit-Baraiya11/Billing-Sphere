import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class All_Transaction extends StatefulWidget {
  @override
  State<All_Transaction> createState() => _AllTransactionState();
}

class _AllTransactionState extends State<All_Transaction> {
  DateTime firstDate = DateTime.now().subtract(Duration(days: 30));
  DateTime lastDate = DateTime.now();

  String? selectedTransaction = "All Transactions";
  final List<String> transactionTypes = [
    "All Transactions",
    "Payment-in",
    "Payment-out",
    "Sale",
    "Purchase",
    "Expenses"
  ];

  List<Map<String, dynamic>> transactions = [];
  List<Map<String, dynamic>> filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions");

    DatabaseEvent event = await ref.once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> transactionList = data.entries.map((entry) {
        return {"id": entry.key, ...Map<String, dynamic>.from(entry.value)};
      }).toList();

      setState(() {
        transactions = transactionList;
        applyFilters();
      });
    }
  }

  void applyFilters() {
    setState(() {
      filteredTransactions = transactions.where((transaction) {
        // Convert timestamp to DateTime
        int? transactionTime = transaction["current_time"];
        if (transactionTime == null) return false;
        DateTime transactionDate = DateTime.fromMillisecondsSinceEpoch(transactionTime);

        // Date range filter (inclusive)
        bool isWithinDateRange = transactionDate.isAfter(firstDate.subtract(Duration(days: 1))) &&
            transactionDate.isBefore(lastDate.add(Duration(days: 1)));

        // Transaction type filter
        bool matchesType = selectedTransaction == "All Transactions" ||
            (transaction["type"]?.toLowerCase() == selectedTransaction?.toLowerCase());

        return isWithinDateRange && matchesType;
      }).toList();
    });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? firstDate : lastDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          firstDate = picked;
        } else {
          lastDate = picked;
        }
      });
      applyFilters();
    }
  }

  Widget _buildTransactionTile(Map<String, dynamic> transaction) {
    String type = transaction["type"] ?? "Unknown";
    String customer = transaction["customer"] ?? "N/A";
    String date = transaction["date"] ?? "N/A";
    String amount = transaction["total_amount"]?.toString() ?? "0";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(customer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(type, style: TextStyle(fontSize: 12, color: Colors.black)),
          Text("₹$amount", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text("All Transactions", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Text(
                    '${firstDate.day}/${firstDate.month}/${firstDate.year}',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ),
                SizedBox(width: 4),
                Text('to', style: TextStyle(fontSize: 12, color: Colors.grey)),
                SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _selectDate(context, false),
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
                value: selectedTransaction,
                hint: Text('Select Transaction', style: TextStyle(fontSize: 12)),
                icon: Icon(Icons.arrow_drop_down, size: 16),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTransaction = newValue;
                  });
                  applyFilters();
                },
                items: transactionTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 12)),
                  );
                }).toList(),
                underline: Container(),
              ),
            ),
            Divider(),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? Center(child: Text("No Transactions Found", style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                itemCount: filteredTransactions.length,
                itemBuilder: (context, index) {
                  return _buildTransactionTile(filteredTransactions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
