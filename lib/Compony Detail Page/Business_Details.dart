
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

import '../Home/BottomNavbar_save_buttons.dart';
import '../Home/Prefered_underline_appbar.dart';

class Business_Details extends StatefulWidget
{
  @override
  State<StatefulWidget> createState()=>BusinessDetails();
}
class BusinessDetails extends State<Business_Details>
{
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  final List<String> imagePaths = [
    "Assets/Images/banking.png",
    "Assets/Images/banking.png",
    "Assets/Images/banking.png",
  ];



  TextEditingController enteredText = TextEditingController();
  String _selectedOption = 'To Receive';
  String selectedOption = "Unregistered/Consumer";


  String selectedState = "State";
  void _showStateSelectionBottomSheet(BuildContext context) {
    final List<String> statesOfIndia = [
      "Andhra Pradesh",
      "Arunachal Pradesh",
      "Assam",
      "Bihar",
      "Chhattisgarh",
      "Goa",
      "Gujarat",
      "Haryana",
      "Himachal Pradesh",
      "Jharkhand",
      "Karnataka",
      "Kerala",
      "Madhya Pradesh",
      "Maharashtra",
      "Manipur",
      "Meghalaya",
      "Mizoram",
      "Nagaland",
      "Odisha",
      "Punjab",
      "Rajasthan",
      "Sikkim",
      "Tamil Nadu",
      "Telangana",
      "Tripura",
      "Uttar Pradesh",
      "Uttarakhand",
      "West Bengal",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select State",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: statesOfIndia.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(statesOfIndia[index]),
                      onTap: () {
                        setState(() {
                          selectedState = statesOfIndia[index];
                        });
                        Navigator.pop(context); // Close the BottomSheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String selectBusiness_type = "Business Type";
  void _show_business_type(BuildContext context){
    final List<String> statesOfIndia = [
      "Retail",
      "Wholesale",
      "Distributor",
      "Service",
      "Manufacturing",
      "Others"
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Business Type",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: statesOfIndia.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(statesOfIndia[index]),
                      onTap: () {
                        setState(() {
                          selectBusiness_type = statesOfIndia[index];
                        });
                        Navigator.pop(context); // Close the BottomSheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String selectBusiness_category  = "Business Category";
  void _show_business_categoory(BuildContext context){
    final List<String> statesOfIndia = [
      "Accounting & CA",
      "Interior Designer",
      "Interior Designer",
      "Salon & Spa",
      "Liquor Store",
      "Liquor Store",
      "Construction Materials & Equipment",
      "Repairing/ Plumbing/ Electrician",
      "Chemicals & Fertilizers",
      "Computer Equipments & Softwares",
      "Electrical & Electronics Equipments",
      "Fashion Accessory/ Cosmetics",
      "Tailoring/ Boutique",
      "Fruit And Vegetable",
      "Kirana/ General Merchant",
      "FMCG Products",
      "Dairy Farm Products/ Poultry",
      "Furniture",
      "Garment/Fashion & Hosiery",
      "Jewellery & Gems",
      "Pharmacy/ Medical",
      "Hardware Store",
      "Industrial Machinery & Equipment",
      "Mobile & Accessories",
      "Nursery/ Plants",
      "Petroleum Bulk Stations & Terminals/ Petrol",
      "Restaurant/ Hotel",
      "Footwear",
      "Paper & Paper Products",
      "Sweet Shop/Bakery",
      "Gifts & Toys",
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title Row with Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Business Type",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: selectBusiness_category.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(statesOfIndia[index]),
                      onTap: () {
                        setState(() {
                          selectBusiness_category = statesOfIndia[index];
                        });
                        Navigator.pop(context); // Close the BottomSheet
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbarSaveButton(leftButtonText: 'Cencle', rightButtonText: 'save', leftButtonColor: Colors.white,rightButtonColor: Colors.red,onLeftButtonPressed: (){},onRightButtonPressed: (){},),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // Removes shadow
        bottom: Prefered_underline_appbar(),
        foregroundColor: Colors.black,
        title: Text('Business Profile', style: TextStyle(color: Colors.black)),
        actions: [
          Container(
            child: IconButton(
                onPressed: (){

                },
                icon:Icon(FlutterRemix.image_add_line)
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 250,
                color: Colors.blue[100],
                child: Stack(
                  children: [
                    SizedBox(height: 30), // Add padding from the top
                    SizedBox(
                      height: 220,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: imagePaths.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage(imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 180,
                      left: 120,
                      child:SizedBox(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: (){},
                          child: Row(
                            children: [
                              Icon(FlutterRemix.share_forward_line,color: Colors.white,),
                              SizedBox(width: 8,),
                              Text("Share Card",style: TextStyle(color: Colors.white),),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(color: Colors.red, width: 3.0), // Thickness of the underline
                          insets: EdgeInsets.symmetric(horizontal: -50.0), // Extend the width of the indicator
                        ),
                        indicatorColor: Colors.red,
                        indicatorWeight: 2.0,
                        labelColor: Colors.red,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        tabs: [
                          Tab(text: 'Basic Details'),
                          Tab(text: 'Business Details'),
                        ],
                      ),
                      Container(
                        height: 650, // Specify a height for TabBarView
                        child: TabBarView(
                          children: [
                            Center(
                              child:Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Business Name",
                                        hintText: "Compony Name",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "GSTIN",
                                        hintText: "GSTIN",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),

                                    Row(
                                      children: [
                                        SizedBox(width: 205,),
                                        Text("Show on card",style: TextStyle(fontSize: 12),),
                                        Transform.scale(
                                          scale: 0.7, // Adjust size
                                          child: Theme(
                                            data: ThemeData(
                                              switchTheme: SwitchThemeData(
                                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent), // Remove border
                                              ),
                                            ),
                                            child: Switch(
                                              value: false,
                                              onChanged: (value) {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Phone Number 1",
                                        hintText: "Phone Number 1",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),

                                    //second phone number
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Phone Number 2",
                                        hintText: "Phone Number 2",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),

                                    //email
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        hintText: "Email",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),


                                    //business Address
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Business Address",
                                        hintText: "Business Address",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),

                                    //Pincode
                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Pincode",
                                        hintText: "Pincode",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 16),
                                    TextField(
                                      decoration: InputDecoration(
                                        labelText: "Business Description",
                                        hintText: "Business Description",
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.blue, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Center(
                              child:Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true, // Prevent keyboard from opening
                                      controller: TextEditingController(text: selectedState),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(FlutterRemix.arrow_down_s_line,color: Colors.blueAccent,),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _showStateSelectionBottomSheet(context);
                                      },
                                    ),

                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true, // Prevent keyboard from opening
                                      controller: TextEditingController(text: selectBusiness_type),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(FlutterRemix.arrow_down_s_line,color: Colors.blueAccent,),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _show_business_type(context);
                                      },
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 205,),
                                        Text("Show on card",style: TextStyle(fontSize: 12),),
                                        Transform.scale(
                                          scale: 0.7, // Adjust size
                                          child: Theme(
                                            data: ThemeData(
                                              switchTheme: SwitchThemeData(
                                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent), // Remove border
                                              ),
                                            ),
                                            child: Switch(
                                              value: false,
                                              onChanged: (value) {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),

                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true, // Prevent keyboard from opening
                                      controller: TextEditingController(text: selectBusiness_category),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(FlutterRemix.arrow_down_s_line,color: Colors.blueAccent,),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _show_business_categoory(context);
                                      },
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(width: 205,),
                                        Text("Show on card",style: TextStyle(fontSize: 12),),
                                        Transform.scale(
                                          scale: 0.7, // Adjust size
                                          child: Theme(
                                            data: ThemeData(
                                              switchTheme: SwitchThemeData(
                                                trackOutlineColor: MaterialStateProperty.all(Colors.transparent), // Remove border
                                              ),
                                            ),
                                            child: Switch(
                                              value: false,
                                              onChanged: (value) {

                                              },
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}