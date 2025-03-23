import 'package:flutter/material.dart';
import 'package:google_signup/Dashboard/Item/Add_Items_to_Unit.dart';
import 'package:remixicon/remixicon.dart';

import 'Set_Conversion.dart';

class Items extends StatefulWidget {
  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<Items> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Items', style: TextStyle(fontWeight:FontWeight.w500)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: (){},
              icon: Icon(Remix.settings_2_line),
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(Remix.filter_2_line),
          ),
          IconButton(
            onPressed: (){},
            icon: Icon(Remix.more_2_line),
          ),
        ],
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
              insets: EdgeInsets.symmetric(horizontal: 70.0), // Width of the indicator
            ),
            labelStyle: TextStyle(fontSize: 12.0), // Font size for selected tab
            unselectedLabelStyle: TextStyle(fontSize: 12.0),
            labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
            tabs: [
              Tab(text: 'PRODUCTS'),
              Tab(text: 'SERVICES'),
              Tab(text: 'CATEGORIES'),
              Tab(text: 'UNITS'),
            ],
          ),
          const SizedBox(height: 10),

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
                          Expanded(
                            child: ListView.separated(
                              itemCount: 2,
                              separatorBuilder: (context,index){
                                return Divider(color: Colors.grey.shade400,thickness: 1,);
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
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
                                                  Text("Coffee ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                  Text("(3868768)",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),),
                                                ],
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'GROCERY',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(onPressed: (){}, icon: Icon(Remix.share_forward_fill,color: Colors.grey,))
                                        ],
                                      ),
                                      SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Sale Price",style: TextStyle(fontSize: 15,color: Colors.grey),),
                                              Text("₹ 500.00",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                            ],
                                          ),

                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Purchase Price",style: TextStyle(fontSize: 15,color: Colors.grey),),
                                              Text("₹ 500.00",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                            ],
                                          ),


                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("In stock",style: TextStyle(fontSize: 15,color: Colors.grey),),
                                              Text("3",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Color(0xFF38C782)),),
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

                // SERVICES Tab
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
                                  hintText: 'Search Services by Name or Code',
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
                          Expanded(
                            child: ListView.separated(
                              itemCount: 2,
                              separatorBuilder: (context,index){
                                return Divider(color: Colors.grey.shade400,thickness: 1,);
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
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
                                                  Text("Coffee ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                                  Text("DHD",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),),
                                                ],
                                              ),
                                              SizedBox(height: 5,),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade300,
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'GROCERY',
                                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Sale Price",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey),),
                                                  Text("₹ 500 ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                                ],
                                              ),
                                              IconButton(onPressed: (){}, icon: Icon(Remix.share_forward_fill,color: Colors.grey,))
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
                                  "Add Services",
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
                              itemCount: 2,
                              separatorBuilder: (context,index){
                                return Divider(color: Colors.grey.shade400,thickness: 1,);
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 8,horizontal: 16),
                                  color: Colors.white,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Grocery"),
                                      Text("2"),
                                    ],
                                  )
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

                // UNITS Tab
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Set_Conversion()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade50
                                      ),
                                      child: Text("Set Conversion",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueAccent),)
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: ElevatedButton(
                                      onPressed: (){
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Items_To_Unit()));
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue.shade50
                                      ),
                                      child: Text("Unit to Items",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blueAccent),)
                                  ),
                                )
                              ]
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              itemCount: 3,
                              separatorBuilder: (context,index){
                                return Divider(color: Colors.grey.shade400,thickness: 1,);
                              },
                              itemBuilder: (context, index) {
                                return Container(
                                    color: Colors.white,
                                    child: ListTile(
                                      dense: true,
                                      contentPadding: EdgeInsets.only(left: 16),
                                      visualDensity: VisualDensity(vertical: -4),
                                      title: Text("Bags"),
                                      subtitle: Text("Bag"),
                                      trailing: IconButton(onPressed: (){}, icon: Icon(Remix.pencil_line)),
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
                                  "Add Unit",
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
