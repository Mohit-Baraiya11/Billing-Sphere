import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:google_signup/Home/Party%20Details/Party_DetailsTab.dart';
import 'package:google_signup/Home/Party%20Details/all_parties_report.dart';
import 'package:google_signup/Home/Transaction%20Details/TransactionDetailsTab.dart';
import 'Party Details/Add_new_party.dart';
import 'Party Details/Import_Party.dart';
import 'Party Details/Party_Statement.dart';



class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea( // Wrap with SafeArea to handle status bar
      child: DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          backgroundColor: Colors.white, // White background to match the design
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: TabBar(
              labelColor: Color(0xFFC41E3A),
              unselectedLabelColor: Colors.black,
              indicator: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Color(0xFFC41E3A)), // Red border
              ),
              indicatorPadding: EdgeInsets.symmetric(vertical: 8.0,), // Align the indicator vertically
              overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove ripple effect
              tabs: [
                Tab(
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      child:Text(
                          "Transaction Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ),
                Tab(
                  child: Expanded(
                    child: Container(
                      width: double.infinity,
                      child: Text(
                          "Party Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14,),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              TransactionDetailsTab(),
              PartyDetailsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

const default_color = Color(0xFFACC7DFFF);














// var iconOf_party_detail_show_all = [
//   FlutterRemix.building_4_line,
// ];
// var labelOf_iconOf_party_detail_show_all = [
//   "All Parties Report",
// ];

class QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  static const default_color = Color(0xFFACC7DFFF);
  const QuickLink({
    Key? key,
    required this.icon,
    required this.label,
    this.backgroundColor = default_color,
    this.iconColor = Colors.white,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 75, // Fix item height to a consistent value
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 40,
                ),
                Positioned(
                  top: -2,
                  child: Icon(
                    icon,
                    size: 30,
                  ),
                ),
                Positioned(
                  top: 25,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 12,),
            ),
          ],
        ),
      ),
    );
  }
}






// class QuickLink extends StatelessWidget {
//   final IconData icon;
//   final String label;
//
//   QuickLink({required this.icon, required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         CircleAvatar(
//           backgroundColor: Colors.blue.shade100,
//           child: Icon(icon, color: Colors.blue),
//         ),
//         SizedBox(height: 5),
//         Text(
//           label,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12),
//         ),
//       ],
//     );
//   }
// }

      
