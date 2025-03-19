import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';

class Add_Items_to_Sale extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? existingItem; // For editing an existing item

  Add_Items_to_Sale({required this.title, this.existingItem});

  @override
  State<StatefulWidget> createState() => _AddItemsToSaleState(title: title, existingItem: existingItem);
}

class _AddItemsToSaleState extends State<Add_Items_to_Sale> {
  String? selectedUnit = 'Kilogram';
  String? taxOption = 'Without Tax';
  String? title;
  Map<String, dynamic>? existingItem; // Store the existing item data
  bool isReadOnly = true; // Controls whether the form is read-only
  bool isEditing = false; // Tracks if the user is in edit mode

  String selectedGstLabel = "None";
  double selectedGstValue = 0.0;
  final Map<String, double> gstOptions = {
    "Exempted": 0.0,
    "GST@0%": 0.0,
    "IGST@0%": 0.0,
    "GST@0.25%": 0.25,
    "IGST@0.25%": 0.25,
    "GST@3%": 3.0,
    "IGST@3%": 3.0,
    "GST@5%": 5.0,
    "IGST@5%": 5.0,
    "GST@12%": 12.0,
    "IGST@12%": 12.0,
    "GST@18%": 18.0,
    "IGST@18%": 18.0,
    "GST@28%": 28.0,
    "IGST@28%": 28.0,
  };

  // Controllers for TextFields
  TextEditingController itemNameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController discountAmountController = TextEditingController();
  TextEditingController gstAmountController = TextEditingController();
  TextEditingController totalAmountController = TextEditingController();

  _AddItemsToSaleState({required String title, this.existingItem}) {
    this.title = title;
  }

  @override
  void initState() {
    super.initState();

    // Pre-fill the fields if existingItem is provided
    if (existingItem != null) {
      itemNameController.text = existingItem!["itemName"];
      quantityController.text = existingItem!["quantity"].toString(); // Convert to string for display
      rateController.text = existingItem!["rate"].toString(); // Convert to string for display
      discountController.text = existingItem!["discount"].toString(); // Convert to string for display
      selectedUnit = existingItem!["unit"];
      taxOption = existingItem!["taxOption"];
      selectedGstLabel = existingItem!["tax"];
      selectedGstValue = existingItem!["taxValue"] ?? 0.0;

      // Calculate and set the total amount
      _calculateTotalAmount();
    }

    // If editing, set isReadOnly to true initially
    if (existingItem != null) {
      isReadOnly = true;
    } else {
      isReadOnly = false; // Allow editing for new items
    }

    // Add listeners to controllers to recalculate total when values change
    quantityController.addListener(_calculateTotalAmount);
    rateController.addListener(_calculateTotalAmount);
    discountController.addListener(_calculateTotalAmount);
  }

  @override
  void dispose() {
    // Clean up controllers
    quantityController.removeListener(_calculateTotalAmount);
    rateController.removeListener(_calculateTotalAmount);
    discountController.removeListener(_calculateTotalAmount);
    quantityController.dispose();
    rateController.dispose();
    discountController.dispose();
    discountAmountController.dispose();
    gstAmountController.dispose();
    totalAmountController.dispose();
    super.dispose();
  }

