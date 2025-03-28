import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Dashboard/Bank/Bank_Details.dart';
import 'package:google_signup/Dashboard/Bank/Bank_account_list.dart';
import 'package:google_signup/Dashboard/Cah_in_Hand.dart';
import 'package:google_signup/Dashboard/Expense/Expense.dart';
import 'package:google_signup/Dashboard/Expense/Expense_Detail.dart';
import 'package:google_signup/Dashboard/Item/Items.dart';
import 'package:google_signup/Dashboard/Payable.dart';
import 'package:google_signup/Dashboard/Purchase_Report.dart';
import 'package:google_signup/Dashboard/Receivable.dart';
import 'package:google_signup/Home/Home.dart';
import 'package:google_signup/Home/Sale_Report.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/Transaction Details/Show All/profit&loss.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  //recivable and payable
  double totalReceivable = 0.0;
  double totalPayable = 0.0;
  Future<void> fetchTotalAmounts() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference partiesRef = FirebaseDatabase.instance.ref().child('users').child('$userId').child('Parties');

    partiesRef.once().then((DatabaseEvent event) {
      double receivable = 0.0;
      double payable = 0.0;

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> parties = event.snapshot.value as Map<dynamic, dynamic>;
        parties.forEach((key, value) {
          double amount = double.tryParse(value['total_amount'].toString()) ?? 0.0;
          if (amount < 0) {
            receivable += amount;
          } else {
            payable += amount.abs();
          }
        });
      }

      setState(() {
        totalReceivable = receivable<0?-receivable:receivable;
        totalPayable = payable;
      });
    });
  }


  //total expenses amount
  double totalExpense = 0.0;
  Future<void> getTotalExpenses() async {
    double total = 0.0;

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;

    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions");
      DatabaseEvent event = await ref.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> transactions = event.snapshot.value as Map<dynamic, dynamic>;

        transactions.forEach((key, value) {
          if (value['type'] == 'expenses' && value.containsKey('amount')) {
            total += double.tryParse(value['amount'].toString()) ?? 0.0;
          }
        });

        // Use setState to update the UI
        setState(() {
          totalExpense = total;
        });
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    }
  }


  ///total cash in hand
  double totalCashInHand = 0.0;
  Future<void> loadCashBalance() async {
    totalCashInHand = await getCashBalance();
    setState(() {});
  }
  void updateCashBalance() async {
    double balance = await getCashBalance();
    setState(() {
      totalCashInHand = balance;
    });
  }
  Future<double> getCashBalance() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    String userId = user.uid;
    DatabaseReference cashRef = FirebaseDatabase.instance.ref("users/$userId/Bank_accounts/Cash");

    try {
      DataSnapshot snapshot = (await cashRef.once()).snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        if (data.containsKey('total_balance')) {
          String balanceStr = data['total_balance'].toString().replaceAll('\$', '').trim();
          return double.tryParse(balanceStr) ?? 0.0;
        }
      }
    } catch (e) {
      print("Error fetching cash balance: $e");
    }

    return 0.0;
  }


  ///total bank balance
  double totalBankBalance = 0.0;
  Future<void> fetchTotalBankBalance() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DataSnapshot snapshot = await FirebaseDatabase.instance
          .ref('users/${user.uid}/Bank_accounts/Bank')
          .get();

      if (snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        double total = 0.0;

        data.forEach((bankId, bankData) {
          if (bankData is Map) {
            double balance = double.tryParse(bankData['total_balance']?.toString() ?? '0') ?? 0.0;
            total += balance;
          }
        });

        setState(() {
          totalBankBalance = total;
        });
      }
    } catch (e) {
      print("Error calculating total bank balance: $e");
    }
  }


  ///bank acoounts
  List<Map<String, dynamic>> bankAccounts = [];
  bool isLoading = true;
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

  ///inventory
  double totalStockValue = 0.0;
  int totalItems = 0; // Variable to store total number of items

  void fetchStockValue() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference itemsRef = FirebaseDatabase.instance.ref().child("users/$userId/Items");

    itemsRef.onValue.listen((event) {
      final itemsData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (itemsData == null) {
        print("No items found");
        setState(() {
          totalStockValue = 0.0;
          totalItems = 0; // Reset item count
        });
        return;
      }

      double totalValue = 0.0;
      int itemCount = 0; // Temporary variable to count items

      itemsData.forEach((key, value) {
        double salePrice = (value["pricing"]["salePrice"] ?? 0).toDouble();
        double openingStock = (value["stock"]["openingStock"] ?? 0).toDouble();

        double stockValue = salePrice * openingStock;
        totalValue += stockValue;
        itemCount++; // Increment for each item
      });

      setState(() {
        totalStockValue = totalValue;
        totalItems = itemCount; // Update total item count
      });
    });
  }

  List<Map<String, dynamic>> lowStockItems = [];
  void fetchLowStockItems() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference itemsRef = FirebaseDatabase.instance.ref().child("users/$userId/Items");

    itemsRef.onValue.listen((event) {
      final itemsData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (itemsData == null) {
        print("No items found");
        setState(() {
          lowStockItems = [];
        });
        return;
      }

      List<Map<String, dynamic>> filteredItems = [];

      itemsData.forEach((key, value) {
        double openingStock = double.tryParse(value["stock"]["openingStock"]?.toString() ?? "0") ?? 0;
        double minStock = double.tryParse(value["stock"]["minStockQty"]?.toString() ?? "0") ?? 0;

        print("Checking Item: ${value["basicInfo"]["itemName"]} | Opening Stock: $openingStock | Min Stock: $minStock");

        if (openingStock == minStock) {
          filteredItems.add({
            "itemName": value["basicInfo"]["itemName"] ?? "Unknown",
            "stock": openingStock,
          });
        }
      });

      setState(() {
        lowStockItems = filteredItems;
      });
    });
  }


  ///Expenses
  List<Map<String, dynamic>> expenseCategories = [];
  void fetchExpenseCategories() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference categoriesRef = FirebaseDatabase.instance.ref("users/$userId/Expense_category");

    categoriesRef.onValue.listen((event) {
      final categoriesData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (categoriesData == null) {
        print("No expense categories found");
        setState(() {
          expenseCategories = [];
        });
        return;
      }

      List<Map<String, dynamic>> loadedCategories = [];

      categoriesData.forEach((key, value) {
        loadedCategories.add({
          "category": value["category_name"] ?? "Unknown",
          "total_amount": value["total_amount"]?.toString() ?? "0.00",
          "category_id": key, // Store the Firebase key for reference
        });
      });

      // Sort by highest total amount first
      loadedCategories.sort((a, b) {
        double amountA = double.tryParse(a["total_amount"]) ?? 0;
        double amountB = double.tryParse(b["total_amount"]) ?? 0;
        return amountB.compareTo(amountA);
      });

      setState(() {
        expenseCategories = loadedCategories;
      });
    });
  }


  @override
  void initState() {
    super.initState();
    fetchTotalAmounts();
    getTotalExpenses();
    loadCashBalance();
    fetchTotalBankBalance();
    fetchBankAccounts();
    fetchStockValue();
    fetchLowStockItems();
    fetchExpenseCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue.shade50,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Receivable()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    child: Icon(Remix.arrow_left_down_line, color: Colors.green, size: 20),
                                  ),
                                  SizedBox(width: 5),
                                  Text("You'll Get", style: TextStyle(fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "₹ ${totalReceivable.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Payable()));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(90),
                                    ),
                                    child: Icon(Remix.arrow_right_up_line, color: Color(0xFFE03537), size: 20),
                                  ),
                                  SizedBox(width: 5),
                                  Text("You'll Give", style: TextStyle(fontSize: 14, color: Colors.black54)),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                "₹ ${totalPayable.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                SizedBox(
                  height: 350, // Set a fixed height
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                //purchase and Expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Purchase (Feb)",
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            SizedBox(height: 5),
                            Text(
                              "₹ 110.00",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Expense()));
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Expense",
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "₹ ${totalExpense.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),



                // Cash & Bank Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Cash & Bank",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_Account_List()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Bank Balance",
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "₹ ${totalBankBalance.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF38C782),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Cash_In_Hand()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cash in-hand",
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "₹ ${totalCashInHand}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: totalCashInHand<0?Color(0xFFE03537):Color(0xFF38C782), // Red Color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "List of Bank",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      // Use ListView.builder for dynamic data
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: bankAccounts.length,
                        itemBuilder: (context, index) {
                          final bank = bankAccounts[index];
                          return ListTile(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_Details(bankName: bank['bankName'],)));
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity(vertical: -4),
                                leading: Text(bank['bankName'], style: TextStyle(fontSize: 15)),
                                trailing:  Text("₹ ${bank['totalBalance'].toStringAsFixed(2)}", style: TextStyle(fontSize: 15, color: Color(0xFFE03537)),),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Inventory Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Inventory",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => Items()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Stock Value",
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "₹ ${totalStockValue.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF38C782), // Green Color
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>Items()));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:[
                                    Text(
                                      "No. of Items",
                                      style: TextStyle(fontSize: 14, color: Colors.black54),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "${totalItems}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      if(lowStockItems.isNotEmpty)
                      Text(
                        "Low Stock Items",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: lowStockItems.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity(vertical: -4),
                            contentPadding: EdgeInsets.zero,
                            leading: Text(
                              lowStockItems[index]["itemName"],
                              style: TextStyle(fontSize: 15),
                            ),
                            trailing: Text(
                              "Stock: ${lowStockItems[index]["stock"]}",
                              style: TextStyle(fontSize: 15, color: Color(0xFFE03537)), // Red color for low stock
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Expenses Section
                if(expenseCategories.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Expenses",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: expenseCategories.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Expense_Detail(
                                      Expense_Category: expenseCategories[index]["category"],
                                    ),
                                  ),
                                );
                          },
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity(vertical: -4),
                          dense: true,
                          leading: Text(expenseCategories[index]["category"],style: TextStyle(fontSize: 15),),
                          trailing: Text("₹ ${expenseCategories[index]["total_amount"]}",style: TextStyle(fontSize: 15,color: Color(0xFFE03537),),),
                          );
                        },
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
    );
  }
}
