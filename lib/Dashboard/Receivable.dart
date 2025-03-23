import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remixicon/remixicon.dart';

class Receivable extends StatefulWidget {
  const Receivable({super.key});

  @override
  State<Receivable> createState() => _ReceivableState();
}

class _ReceivableState extends State<Receivable> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> receivables = [];
  List<Map<String, dynamic>> filteredReceivables = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReceivables();
  }

  void fetchReceivables() {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;

    _dbRef.child("users/$userId/Parties").onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        List<Map<String, dynamic>> tempList = [];
        data.forEach((key, value) {
          double totalAmount = double.tryParse(value['total_amount'].toString()) ?? 0;
          if (totalAmount < 0) {
            tempList.add({
              "name": value['name'] ?? "Unknown",
              "phone": value['phone'] ?? "N/A",
              "amount": totalAmount.abs(),
            });
          }
        });

        setState(() {
          receivables = tempList;
          filteredReceivables = List.from(receivables);
        });
      }
    });
  }

  void filterSearch(String query) {
    List<Map<String, dynamic>> tempSearchList = [];
    if (query.isNotEmpty) {
      tempSearchList = receivables.where((party) {
        return party["name"].toLowerCase().contains(query.toLowerCase()) ||
            party["phone"].contains(query);
      }).toList();
    } else {
      tempSearchList = List.from(receivables);
    }

    setState(() {
      filteredReceivables = tempSearchList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Receivable", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 20)),
        backgroundColor: const Color(0xFF0078AA),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Remix.notification_4_line, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Remix.more_2_line, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.grey.shade200,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
              child: TextField(
                controller: searchController,
                onChanged: filterSearch,
                decoration: InputDecoration(
                  hintText: "Search for Name / No.",
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          // Table Header
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            color: Colors.blue.shade50,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Party Name", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Amount", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // List of Receivables
          Expanded(
            child: filteredReceivables.isEmpty
                ? const Center(child: Text("No receivables found", style: TextStyle(fontSize: 16, color: Colors.grey)))
                : ListView.builder(
              itemCount: filteredReceivables.length,
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        filteredReceivables[index]['name'],
                        style: const TextStyle(fontSize: 15),
                      ),
                      Text(
                        "₹ ${filteredReceivables[index]['amount']}",
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
