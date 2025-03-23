import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_signup/Home/Transaction%20Details/Add%20Txn/Expense/Expenses.dart';

class Expense extends StatefulWidget {
  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<Expense> with SingleTickerProviderStateMixin {
  late TabController _tabController;



  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> items = [];
  double totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchExpenses();
  }

  void fetchExpenses() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    final DatabaseReference _dbRef = FirebaseDatabase.instance.ref("users/$userId/Transactions");

    DatabaseEvent event = await _dbRef.once();
    Map<String, dynamic> transactions = (event.snapshot.value as Map).cast<String, dynamic>();
    Map<String, double> categoryMap = {};
    List<Map<String, dynamic>> itemList = [];
    double total = 0.0;

    transactions.forEach((key, value) {
      if (value["type"] == "expenses") {
        String category = value["expenses_category"] ?? "Unknown";
        double amount = double.tryParse(value["amount"].toString()) ?? 0.0;
        total += amount;

        categoryMap[category] = (categoryMap[category] ?? 0.0) + amount;

        if (value.containsKey("items")) {
          (value["items"] as List).forEach((item) {
            itemList.add({
              "title": item["itemName"],
              "amount": "₹ ${item["amount"]}"
            });
          });
        }
      }
    });

    setState(() {
      categories = categoryMap.entries.map((e) => {"title": e.key, "amount": "₹ ${e.value}"}).toList();
      items = itemList;
      totalAmount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.blue,
                    labelColor: Colors.blue,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.0, color: Colors.blue),
                      insets: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.30),
                    ),
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: "Categories"),
                      Tab(text: "Items"),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("Total: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("₹ $totalAmount", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(categories[index]["title"], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            trailing: Text(categories[index]["amount"], style: TextStyle(fontSize: 15)),
                            tileColor: Colors.white,
                            shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                          );
                        },
                      ),
                      ListView.builder(
                        padding: EdgeInsets.only(bottom: 80),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(items[index]["title"], style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            trailing: Text(items[index]["amount"], style: TextStyle(fontSize: 15)),
                            tileColor: Colors.white,
                            shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Expenses()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE03537),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white),
                      SizedBox(width: 10),
                      Text("Add New Expenses", style: TextStyle(color: Colors.white)),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}