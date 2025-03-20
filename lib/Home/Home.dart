import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
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
class PartyDetailsTab extends StatelessWidget {
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
                        icon: FlutterRemix.account_box_line,
                        label: "Import Party",
                        backgroundColor: Colors.lightBlue,
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Import_Party()));
                        },
                      ),

                      //party statement
                      QuickLink(
                        backgroundColor: Colors.lightBlue,
                        icon: FlutterRemix.contacts_line,
                        label: "Party Statement",
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>Party_Statement()));
                        },
                      ),

                      //show All
                      QuickLink(
                        backgroundColor: Colors.lightBlue,
                        icon: FlutterRemix.building_4_line,
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
              child:  Stack(
                children:[
                  ListView.builder(
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)
                      ),
                      child: ListTile(
                        title: Text("Mohit",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w400,color: Colors.black),),
                        subtitle: Text("22 jan 25",style: TextStyle(fontSize: 12,color: Colors.grey),),
                        trailing: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            children: [
                              Text("#200",style: TextStyle(fontSize: 13,color: Colors.greenAccent),),
                              Text("you'll get",style: TextStyle(fontSize: 13,color: Colors.greenAccent),),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.all(14),
                          backgroundColor: Colors.red,
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(15),
                          // ),
                        ),
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context)=>Add_new_Party()));
                        },
                        child: SizedBox(
                          width: 130,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FlutterRemix.user_3_line,color: Colors.white,size: 20,),
                              const SizedBox(width: 8),
                              Text(
                                "Add New Party",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
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
    );
  }
}

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

      
