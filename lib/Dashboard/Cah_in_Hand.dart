import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/Prefered_underline_appbar.dart';

class Cash_In_Hand extends StatefulWidget {
  const Cash_In_Hand({super.key});

  @override
  State<Cash_In_Hand> createState() => _Cash_In_HandState();
}

class _Cash_In_HandState extends State<Cash_In_Hand> {
  double totalCashBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true; // Added loading state

  @override
  void initState() {
    super.initState();
    fetchCashDetails();
  }

  Future<void> fetchCashDetails() async {
    setState(() {
      isLoading = true; // Start loading
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    String userId = user.uid;
    DatabaseReference cashRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash");

    try {
      DatabaseEvent event = await cashRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        // Fetch total balance
        if (data.containsKey('total_balance')) {
          totalCashBalance = double.tryParse(data['total_balance'].toString()) ?? 0.0;
        }

        // Fetch transactions
        transactions.clear();
        if (data.containsKey('Cash_transaction')) {
          Map<dynamic, dynamic> transData = data['Cash_transaction'] as Map<dynamic, dynamic>;

          transData.forEach((key, value) {
            if (value is Map && value.containsKey('transaction')) {
              Map<dynamic, dynamic> transactionDetails = value['transaction'];

              transactions.add({
                'amount': double.tryParse(value['amount'].toString()) ?? 0.0,
                'date': value['date'] ?? '',
                'current_time': value['current_time'] ?? '',
                'transactionId': transactionDetails['transactionId'] ?? '',
                'name': transactionDetails['party_name'] ?? 'No Description',
                'paymentType': transactionDetails['paymentType'] ?? 'Unknown',
                'party_name': transactionDetails['party_name'] ?? 'N/A',
                'phone': transactionDetails['phone'] ?? 'N/A',
                'type': transactionDetails['type'] ?? '',
              });
            }
          });

          // Sort transactions by date (latest first)
          transactions.sort((a, b) => b['current_time'].compareTo(a['current_time']));
        }
      }
    } catch (e) {
      print("Error fetching cash transactions: $e");
    }

    setState(() {
      isLoading = false; // Stop loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('Cash in hand', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner
          : Container(
        height: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFFC5EEE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Cash Balance", style: TextStyle(fontSize: 16, color: Colors.black54)),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              " ₹${totalCashBalance.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 20, color: Color(0xFF38C782)),
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
                      Text("Amount")
                    ],
                  ),
                  Divider(),
                  Expanded(
                    child: transactions.isEmpty
                        ? Center(child: Text("No transactions found"))
                        : ListView.builder(
                      itemCount: transactions.length,
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      itemBuilder: (context, index) {
                        var transaction = transactions[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                "${transaction['type'].toString().toUpperCase()} - ${transaction['name']}",
                                style: TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(transaction['date']),
                              contentPadding: EdgeInsets.zero,
                              trailing: Text(
                                "₹${transaction['amount'].toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: transaction['type'] == "expenses"
                                      ? Color(0xFFE03537)
                                      : Color(0xFF38C782),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Divider(),
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
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Color(0xFFE03537), width: 2),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bank Transfer",
                              style: TextStyle(color: Color(0xFFE03537), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          backgroundColor: Color(0xFFE03537),
                        ),
                        onPressed: () {},
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Adjust Cash",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
