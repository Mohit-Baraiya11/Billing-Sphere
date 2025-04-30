import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Purchase/purchase.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/Prefered_underline_appbar.dart';

class Purchase_dashboard extends StatefulWidget {
  const Purchase_dashboard({super.key});

  @override
  State<Purchase_dashboard> createState() => _Purchase_dashboard();
}

class _Purchase_dashboard extends State<Purchase_dashboard> {
  List<Map<String, dynamic>> transactions = [];
  double totalPurchaseAmount = 0.0; // Variable to store total purchase amount
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true;
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      setState(() {
        isLoading = false;
      });
      return;
    }

    String userId = user.uid;
    DatabaseReference transactionRef = FirebaseDatabase.instance.ref("users/$userId/Transactions");

    try {
      // Fetch transactions from Transactions node
      DatabaseEvent transEvent = await transactionRef.once();
      transactions.clear();
      totalPurchaseAmount = 0.0; // Reset total purchase amount

      if (transEvent.snapshot.value != null) {
        Map<dynamic, dynamic> transData = transEvent.snapshot.value as Map<dynamic, dynamic>;

        transData.forEach((key, value) {
          if (value is Map) {
            String type = value['type']?.toString().trim().toLowerCase() ?? '';
            if (type == 'purchase') {
              double amount = double.tryParse(value['total_amount']?.toString() ?? '0') ?? 0.0;
              String name = value['party_name']?.toString() ?? 'Unknown';

              // Add to transactions list for display
              transactions.add({
                'amount': amount,
                'date': value['date']?.toString() ?? '',
                'current_time': value['current_time']?.toString() ?? '0',
                'transactionId': value['transactionId']?.toString() ?? key,
                'name': name,
                'type': type,
              });

              // Add to total purchase amount
              totalPurchaseAmount += amount;
            }
          }
        });
      }

      transactions.sort((a, b) {
        int timeA = int.tryParse(a['current_time'] ?? '0') ?? 0;
        int timeB = int.tryParse(b['current_time'] ?? '0') ?? 0;
        return timeB.compareTo(timeA); // Latest first
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() {
        isLoading = false;
      });
    }
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
        title: Text('Purchase', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
        height: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Purchase Amount Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC5EEE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Text(
                          "Total Purchase Amount",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              " ₹${totalPurchaseAmount.toStringAsFixed(2)}",
                              style:TextStyle(
                                fontSize: 20,
                                color: Color(0xFF38C782),
                              ),
                            ),
                            Icon(Remix.checkbox_multiple_blank_line),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transaction Details"),
                      Text("Amount"),
                    ],
                  ),
                   Divider(),
                  Expanded(
                    child: transactions.isEmpty
                        ? const Center(child: Text("No purchase transactions found"))
                        : ListView.builder(
                      itemCount: transactions.length,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      itemBuilder: (context, index) {
                        var transaction = transactions[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                "${transaction['type'].toString().toUpperCase()} - ${transaction['name']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(transaction['date']),
                              contentPadding: EdgeInsets.zero,
                              trailing: Text(
                                "₹${transaction['amount'].toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Color(0xFF38C782),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: const Color(0xFFE03537),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Purchase()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Remix.add_line,color: Colors.white,),
                        Text(
                          "Add Purchase",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
