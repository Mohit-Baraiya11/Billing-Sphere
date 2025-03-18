
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';

class Adjust_Stock extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => AdjustStock();
}

class AdjustStock extends State<Adjust_Stock>
{
  String selectedOption = "Add Stock"; // Default selected radio button
  TextEditingController dateController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now()); // Default date
  }

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
        title: const Text(
          "Adjust Stock",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio Buttons: Add Stock / Reduce Stock
            Row(
              children: [
                Radio(
                  value: "Add Stock",
                  groupValue: selectedOption,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value.toString();
                    });
                  },
                ),
                const Text("Add Stock",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
                const SizedBox(width: 20),
                Radio(
                  value: "Reduce Stock",
                  groupValue: selectedOption,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      selectedOption = value.toString();
                    });
                  },
                ),
                const Text("Reduce Stock",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 12),

            // Date Picker Field
            const Text("Enter Adjustment Date",
                style: TextStyle(fontSize: 14, color: Colors.grey)),
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
                  icon: const Icon(
                      FlutterRemix.calendar_line, color: Colors.blue),
                  onPressed: () {
                    _selectDate(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Quantity Input
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Price Input
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Price",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Adjustment Details Input
            TextField(
              controller: detailsController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Adjustment Details",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.all(14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            // Add your stock adjustment logic here
          },
          child:  Text(
            selectedOption == "Add Stock" ? "Add Stock" : "Reduce Stock",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}