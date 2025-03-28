import 'package:billing_sphere/Dashboard/Bank/Bank_Adjustment.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_Transfer.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_to_Bank_Transfer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import '../../Home/Prefered_underline_appbar.dart';
import '../../Home/Transaction Details/Show All/add_bank_account.dart';

class Bank_Details extends StatefulWidget {
  String bankName;
  Bank_Details({required this.bankName});
  @override
  State<Bank_Details> createState() => _Bank_Details(bankName: this.bankName);
}

class _Bank_Details extends State<Bank_Details> {
  final String bankName;
  _Bank_Details({required this.bankName});

  double totalBalance = 0.0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBankDetails();
  }

  Future<void> fetchBankDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      // Fetch bank details
      DataSnapshot bankSnapshot = await FirebaseDatabase.instance
          .ref('users/${user.uid}/Bank_accounts/Bank/$bankName')
          .get();

      if (bankSnapshot.value != null) {
        Map<dynamic, dynamic> bankData = bankSnapshot.value as Map<dynamic, dynamic>;

        // Extract required values
        double fetchedBalance = double.tryParse((bankData['total_balance']?.toString() ?? '0').replaceAll('\$', '')) ?? 0.0;
        double openingBalance = double.tryParse((bankData['opening_balance']?.toString() ?? '0').replaceAll('\$', '')) ?? 0.0;
        String dateAdded = bankData['date_added'] ?? '--';

        // Fetch transactions
        DataSnapshot transactionsSnapshot = await FirebaseDatabase.instance
            .ref('users/${user.uid}/Bank_accounts/Bank/$bankName/Bank_transaction')
            .get();

        List<Map<String, dynamic>> loadedTransactions = [];

        if (transactionsSnapshot.value != null) {
          Map<dynamic, dynamic> transData = transactionsSnapshot.value as Map<dynamic, dynamic>;

          transData.forEach((key, value) {
            if (value is Map) {
              // Extract amount correctly
              String? amountStr = value['amount']?.toString();
              if (amountStr == null && value.containsKey('transaction')) {
                amountStr = value['transaction']['amount']?.toString();
              }
              double amount = double.tryParse(amountStr?.replaceAll('\$', '') ?? '0') ?? 0.0;

              // Fetch correct transaction fields
              Map<dynamic, dynamic> transaction = value.containsKey('transaction')
                  ? value['transaction'] as Map<dynamic, dynamic>
                  : value;

              String displayName = transaction['customer'] ??
                  transaction['party_name'] ??
                  (transaction['type']?.toString().toLowerCase().contains('expense') ?? false
                      ? 'Expense'
                      : 'Transaction');

              loadedTransactions.add({
                'amount': amount,
                'date': transaction['date'] ?? '',
                'name': displayName,
                'type': transaction['type']?.toString().toLowerCase() ?? 'payment',
                'phone': transaction['phone'] ?? '',
                'received': transaction['received'] ?? '',
              });
            }
          });

          // Sort transactions by date (newest first)
          loadedTransactions.sort((a, b) => (b['date'] ?? '').compareTo(a['date'] ?? ''));
        }

        // **Always Add Opening Balance Transaction at the Start**
        loadedTransactions.insert(0, {
          'amount': openingBalance,
          'date': dateAdded, // Use date_added from Firebase
          'name': 'Opening Balance',
          'type': 'opening_balance',
          'phone': '',
          'received': '',
        });

        setState(() {
          totalBalance = fetchedBalance;
          transactions = loadedTransactions;
        });
      }
    } catch (e) {
      print("Error fetching bank details: $e");
    }

    setState(() => isLoading = false);
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
        title: Text('Bank Details', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Add_Bank_Account()));
              },
              icon: Icon(Remix.pencil_line)
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  color: Colors.white,
                  child: Text(bankName, style: TextStyle(fontSize: 16)),
                ),
                SizedBox(height: 10),

                // Balance Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Balance", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        SizedBox(height: 10),
                        Text(
                          " ₹${totalBalance.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 18, color: Color(0xFF38C782)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0),

                // Transactions List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Transaction Details"),
                                Text("Amount")
                              ],
                            ),
                          ),
                          Divider(),
                          Expanded(
                            child: transactions.isEmpty
                                ? Center(child: Text("No transactions found"))
                                : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        "${transaction['type'] == 'expenses' ? 'Expense' : 'Payment'} - ${transaction['name']}",
                                      ),
                                      subtitle: Text(transaction['date']),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                      trailing: Text(
                                        '₹${transaction['amount'].toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: transaction['type'] == 'expenses'
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
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    backgroundColor: Color(0xFFE03537),
                  ),
                  onPressed: () {
                    _showTransferOptions(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Deposit/Withdraw",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showTransferOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          color: Colors.white,
          height: MediaQuery.of(context).size.height*0.35,
          child: Column(
            children: [
              SizedBox(height:20,),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BankTransferPage(transferType: "Deposit",)));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.bank_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Cash\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BankTransferPage(transferType: "Withdraw",)));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.bank_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Cash to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_To_Bank_Transfer()));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.bank_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_Adjustment()));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}