import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';

class Adjust_Stock extends StatefulWidget {
  final String itemId;
  Adjust_Stock({required this.itemId});

  @override
  _AdjustStockPageState createState() => _AdjustStockPageState();
}

class _AdjustStockPageState extends State<Adjust_Stock> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  String selectedOption = "Add Stock";
  int openingStock = 0;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
    fetchItemData();
  }

  /// **Fetch Item Sale Price & Opening Stock**
  Future<void> fetchItemData() async {
    if (user == null) return;

    try {
      DatabaseReference itemRef = dbRef.child("users/${user!.uid}/Items/${widget.itemId}");
      DataSnapshot snapshot = await itemRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        double salePrice = (data['pricing']?['salePrice'] ?? 0).toDouble();
        openingStock = (data['stock']?['openingStock'] ?? 0).toInt();

        setState(() {
          priceController.text = salePrice.toStringAsFixed(2);
        });
      } else {
        debugPrint("Item not found");
      }
    } catch (e) {
      debugPrint("Error fetching item data: $e");
    }
  }

  /// **Update Stock & Add Stock Transaction**
  Future<void> updateStock() async {
    if (user == null) return;

    try {
      int quantity = int.tryParse(quantityController.text) ?? 0;
      double price = double.tryParse(priceController.text) ?? 0;
      int totalAmount = (quantity * price).toInt();
      String date = dateController.text;

      // **Validation**
      if (quantity <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Enter a valid quantity")));
        return;
      }

      int updatedStock = selectedOption == "Add Stock"
          ? openingStock + quantity
          : openingStock - quantity;

      if (updatedStock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Not enough stock available")));
        return;
      }

      // **Update stock in Firebase**
      await dbRef.child("users/${user!.uid}/Items/${widget.itemId}/stock/openingStock").set(updatedStock);

      // **Generate unique transaction ID**
      DatabaseReference transactionRef = dbRef
          .child("users/${user!.uid}/Items/${widget.itemId}/stock_transaction")
          .push();
      String transactionId = transactionRef.key ?? DateTime.now().millisecondsSinceEpoch.toString();

      // **Add stock transaction with unique ID**
      await transactionRef.set({
        "transactionId": transactionId, // Store the transaction ID
        "date": date,
        "quantity": quantity,
        "total_amount": totalAmount,
        "type": selectedOption == "Add Stock" ? "Add Stock" : "Reduce Stock",
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock updated successfully")));

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error updating stock: $e");
    }
  }

  /// **Date Picker**
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat("dd/MM/yyyy").format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Adjust Stock", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Radio(
                  value: "Add Stock",
                  groupValue: selectedOption,
                  activeColor: Colors.blue,
                  onChanged: (value) => setState(() => selectedOption = value.toString()),
                ),
                const Text("Add Stock", style: TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(width: 20),
                Radio(
                  value: "Reduce Stock",
                  groupValue: selectedOption,
                  activeColor: Colors.blue,
                  onChanged: (value) => setState(() => selectedOption = value.toString()),
                ),
                const Text("Reduce Stock", style: TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 12),
            const Text("Enter Adjustment Date", style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Select Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(FlutterRemix.calendar_line, color: Colors.blue),
                  onPressed: () => _selectDate(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Quantity",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: "Sale Price",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: updateStock,
          child: Text(selectedOption == "Add Stock" ? "Add Stock" : "Reduce Stock",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }
}
