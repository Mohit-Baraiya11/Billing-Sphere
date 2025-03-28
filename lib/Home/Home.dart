import 'package:billing_sphere/Home/Party%20Details/Party_DetailsTab.dart';
import 'package:billing_sphere/Home/Transaction%20Details/TransactionDetailsTab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();
  int selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    _pageController.animateToPage(index,
        duration: Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: Column(
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabTapped(0),
                        child: Container(
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedIndex == 0
                                ? Color(0xFFFADBD8)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: selectedIndex==0?Color(0xFFC41E3A):Colors.grey),
                          ),
                          child: Text(
                            "Transaction Details",
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedIndex == 0 ? Color(0xFFC41E3A) : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabTapped(1),
                        child: Container(
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selectedIndex == 1
                                ? Color(0xFFFADBD8) // Selected color
                                : Colors.white, // Unselected color
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: selectedIndex==1?Color(0xFFC41E3A):Colors.grey),
                          ),
                          child: Text(
                            "Party Details",
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedIndex == 1
                                  ? Color(0xFFC41E3A) // Selected text color
                                  : Colors.black, // Unselected text color
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
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          children: [
            TransactionDetailsTab(),
            PartyDetailsTab(),
          ],
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

      
