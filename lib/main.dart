import 'package:billing_sphere/Compony%20Detail%20Page/Business_Details.dart';
import 'package:billing_sphere/Items/Items_show.dart';
import 'package:billing_sphere/Notification/Notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:remixicon/remixicon.dart';

import 'Dashboard/Dashboard.dart';
import 'Home/Home.dart';
import 'Menu/menu.dart';
import 'Splash-Screen/Splash_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyBGS9_9XgP7xTlfgjZCvpQEx69qi-PyzsA",
      appId: "1:199968286312:android:c89754bdac7180da5c7ddd",
      messagingSenderId: "199968286312",
      projectId: "billing-sphere-5f24e",
      storageBucket: "billing-sphere-5f24e.firebasestorage.app",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int myindex = 0;

  var arrText = [
    HomePage(),
    Dashboard(),
    Items_show(),
    Menu(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: Stack(
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.white,
            onTap: (index) {
              setState(() {
                myindex = index;
              });
            },
            currentIndex: myindex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.black54,
            items: const [
              BottomNavigationBarItem(icon: Icon(FlutterRemix.home_8_line), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(FlutterRemix.dashboard_line), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Remix.box_3_line), label: 'Items'),
              BottomNavigationBarItem(icon: Icon(FlutterRemix.profile_line), label: 'Menu'),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom: 55, // Position the arrow above the icons
            left: MediaQuery.of(context).size.width / 4 * myindex +
                MediaQuery.of(context).size.width / 9 - 10,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              width: 30, // Width of the arrow base
              height: 10, // Height of the arrow tip
              child: CustomPaint(
                painter: ArrowPainter(),
              ),
            ),
          ),
        ],
      ),

      body: Center(
        child: arrText[myindex],
      ),
    );
  }
}


// Custom AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.grey.shade400,
        statusBarIconBrightness: Brightness.light, // Light icons (for dark backgrounds)
      ),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: CircleAvatar(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>Business_Details()));
          },
          child: Container(
            padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border:Border.all(width: 1,color: Colors.blue),
                borderRadius: BorderRadius.circular(90),
              ),
              child: Icon(FlutterRemix.store_2_line, color: Colors.blue,size: 18,)
          ),
        ), // Replace with your store icon
      ),
      title: const Text(
        "Mohit_Store",
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        IconButton(
          icon: const Icon(FlutterRemix.notification_3_line),
          onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context)=>Notification_page()));
          },
        ),
        Container(
          child: PopupMenuButton<String>(
            color: Colors.white,
            icon: Icon(FlutterRemix.settings_2_line), // Settings icon
            onSelected: (value) {
              if (value == "Profile") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Business_Details()),
                );
              } else if (value == "Log Out") {
                // Handle Log Out action
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "Profile",
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black), // Profile icon
                    SizedBox(width: 8),
                    Text("Profile"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "Log Out",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black), // Log Out icon
                    SizedBox(width: 8),
                    Text("Log Out"),
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}





class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top center
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}








