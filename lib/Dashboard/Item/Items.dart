import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_signup/Dashboard/Item/Add_Items_to_Unit.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';
import 'package:remixicon/remixicon.dart';

import 'Set_Conversion.dart';

class Items extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<Items> with SingleTickerProviderStateMixin {

  late TabController _tabController;


  List<Map<String, dynamic>> itemList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    fetchItems();
    fetchCategoriesAndItems();
  }

  void fetchItems() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child("users/$userId/Items");

    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map<dynamic, dynamic>) {
        print("No items found or data is in an incorrect format");
        setState(() {
          itemList = []; // Ensure list is empty if no data
        });
        return;
      }

      List<Map<String, dynamic>> tempList = [];

      data.forEach((key, value) {
        try {
          tempList.add({
            "id": key,
            "name": value["basicInfo"]["itemName"] ?? "No Name",
            "code": value["basicInfo"]["itemCode"] ?? "No Code",
            "category": value["basicInfo"]["category"]["name"] ?? "No Category",
            "salePrice": value["pricing"]["salePrice"] ?? 0,
            "purchasePrice": value["pricing"]["purchasePrice"] ?? 0,
            "stock": value["stock"]["openingStock"] ?? 0,
          });
        } catch (e) {
          print("Error parsing item: $e");
        }
      });

      setState(() {
        itemList = tempList;
      });
    }, onError: (error) {
      print("Firebase Error: $error");
    });
  }

  List<Map<String, dynamic>> categoriesList = [];
  void fetchCategoriesAndItems() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    final DatabaseReference categoriesRef =
    FirebaseDatabase.instance.ref().child("users/$userId/Categories");
    final DatabaseReference itemsRef =
    FirebaseDatabase.instance.ref().child("users/$userId/Items");

    categoriesRef.onValue.listen((categoriesEvent) {
      final categoriesData = categoriesEvent.snapshot.value as Map<dynamic, dynamic>?;

      if (categoriesData == null) {
        print("No categories found");
        setState(() {
          categoriesList = [];
        });
        return;
      }

      print("Categories Fetched: $categoriesData");

      // Store categories in a map
      Map<String, String> categoriesMap = {};
      categoriesData.forEach((key, value) {
        categoriesMap[key] = value["name"] ?? "Unnamed";
      });

      print("Parsed Categories: $categoriesMap");

      // Fetch items to count category occurrences
      itemsRef.once().then((itemsEvent) {
        final itemsData = itemsEvent.snapshot.value as Map<dynamic, dynamic>?;

        Map<String, int> categoryItemCount = {};
        if (itemsData != null) {
          print("Items Fetched: $itemsData");

          itemsData.forEach((key, value) {
            if (value["basicInfo"] != null && value["basicInfo"]["category"] != null) {
              String categoryId = value["basicInfo"]["category"]["id"] ?? "";
              if (categoryId.isNotEmpty) {
                categoryItemCount[categoryId] = (categoryItemCount[categoryId] ?? 0) + 1;
              }
            }
          });
        }

        print("Category Item Counts: $categoryItemCount");

        // Prepare final list
        List<Map<String, dynamic>> tempList = [];
        categoriesMap.forEach((key, name) {
          tempList.add({
            "id": key,
            "name": name,
            "count": categoryItemCount[key] ?? 0,
          });
        });

        print("Final Category List: $tempList");

        setState(() {
          categoriesList = tempList;
        });
      });
    });
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
        title:  Text('Items', style: TextStyle(fontWeight:FontWeight.w500)),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: DefaultTabController(
      length: 4, // Number of tabs
      initialIndex: 0, // Default to 'PRODUCTS'
      child: Column(
        children: [
          // Tab Bar inside body
          const TabBar(
            labelColor: Colors.red,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.red,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3.0, // Indicator thickness
                color: Colors.red,
              ),
              insets: EdgeInsets.symmetric(horizontal: 120),
            ),
            labelStyle: TextStyle(fontSize: 12.0),
            unselectedLabelStyle: TextStyle(fontSize: 12.0),
            labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
            tabs: [
              Tab(text: 'PRODUCTS'),
              Tab(text: 'CATEGORIES'),
            ],
          ),
          SizedBox(height: 10),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              children: [
                // PRODUCTS Tab
                Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search Items by Name or Code',
                                prefixIcon: Icon(Remix.search_2_line, color: Colors.blueAccent),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: itemList.isEmpty
                                ? const Center(child: CircularProgressIndicator())
                                : ListView.separated(
                              itemCount: itemList.length,
                              separatorBuilder: (context, index) {
                                return Divider(color: Colors.grey.shade400, thickness: 1);
                              },
                              itemBuilder: (context, index) {
                                var item = itemList[index];
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(item["name"], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                  Text(" (${item["code"]})", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
                                                child: Text(item["category"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          ),
                                          IconButton(onPressed: () {}, icon: Icon(Remix.share_forward_fill, color: Colors.grey))
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Sale Price", style: TextStyle(fontSize: 15, color: Colors.grey)),
                                              Text("₹ ${item["salePrice"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Purchase Price", style: TextStyle(fontSize: 15, color: Colors.grey)),
                                              Text("₹ ${item["purchasePrice"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("In stock", style: TextStyle(fontSize: 15, color: Colors.grey)),
                                              Text("${item["stock"]}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF38C782))),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.all(14),
                              backgroundColor: Color(0xFFE03537),
                            ),
                            onPressed: () {
                            },
                            child:Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Remix.add_circle_fill,color: Colors.white,size: 20,),
                                SizedBox(width: 10),
                                Text(
                                  "Add Product",
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

                // CATEGORIES Tab
                Container(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 55,
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: TextField(
                              decoration: InputDecoration(
                                  hintText: 'Search Category',
                                  hintStyle: TextStyle(color: Colors.grey,fontSize: 16),
                                  prefixIcon: Icon(Remix.search_2_line, color: Colors.blueAccent),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:  BorderSide(color: Colors.grey,width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:  BorderSide(color: Colors.grey,width: 1),
                                  )
                              ),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Container(
                            color: Colors.grey.shade200,
                            padding: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Category Name"),
                                Text("Item Count"),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: categoriesList.length,
                              separatorBuilder: (context, index) {
                                return Divider(color: Colors.grey.shade400, thickness: 1);
                              },
                              itemBuilder: (context, index) {
                                final category = categoriesList[index];
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(category["name"] ?? "No Name"),
                                      Text(category["count"].toString()),
                                    ],
                                  ),
                                );
                              },
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
                            },
                            child:Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Remix.add_circle_fill,color: Colors.white,size: 20,),
                                SizedBox(width: 10),
                                Text(
                                  "Add Category",
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

              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
