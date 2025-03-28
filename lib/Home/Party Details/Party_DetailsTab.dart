
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_signup/Home/Party%20Details/Add_new_party.dart';
import 'package:google_signup/Home/Party%20Details/Import_Party.dart';
import 'package:google_signup/Home/Party%20Details/Party_Statement.dart';
import 'package:remixicon/remixicon.dart';

import '../Home.dart';
import 'all_parties_report.dart';

class PartyDetailsTab extends StatefulWidget {
  const PartyDetailsTab({super.key});

  @override
  State<PartyDetailsTab> createState() => _PartyDetailsTab();
}

class _PartyDetailsTab extends State<PartyDetailsTab> {

  List<Map<String, dynamic>> partyList = [];

  bool isLoading = true; // Track loading state

  void fetchPartiesData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Parties");
    DatabaseEvent event = await ref.once();

    List<Map<String, dynamic>> fetchedParties = [];

    if (event.snapshot.value != null && event.snapshot.value is Map) {
      Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        String latestDate = "No Date";
        double totalAmount = double.tryParse(value['total_amount'].toString()) ?? 0.0;

        // Check if transactions exist and find latest transaction date
        if (value.containsKey("transactions") && value["transactions"] is Map) {
          Map<dynamic, dynamic> transactions = value["transactions"];
          int latestTime = 0;

          transactions.forEach((txnKey, txnValue) {
            if (txnValue is Map && txnValue.containsKey("current_time")) {
              int txnTime = txnValue['current_time'] ?? 0;
              String txnDate = txnValue['date'] ?? "No Date";

              // Find the latest transaction
              if (txnTime > latestTime) {
                latestTime = txnTime;
                latestDate = txnDate;
              }
            }
          });
        }

        fetchedParties.add({
          "name": value['name'] ?? "Unknown",
          "date": latestDate, // Latest transaction date
          "total_amount": totalAmount,
        });
      });
    }

    setState(() {
      partyList = fetchedParties;
      isLoading = false; // Stop loading
    });
  }

  @override
  void initState() {
    super.initState();
    fetchPartiesData();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0)
              ),
              padding:EdgeInsets.only(top: 4.0,bottom: 4.0),
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 35,bottom: 7),
                      child: Text(
                        "Quick Links",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //import party
                      QuickLink(
                        icon: Remix.account_box_line,
                        label: "Import Party",
                        backgroundColor: Colors.lightBlue,
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Import_Party()));
                        },
                      ),

                      //party statement
                      QuickLink(
                        backgroundColor: Colors.lightBlue,
                        icon: Remix.contacts_line,
                        label: "Party Statement",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Party_Statement()));
                        },
                      ),

                      //show All
                      QuickLink(
                          backgroundColor: Colors.lightBlue,
                          icon: Remix.building_4_line,
                          label: "All Parties Report",
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>All_Parties_Report()));
                          }
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: Stack(
                children: [
                  isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.black, // Black loading indicator
                    ),
                  )
                      : ListView.builder(
                    itemCount: partyList.length,
                    itemBuilder: (context, index) {
                      var party = partyList[index];
                      bool isPositive = party["total_amount"] >= 0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(
                            party["name"],
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.black),
                          ),
                          subtitle: Text(
                            party["date"],
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          trailing: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              children: [
                                Text(
                                  "₹ ${party["total_amount"].toStringAsFixed(2)}",
                                  style: TextStyle(fontSize: 13, color: isPositive ? Color(0xFF38C782) : Color(0xFFE03537)),
                                ),
                                Text(
                                  isPositive ? "You'll get" : "You'll give",
                                  style: TextStyle(fontSize: 13, color: isPositive ? Color(0xFF38C782) : Color(0xFFE03537)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}