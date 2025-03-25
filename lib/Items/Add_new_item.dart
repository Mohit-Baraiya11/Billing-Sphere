import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/BottomNavbar_save_buttons.dart';
import '../Home/Prefered_underline_appbar.dart';

class Add_new_item extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Addnewitem();
}

class Addnewitem extends State<Add_new_item> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedTaxType = "Without Tax";
  String selectedDiscountType = "Percentage";

  TextEditingController _dateController = TextEditingController();

  TextEditingController item_name_controller = TextEditingController();
  TextEditingController item_code_controller = TextEditingController();
  TextEditingController hsn_sac_code_controller = TextEditingController();


  ///pricing
   TextEditingController sale_price_controller = TextEditingController();
   TextEditingController discount_on_sale_price_controller = TextEditingController();
   TextEditingController purchase_price_controller = TextEditingController();
   TextEditingController _taxrate = TextEditingController();


   ///Stock
  TextEditingController opening_stock = TextEditingController();
  TextEditingController at_price_unit_controller = TextEditingController();
  TextEditingController min_stock_qty_controller = TextEditingController();
  TextEditingController item_location_controller = TextEditingController();



  String? _selectedCategoryName;
  String? _selectedCategoryId;
  final TextEditingController _categoryController = TextEditingController();
  List<Map<String, dynamic>> _categories = [];
  final TextEditingController _addCategoryController = TextEditingController();

  ///ADD CATEGORY
  Future<void> _fetchCategories() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DatabaseReference categoriesRef = FirebaseDatabase.instance
          .ref("users/${user.uid}/Categories");

      DatabaseEvent event = await categoriesRef.once();

      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          _categories = [];

          // Handle both direct child nodes and nested structures
          data.forEach((categoryId, categoryData) {
            // If categoryData is a Map (direct properties)
            if (categoryData is Map) {
              _categories.add({
                'id': categoryId,
                'name': categoryData['name'] ?? 'Unnamed Category',
                'createdAt': categoryData['createAkt'] ?? 0, // Note: using createAkt instead of createdAt
              });
            }
            // If categoryData has nested structure (like in your screenshot)
            else if (categoryData is String) {
              // Handle cases where the value might be just a string
              _categories.add({
                'id': categoryId,
                'name': categoryData,
                'createdAt': DateTime.now().millisecondsSinceEpoch,
              });
            }
          });

          // Sort categories by creation time (newest first)
          _categories.sort((a, b) => (b['createdAt'] as int).compareTo(a['createdAt'] as int));
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
      // Show error to user if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load categories")),
      );
    }
  }
  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add Category", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Remix.close_line)
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 45,
                    child: TextField(
                      controller: _addCategoryController,
                      decoration: InputDecoration(
                        labelText: "Add new category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                        backgroundColor: Color(0xFFE03537),
                      ),
                      onPressed: () async {
                        if (_addCategoryController.text.isNotEmpty) {
                          await _addCategory(_addCategoryController.text);
                          _addCategoryController.clear();
                          Navigator.pop(context);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    );
  }
  Future<void> _addCategory(String categoryName) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DatabaseReference categoriesRef = FirebaseDatabase.instance
          .ref("users/${user.uid}/Categories");

      // Check if category already exists
      DatabaseEvent event = await categoriesRef
          .orderByChild('name')
          .equalTo(categoryName)
          .once();

      if (event.snapshot.value == null) {
        // Add new category
        await categoriesRef.push().set({
          'name': categoryName,
          'createdAt': ServerValue.timestamp,
        });
      }
    } catch (e) {
      print("Error adding category: $e");
      rethrow;
    }
  }



  ///Add item
  Future<void> addItemToDatabase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Validate required fields
      if (item_name_controller.text.isEmpty) {
        throw Exception("Item name is required");
      }

      // Prepare the item data map
      Map<String, dynamic> itemData = {
        'basicInfo': {
          'itemName': item_name_controller.text,
          'itemCode': item_code_controller.text,
          'category': {
            'id': _selectedCategoryId,
            'name': _selectedCategoryName,
          },
          'hsnSacCode': hsn_sac_code_controller.text,
          'createdAt': ServerValue.timestamp,
        },
        'pricing': {
          'salePrice': double.tryParse(sale_price_controller.text) ?? 0.0,
          'discount': {
            'type': selectedDiscountType,
            'value': double.tryParse(discount_on_sale_price_controller.text) ?? 0.0,
          },
          'purchasePrice': double.tryParse(purchase_price_controller.text) ?? 0.0,
          'tax': {
            'type': selectedTaxType,
            'rate': double.tryParse(_taxrate.text) ?? 0.0,
          },
        },
        'stock': {
          'openingStock': int.tryParse(opening_stock.text) ?? 0,
          'asOfDate': _dateController.text.isNotEmpty
              ? _dateController.text
              : DateTime.now().toString(),
          'pricePerUnit': double.tryParse(at_price_unit_controller.text) ?? 0.0,
          'minStockQty': int.tryParse(min_stock_qty_controller.text) ?? 0,
          'location': item_location_controller.text,
        },
      };

      // Get reference to user's items
      DatabaseReference itemsRef = FirebaseDatabase.instance
          .ref("users/${user.uid}/Items");

      // Push the new item to database
      DatabaseReference newItemRef = itemsRef.push();
      await newItemRef.set(itemData);

      // Clear all controllers after successful submission
      clearAllControllers();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item added successfully")),
      );

    } catch (e) {
      print("Error adding item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item: ${e.toString()}")),
      );
      rethrow;
    }
  }
  void clearAllControllers() {
    // Basic Info
    item_name_controller.clear();
    item_code_controller.clear();
    hsn_sac_code_controller.clear();
    _categoryController.clear();
    _selectedCategoryId = null;
    _selectedCategoryName = null;

    // Pricing
    sale_price_controller.clear();
    discount_on_sale_price_controller.clear();
    purchase_price_controller.clear();
    _taxrate.clear();
    selectedTaxType = "Without Tax";
    selectedDiscountType = "Percentage";

    // Stock
    opening_stock.clear();
    _dateController.clear();
    at_price_unit_controller.clear();
    min_stock_qty_controller.clear();
    item_location_controller.clear();

    // Update UI
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    _dateController.text = formattedDate;

    _taxrate.text = "none";

    _tabController = TabController(length: 2, vsync: this);


    _fetchCategories();

  }

  @override
  void dispose() {
    _categoryController.dispose();
    _tabController.dispose();
    item_name_controller.dispose();
    item_code_controller.dispose();
    hsn_sac_code_controller.dispose();
    _categoryController.dispose();
    _addCategoryController.dispose();
    sale_price_controller.dispose();
    discount_on_sale_price_controller.dispose();
    purchase_price_controller.dispose();
    _taxrate.dispose();
    opening_stock.dispose();
    _dateController.dispose();
    at_price_unit_controller.dispose();
    min_stock_qty_controller.dispose();
    item_location_controller.dispose();
    super.dispose();
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
        title:Text("Add Items", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      bottomNavigationBar: BottomNavbarSaveButton(
        leftButtonText: 'Cancel',
        rightButtonText: 'Save',
        leftButtonColor: Colors.white,
        rightButtonColor: Colors.red,
        onLeftButtonPressed: () {},
        onRightButtonPressed: () async{
          await addItemToDatabase();
        },
      ),
      body: Container(
        color: Colors.blue[50],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Name with Button
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.white,
                child: Column(
                  children: [
                    // Item name
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: item_name_controller,
                              decoration: InputDecoration(
                                labelText: "Item Name",
                                hintText: "Item Name",
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item code / Barcode
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: item_code_controller,
                              decoration: InputDecoration(
                                labelText: "Item Code / Barcode",
                                hintText: "Item Code / Barcode",
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Item Category
                    Padding(
                      padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: _categoryController,
                              onTap: () {
                                // Store current selection before opening modal
                                final currentCategoryId = _selectedCategoryId;

                                showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    // Create a local variable to track selection within the modal
                                    String? localSelectedCategoryId = _selectedCategoryId;
                                    String? localSelectedCategoryName = _selectedCategoryName;

                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          height: MediaQuery.of(context).size.height * 0.85,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: Colors.white,
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Select Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                        IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            icon: Icon(Icons.close)
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(color: Colors.grey.shade200, thickness: 1),
                                                  SizedBox(height: 10),

                                                  // Search field
                                                  Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    child: TextField(
                                                      decoration: InputDecoration(
                                                        prefixIcon: Icon(Remix.search_2_line, color: Colors.blueAccent),
                                                        hintText: "Search Category",
                                                        floatingLabelStyle: TextStyle(color: Colors.blue),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                                          borderRadius: BorderRadius.circular(4.0),
                                                        ),
                                                        focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                                        ),
                                                        enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(4.0),
                                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                                        ),
                                                      ),
                                                      onChanged: (value) {
                                                        // Implement search functionality if needed
                                                      },
                                                    ),
                                                  ),
                                                  Divider(color: Colors.grey.shade200, thickness: 1),

                                                  // Add New Category Tile
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _showAddCategoryDialog(context);
                                                    },
                                                    dense: true,
                                                    visualDensity: VisualDensity.compact,
                                                    title: Text("Add New Category", style: TextStyle(color: Colors.blueAccent)),
                                                    trailing: Icon(Remix.add_circle_line, color: Colors.blueAccent),
                                                  ),
                                                  Divider(color: Colors.grey.shade200, thickness: 1),

                                                  Expanded(
                                                    child: _categories.isEmpty
                                                        ? Center(child: Text("No categories found"))
                                                        : ListView.separated(
                                                      itemCount: _categories.length,
                                                      separatorBuilder: (context, index) {
                                                        return Divider(color: Colors.grey.shade200, thickness: 1);
                                                      },
                                                      itemBuilder: (context, index) {
                                                        final category = _categories[index];
                                                        return ListTile(
                                                          dense: true,
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                          visualDensity: VisualDensity.compact,
                                                          title: Text(category['name']),
                                                          trailing: Radio<String>(
                                                            activeColor: Colors.blueAccent,
                                                            value: category['id'],
                                                            groupValue: localSelectedCategoryId,
                                                            onChanged: (value) {
                                                              setModalState(() {
                                                                localSelectedCategoryId = value;
                                                                localSelectedCategoryName = category['name'];
                                                              });
                                                            },
                                                          ),
                                                          onTap: () {
                                                            setModalState(() {
                                                              localSelectedCategoryId = category['id'];
                                                              localSelectedCategoryName = category['name'];
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                bottom: 20,
                                                left: 0,
                                                right: 0,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(14),
                                                    backgroundColor: Color(0xFFE03537),
                                                  ),
                                                  onPressed: () {
                                                    if (localSelectedCategoryId != null) {
                                                      // Update the parent widget's state
                                                      setState(() {
                                                        _selectedCategoryId = localSelectedCategoryId;
                                                        _selectedCategoryName = localSelectedCategoryName;
                                                        _categoryController.text = localSelectedCategoryName!;
                                                      });
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Apply",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              decoration: InputDecoration(
                                hintText: _selectedCategoryName ?? "Item Category",
                                suffixIcon: Icon(Remix.arrow_down_s_line),
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),


                    // HSN / SAC Code
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 8.0, bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: hsn_sac_code_controller,
                              decoration: InputDecoration(
                                labelText: "HSN / SAC Code",
                                hintText: "HSN / SAC Code",
                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15),
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController, // Use the _tabController here
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(color: Colors.red, width: 3.0),
                        insets: EdgeInsets.symmetric(horizontal: -50.0),
                      ),
                      indicatorColor: Colors.red,
                      indicatorWeight: 2.0,
                      labelColor: Colors.red,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(text: 'Pricing'),
                        Tab(text: 'Stock'),
                      ],
                    ),
                    Container(
                      height: 540,
                      child: TabBarView(
                        controller: _tabController, // Use the _tabController here
                        children: [
                          // Pricing Tab
                          Center(
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Sale Price", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: sale_price_controller,
                                        decoration: InputDecoration(
                                          labelText: "Sale Price",
                                          hintText: "Sale Price",
                                          floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                      SizedBox(height: 16),
                                      TextField(
                                        controller: discount_on_sale_price_controller,
                                        decoration: InputDecoration(
                                          labelText: "Disc On Sale Price",
                                          floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                      SizedBox(height: 10),
                                      Text("+ Add Wholesale Price", style: TextStyle(color: Colors.blueAccent, fontSize: 15, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(color: Colors.blue[50], height: 10,),


                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Purchase Price", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: purchase_price_controller,
                                              decoration: InputDecoration(
                                                labelText: "Purchase Item",
                                                hintText: "Purchase Item",
                                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                                    ],
                                  ),
                                ),
                                Container(color: Colors.blue[50], height: 10,),


                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Taxes", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                      Divider(),
                                      SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: _taxrate,
                                              decoration: InputDecoration(
                                                labelText: "Tax Rate",
                                                floatingLabelStyle: TextStyle(color: Colors.blue),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Stock Tab
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: opening_stock,
                                    decoration: InputDecoration(
                                      labelText: "Opening Stock",
                                      hintText: "Ex:300",
                                      floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: _dateController,
                                          readOnly: true,
                                          keyboardType: TextInputType.datetime,
                                          decoration: InputDecoration(
                                            labelText: "As of Date",
                                            suffixIcon: Icon(FlutterRemix.calendar_2_line),
                                            floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: at_price_unit_controller,
                                          decoration: InputDecoration(
                                            labelText: "At Price/Unit",
                                            hintText: "Ex:2000",
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
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.datetime,
                                          controller: min_stock_qty_controller,
                                          decoration: InputDecoration(
                                            labelText: "Min Stock Qty",
                                            hintText: "Ex:5",
                                            floatingLabelStyle: TextStyle(color: Colors.blue),
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
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          controller: item_location_controller,
                                          decoration: InputDecoration(
                                            labelText: "Item Location",
                                            hintText: "Item Location",
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
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}