  void _showGstBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tax %",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: gstOptions.length,
                  itemBuilder: (context, index) {
                    final key = gstOptions.keys.elementAt(index);
                    final value = gstOptions[key]!;
                    return ListTile(
                      title: Text(key),
                      trailing: Text("${value.toStringAsFixed(1)}%"),
                      onTap: () {
                        setState(() {
                          selectedGstLabel = key;
                          selectedGstValue = value;
                        });
                        Navigator.pop(context);
                        _calculateTotalAmount(); // Recalculate total when GST changes
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to calculate subtotal
  double calculateSubtotal() {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;
    double rate = double.tryParse(rateController.text) ?? 0.0;
    return quantity * rate; // Return subtotal as double
  }

  // Function to calculate total amount
  void _calculateTotalAmount() {
    double quantity = double.tryParse(quantityController.text) ?? 0.0;
    double rate = double.tryParse(rateController.text) ?? 0.0;
    double subtotal = quantity * rate; // Calculate subtotal
    double discountPercentage = double.tryParse(discountController.text) ?? 0.0;
    double discountAmount = (subtotal * discountPercentage) / 100;
    double gstAmount = (subtotal - discountAmount) * (selectedGstValue / 100);
    double totalAmount = subtotal - discountAmount + gstAmount;

    setState(() {
      discountAmountController.text = discountAmount.toStringAsFixed(2);
      gstAmountController.text = gstAmount.toStringAsFixed(2);
      totalAmountController.text = totalAmount.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          title!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        bottom: Prefered_underline_appbar(),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                      labelText: "Item Name",
                      hintText: "e.g. Chocolate Cake",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    readOnly: isReadOnly, // Set read-only state
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Quantity",
                            hintText: "Quantity",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          readOnly: isReadOnly, // Set read-only state
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedUnit,
                          items: [
                            DropdownMenuItem(child: Text('Kilogram'), value: 'Kilogram'),
                            DropdownMenuItem(child: Text('Liter'), value: 'Liter'),
                            DropdownMenuItem(child: Text('Gram'), value: 'Gram'),
                            DropdownMenuItem(child: Text('Piece'), value: 'Piece'),
                            DropdownMenuItem(child: Text('Packet'), value: 'Packet'),
                          ],
                          onChanged: isReadOnly
                              ? null // Disable dropdown if read-only
                              : (String? newValue) {
                            setState(() {
                              selectedUnit = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Unit",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rateController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Rate (Price/Unit)",
                            hintText: "Rate (Price/Unit)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                          readOnly: isReadOnly, // Set read-only state
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: taxOption,
                          items: [
                            DropdownMenuItem(child: Text('Without Tax'), value: 'Without Tax'),
                            DropdownMenuItem(child: Text('With Tax'), value: 'With Tax'),
                          ],
                          onChanged: isReadOnly
                              ? null // Disable dropdown if read-only
                              : (String? newValue) {
                            setState(() {
                              taxOption = newValue;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Tax Option",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Totals & Taxes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 20),
                  Divider(),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(flex: 2, child: Text("Subtotal (Rate x Qty)")),
                          Icon(Icons.currency_rupee, size: 15),
                          SizedBox(width: 50),
                          Text(calculateSubtotal().toStringAsFixed(2)),
                        ],
                      ),
                      SizedBox(height: 10,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: Text("Discount", style: TextStyle(fontSize: 16))),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orangeAccent, width: 1),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: discountController,
                                    onChanged: (String value) {
                                      _calculateTotalAmount();
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontSize: 14),
                                    readOnly: isReadOnly, // Set read-only state
                                  ),
                                ),
                              ),
                              Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.orangeAccent, width: 1),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                ),
                                child: Text("%", style: TextStyle(color: Colors.orangeAccent, fontSize: 16)),
                              ),
                            ],
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                ),
                                child: Text("₹", style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ),
                              Container(
                                height: 40,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: discountAmountController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: "0.00",
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 1, child: Text("Tax %", style: TextStyle(fontSize: 16))),
                          GestureDetector(
                            onTap: () => _showGstBottomSheet(context),
                            child: Container(
                              height: 40,
                              width: 130,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey, width: 1),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(selectedGstLabel, style: TextStyle(fontSize: 14, color: Colors.black)),
                                    Icon(Icons.arrow_drop_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(4), bottomLeft: Radius.circular(4)),
                                ),
                                child: Text("₹", style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ),
                              Container(
                                height: 40,
                                width: 90,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextField(
                                    controller: gstAmountController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: "0.00",
                                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                      border: InputBorder.none,
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text("Total Amount", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ),
                          Icon(Icons.currency_rupee, size: 17),
                          SizedBox(width: 50),
                          Text(totalAmountController.text, style: TextStyle(fontSize: 17)),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 130),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cancel Button (Visible in edit mode)
                    if (existingItem != null && !isEditing)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Cancel and go back
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            backgroundColor: Colors.grey.shade200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Cancel", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    SizedBox(width: 10),

                    // Edit Button (Visible in edit mode when not editing)
                    if (existingItem != null && !isEditing)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isReadOnly = false; // Enable editing
                              isEditing = true; // Enter edit mode
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Edit",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),

                    // Save Button (Visible when editing or adding a new item)
                    if (isEditing || existingItem == null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Create updated item data
                            Map<String, dynamic> updatedItem = {
                              "itemName": itemNameController.text,
                              "quantity": double.tryParse(quantityController.text) ?? 0.0, // Convert to double
                              "unit": selectedUnit,
                              "rate": double.tryParse(rateController.text) ?? 0.0, // Convert to double
                              "discount": double.tryParse(discountController.text) ?? 0.0, // Convert to double
                              "tax": selectedGstLabel,
                              "taxValue": selectedGstValue, // Already a double
                              "subtotal": calculateSubtotal(), // Already a double
                              "totalAmount": double.tryParse(totalAmountController.text) ?? 0.0, // Convert to double
                            };

                            // Return the updated item data
                            Navigator.pop(context, updatedItem);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
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