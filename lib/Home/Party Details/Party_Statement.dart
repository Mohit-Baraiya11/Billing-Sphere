import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../Prefered_underline_appbar.dart';

class Party_Statement extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PartyStatement();
}

class PartyStatement extends State<Party_Statement> {
  var time = DateTime.now();

  String? selectedTimeDuration = "This week";
  final List<String> timeDurationOptions = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This Financial Year',
    'custom'
  ];

  List<Map<dynamic, dynamic>> parties = [];
  List<Map<dynamic, dynamic>> transactions = [];
  List<Map<dynamic, dynamic>> filteredParties = [];
  String? selectedPartyId;
  TextEditingController searchController = TextEditingController();
  bool isLoadingParties = true;
  bool isLoadingTransactions = true;

  var firstDate = DateTime.now();
  var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  @override
  void initState() {
    super.initState();
    fetchParties();
    searchController.addListener(() {
      filterParties();
    });
  }

  // Fetch all parties from the database
  Future<void> fetchParties() async {
    setState(() {
      isLoadingParties = true;
    });

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref().child('Parties');
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> partiesData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          parties = partiesData.entries.map((entry) {
            Map<dynamic, dynamic> party = entry.value as Map<dynamic, dynamic>;
            party['id'] = entry.key;
            return party;
          }).toList();
          filteredParties = parties;
          isLoadingParties = false;
        });
      } else {
        setState(() {
          isLoadingParties = false;
        });
      }
    } catch (e) {
      print("Error fetching parties: $e");
      setState(() {
        isLoadingParties = false;
      });
    }
  }

  // Fetch transactions for the selected party
  Future<void> fetchTransactions(String partyId) async {
    setState(() {
      isLoadingTransactions = true;
    });

    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child('transactions')
          .child(partyId);

      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> transactionsData = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          transactions = transactionsData.entries.map((entry) {
            Map<dynamic, dynamic> transaction = entry.value as Map<dynamic, dynamic>;
            transaction['id'] = entry.key;
            return transaction;
          }).toList();
          isLoadingTransactions = false;
        });
      } else {
        setState(() {
          transactions = [];
          isLoadingTransactions = false;
        });
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() {
        isLoadingTransactions = false;
      });
    }
  }

  // Filter parties based on search input
  void filterParties() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredParties = parties
          .where((party) => party['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  // Show time selection modal
  void _showTimeSelectionModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: timeDurationOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(timeDurationOptions[index]),
                    trailing: selectedTimeDuration == timeDurationOptions[index]
                        ? Icon(Icons.circle, color: Colors.blue, size: 12)
                        : null,
                    onTap: () {
                      setState(() {
                        selectedTimeDuration = timeDurationOptions[index];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Select first date
  void _selectFirstDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          firstDate = picked;
        });
      }
    });
  }

  // Select last date
  void _selectLastDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          lastDate = picked;
        });
      }
    });
  }

  // Calculate totals
  double getTotalDebit() {
    return transactions
        .where((txn) => txn['balance_type'] == 'due')
        .fold(0.0, (sum, txn) => sum + (double.tryParse(txn['total'].toString()) ?? 0.0));
  }

  double getTotalCredit() {
    return transactions
        .where((txn) => txn['balance_type'] == 'rec')
        .fold(0.0, (sum, txn) => sum + (double.tryParse(txn['total'].toString()) ?? 0.0));
  }

  double getClosingBalance() {
    return getTotalDebit() - getTotalCredit();
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
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text('Party Statement', style: TextStyle(color: Colors.black)),
        bottom: Prefered_underline_appbar(),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          SizedBox(width: 10),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search bar for selecting party
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search for a party",
                      prefixIcon: Icon(Icons.search, color: Colors.blue),
                      suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onTap: () {
                      filterParties();
                    },
                  ),
                  if (searchController.text.isNotEmpty && filteredParties.isNotEmpty)
                    Container(
                      height: 200,
                      color: Colors.white,
                      child: ListView.builder(
                        itemCount: filteredParties.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(filteredParties[index]['name']),
                            onTap: () {
                              setState(() {
                                selectedPartyId = filteredParties[index]['id'];
                                searchController.text = filteredParties[index]['name'];
                                fetchTransactions(selectedPartyId!);
                              });
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),

            // Date selection
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 4, bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showTimeSelectionModal(context);
                    },
                    child: Container(
                      child: Row(
                        children: [
                          Text("${selectedTimeDuration}"),
                          SizedBox(width: 50),
                          Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                    child: VerticalDivider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _selectFirstDate(context),
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
                    onTap: () => _selectLastDate(context),
                    child: Text(
                      '${lastDate.day}/${lastDate.month}/${lastDate.year}',
                      style: TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: 20),
                  Icon(FlutterRemix.calendar_2_line, color: Colors.blueAccent, size: 15),
                ],
              ),
            ),
            Divider(),

            // Main content
            Expanded(
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Colors.blue.shade200, Colors.blue.shade50],
                  ),
                ),
                padding: EdgeInsets.all(8.0),
                child: isLoadingParties
                    ? Center(child: CircularProgressIndicator())
                    : selectedPartyId == null
                    ? Center(child: Text("Please select a party to view transactions"))
                    : Column(
                  children: [
                    // Summary cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Debit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "₹ ${getTotalDebit().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Credit",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "₹ ${getTotalCredit().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Closing Balance",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "₹ ${getClosingBalance().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: getClosingBalance() >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Transaction Details Table
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    "Txns Type",
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Sale Amount",
                                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Profit/Loss",
                                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.black12),
                            Expanded(
                              child: isLoadingTransactions
                                  ? Center(child: CircularProgressIndicator())
                                  : transactions.isEmpty
                                  ? Center(child: Text("No transactions found for this party"))
                                  : ListView.builder(
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(transaction['type'] ?? ''),
                                                  SizedBox(height: 2),
                                                  Text(
                                                    "${transaction['date'] ?? ''} - ${transaction['description'] ?? ''}",
                                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text("₹ ${transaction['total']?.toString() ?? '0.00'}"),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  "₹ ${transaction['profit_loss']?.toString() ?? '0.00'}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: (double.tryParse(transaction['profit_loss']?.toString() ?? '0') ?? 0) >= 0
                                                        ? Colors.green
                                                        : Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
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