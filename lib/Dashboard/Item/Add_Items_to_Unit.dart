import 'package:billing_sphere/Home/Prefered_underline_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Add_Items_To_Unit extends StatefulWidget {
  const Add_Items_To_Unit({super.key});
  @override
  State<Add_Items_To_Unit> createState() => _Add_Items_To_UnitState();
}

class _Add_Items_To_UnitState extends State<Add_Items_To_Unit> {
  final List<Map<String, dynamic>> _items = [
    {'name': 'Cofee', 'selected': false},
    {'name': 'Maggie', 'selected': false},
    {'name': 'Patato', 'selected': false},
    {'name': 'Rice (3568...)', 'selected': false},
  ];

  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = _items
        .where((item) => item['name'].toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Items to Unit"),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Column(
              children: [

                SizedBox(height: MediaQuery.of(context).size.height*0.010),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search Items by Name or Code",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),

                // Items List
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        title: Text(filteredItems[index]['name']),
                        value: filteredItems[index]['selected'],
                        onChanged: (bool? value) {
                          setState(() {
                            filteredItems[index]['selected'] = value!;
                            _items[_items.indexWhere((item) => item['name'] == filteredItems[index]['name'])]
                            ['selected'] = value;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Bottom Buttons
              ],
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children:[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        onPressed: () {

                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Cencle",
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10,),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () {
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Next",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                            ),
                          ],
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