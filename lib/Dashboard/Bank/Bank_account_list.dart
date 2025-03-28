import 'package:billing_sphere/Dashboard/Bank/Bank_Adjustment.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_Transfer.dart';
import 'package:billing_sphere/Dashboard/Bank/Bank_to_Bank_Transfer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:remixicon/remixicon.dart';

import '../../Home/Transaction Details/Show All/add_bank_account.dart';

class Bank_Account_List extends StatefulWidget {
  const Bank_Account_List({super.key});

  @override
  State<Bank_Account_List> createState() => _Bank_Account_ListState();
}

class _Bank_Account_ListState extends State<Bank_Account_List> {
  List<Map<String, dynamic>> bankAccounts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBankAccounts();
  }

  Future<void> fetchBankAccounts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    String userId = user.uid;
    DatabaseReference bankRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Bank");

    try {
      DatabaseEvent event = await bankRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        bankAccounts.clear();

        data.forEach((bankId, bankData) {
          if (bankData is Map) {
            bankAccounts.add({
              'bankName': bankData['bank_name'] ?? 'Unknown Bank',
              'totalBalance': double.tryParse(bankData['total_balance']?.toString() ?? '0') ?? 0.0,
              'accountHolder': bankData['holder_name'] ?? '',
              'ifsc': bankData['ifac'] ?? '',
            });
          }
        });
      }
    } catch (e) {
      print("Error fetching bank accounts: $e");
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
        title: Text('Bank Accounts List', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.blue[50],
        padding: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Column(
              children: [

                  Expanded(
                    child: isLoading?Center(child: CircularProgressIndicator(color: Colors.black,)):
                       ListView.builder(
                        itemCount: bankAccounts.length,
                        itemBuilder: (context, index) {
                          final bank = bankAccounts[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    bank['bankName'],
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    "₹ ${bank['totalBalance'].toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF38C782)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFFE03537), width: 2),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Add_Bank_Account()));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add Bank",
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
                      onPressed: () {
                        _showTransferOptions(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Deposit/Withdraw",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
