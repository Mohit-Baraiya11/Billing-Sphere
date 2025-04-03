import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class All_Parties_Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AllPartiesReportState();
}

class _AllPartiesReportState extends State<All_Parties_Report> {
  bool showZeroBalance = true;
  String selectedSortBy = "Name";
  String selectedShowOption = "All parties";
  String dateFilter = "31/01/2025";

  final List<String> sortByOptions = ["Name", "Balance"];
  final List<String> showOptions = ["All parties", "Specific party"];

  // Add these variables for Firebase data
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _parties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadParties();
  }

  Future<void> _loadParties() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await _databaseRef.child('users/${user.uid}/Parties').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _parties = data.entries.map((entry) {
            // Debug print to see the actual data structure
            print('Party data: ${entry.key} - ${entry.value}');

            // Handle different possible field names
            dynamic amount = entry.value['total amount'] ??
                entry.value['total_amount'] ??
                entry.value['totalAmount'] ??
                0.0;

            return {
              'id': entry.key,
              'name': entry.value['name'] ?? 'No Name',
              'phone': entry.value['phone'] ?? '',
              'total_amount': amount,
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _parties = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading parties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Color(0xFF0078AA),
        backgroundColor: Color(0xFF0078AA),
        title: Text(
          "Party Report",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSortBy,
                      decoration: const InputDecoration(
                        labelText: "Sort by",
                        labelStyle: TextStyle(color: Color(0xFF0078AA)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: sortByOptions
                          .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSortBy = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

              // Table Header (unchanged)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Party name",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Balance",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Updated Party Data List with Firebase data
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _parties.isEmpty
                    ? Center(child: Text("No parties found"))
                    : ListView.builder(
                  itemCount: _parties.length,
                  itemBuilder: (context, index) {
                    final party = _parties[index];
                    final balance = double.tryParse(party['total_amount'].toString()) ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              party['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "₹ ${balance.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: balance > 0
                                      ? Color(0xFF38C782)
                                      : Color(0xFFE03537),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}