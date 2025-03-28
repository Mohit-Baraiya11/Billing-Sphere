import 'package:billing_sphere/Home/Prefered_underline_appbar.dart';
import 'package:billing_sphere/Items/Adjust_Stock.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Items_Details extends StatefulWidget {
  final String itemId;
  const Items_Details({Key? key, required this.itemId}) : super(key: key);

  @override
  State<Items_Details> createState() => _ItemsDetailState();
}

class _ItemsDetailState extends State<Items_Details> {
  Map<String, dynamic> itemData = {
    'itemName': 'Loading...',
    'Location': 'Loading...',
    'salePrice': 0.0,
    'purchasePrice': 0.0,
    'openingStock': 0,
    'itemCode': 'Loading...',
  };
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DatabaseReference itemRef = FirebaseDatabase.instance
          .ref("users/${user.uid}/Items/${widget.itemId}");

      DatabaseEvent event = await itemRef.once();
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        // **Fetch stock transactions**
        Map<dynamic, dynamic>? stockTransactions = data['stock_transaction'];

        List<Map<String, dynamic>> transactionsList = [];
        if (stockTransactions != null) {
          stockTransactions.forEach((key, value) {
            transactionsList.add({
              'transactionId': value['transactionId'] ?? '',
              'type': value['type'] ?? 'Unknown',
              'date': value['date'] ?? '',
              'quantity': value['quantity'] ?? 0,
              'total_amount': value['total_amount'] ?? 0,
            });
          });
        }

        // **Update state**
        setState(() {
          itemData = {
            'itemName': data['basicInfo']?['itemName'] ?? 'No Name',
            'Location': data['stock']?['location'] ?? 'No Location',
            'salePrice': data['pricing']?['salePrice']?.toDouble() ?? 0.0,
            'purchasePrice': data['pricing']?['purchasePrice']?.toDouble() ?? 0.0,
            'openingStock': data['stock']?['openingStock']?.toInt() ?? 0,
            'itemCode': data['basicInfo']?['itemCode'] ?? 'No Code',
            'transactions': transactionsList, // Store all transactions
          };
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching item details: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate stock value
    double stockValue = itemData['salePrice'] * itemData['openingStock'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        title: Text("Item Details", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: Colors.black)),
        bottom: Prefered_underline_appbar(),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Image.asset(
              "Assets/Images/xls.png",
              height: 25,
              width: 25,
            ),
          ),
          IconButton(
            icon: Icon(FlutterRemix.pencil_line, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Name and Location
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemData['itemName'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Location: ${itemData['Location']}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Pricing and Stock Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Sale Price", style: TextStyle(color: Colors.grey)),
                            Text("₹ ${itemData['salePrice'].toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Purchase Price", style: TextStyle(color: Colors.grey)),
                            Text("₹ ${itemData['purchasePrice'].toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("In Stock", style: TextStyle(color: Colors.grey)),
                            Text(itemData['openingStock'].toString(),
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stock Value and Item Code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Stock Value", style: TextStyle(color: Colors.grey)),
                            Text("₹ ${stockValue.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Item Code", style: TextStyle(color: Colors.grey)),
                            Text(itemData['itemCode'],
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stock Transactions Header
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey.shade100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stock Transactions",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Transactions", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text("Quantity", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text("Total Amount", style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stock Transaction List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: itemData['transactions'].length, 
                    itemBuilder: (context, index) {
                      var transaction = itemData['transactions'][index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8, top: 8, bottom: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction['type'],
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  Text(
                                    transaction['date'],
                                    style: TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 40,),
                            Expanded(child: Text(transaction['quantity'].toString(), style: TextStyle(fontSize: 14))),
                            Text("₹ ${transaction['total_amount'].toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    },
                  ),

                ],
              ),
            ),
          ),

          // Adjust Stock Button at Bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(90),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Adjust_Stock(itemId: widget.itemId,),
                    ),
                  );
                },
                child: SizedBox(
                  width: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(width: 8),
                      Text(
                        "Adjust Stock",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}