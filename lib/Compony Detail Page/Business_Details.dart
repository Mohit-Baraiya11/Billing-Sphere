import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:remixicon/remixicon.dart';

import '../Home/BottomNavbar_save_buttons.dart';
import '../Home/Prefered_underline_appbar.dart';

class Business_Details extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BusinessDetails();
}

class BusinessDetails extends State<Business_Details> {
  // Controllers for Basic Details
  TextEditingController businessNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController businessDescriptionController = TextEditingController();

  // Controllers for Business Details
  String selectedState = "State";
  String selectBusinessType = "Business Type";
  String selectBusinessCategory = "Business Category";

  bool isEditing = false; // To toggle between edit and save modes
  bool hasData = false; // To check if data exists in the database
  bool isLoading = true; // To show loading state while fetching data

  @override
  void initState() {
    super.initState();
    fetchBusinessProfile(); // Fetch data when the page loads
  }

  // Fetch business profile from Firebase Realtime Database
  Future<void> fetchBusinessProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(user.uid)
            .child('business_profile')
            .child('profile');

        DataSnapshot snapshot = await ref.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
          setState(() {
            hasData = true;
            // Populate Basic Details
            businessNameController.text = data['businessName'] ?? '';
            phoneNumberController.text = data['phoneNumber'] ?? '';
            emailController.text = data['email'] ?? '';
            businessAddressController.text = data['businessAddress'] ?? '';
            pincodeController.text = data['pincode'] ?? '';
            businessDescriptionController.text = data['businessDescription'] ?? '';
            // Populate Business Details
            selectedState = data['state'] ?? "State";
            selectBusinessType = data['businessType'] ?? "Business Type";
            selectBusinessCategory = data['businessCategory'] ?? "Business Category";
          });
        } else {
          setState(() {
            hasData = false;
            isEditing = true; // Allow editing if no data exists
          });
        }
      }
    } catch (e) {
      print("Error fetching business profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Save or update business profile to Firebase Realtime Database
  Future<void> saveBusinessProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(user.uid)
            .child('business_profile')
            .child('profile');

        await ref.set({
          'businessName': businessNameController.text,
          'phoneNumber': phoneNumberController.text,
          'email': emailController.text,
          'businessAddress': businessAddressController.text,
          'pincode': pincodeController.text,
          'businessDescription': businessDescriptionController.text,
          'state': selectedState,
          'businessType': selectBusinessType,
          'businessCategory': selectBusinessCategory,
        });

        setState(() {
          hasData = true;
          isEditing = false; // Switch back to read-only mode after saving
        });
      }
    } catch (e) {
      print("Error saving business profile: $e");
    }
  }

  // Bottom sheet for selecting state
  void _showStateSelectionBottomSheet(BuildContext context) {
    if (!isEditing) return; // Prevent interaction if not in edit mode

    final List<String> statesOfIndia = [
      "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
      "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka",
      "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur", "Meghalaya", "Mizoram",
      "Nagaland", "Odisha", "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu",
      "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal",
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
                        Navigator.pop(context);
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

  // Bottom sheet for selecting business type
  void _showBusinessType(BuildContext context) {
    if (!isEditing) return; // Prevent interaction if not in edit mode

    final List<String> businessTypes = [
      "Retail", "Wholesale", "Distributor", "Service", "Manufacturing", "Others"
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
                  itemCount: businessTypes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(businessTypes[index]),
                      onTap: () {
                        setState(() {
                          selectBusinessType = businessTypes[index];
                        });
                        Navigator.pop(context);
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

  // Bottom sheet for selecting business category
  void _showBusinessCategory(BuildContext context) {
    if (!isEditing) return; // Prevent interaction if not in edit mode

    final List<String> businessCategories = [
      "Accounting & CA", "Interior Designer", "Salon & Spa", "Liquor Store",
      "Construction Materials & Equipment", "Repairing/ Plumbing/ Electrician",
      "Chemicals & Fertilizers", "Computer Equipments & Softwares",
      "Electrical & Electronics Equipments", "Fashion Accessory/ Cosmetics",
      "Tailoring/ Boutique", "Fruit And Vegetable", "Kirana/ General Merchant",
      "FMCG Products", "Dairy Farm Products/ Poultry", "Furniture",
      "Garment/Fashion & Hosiery", "Jewellery & Gems", "Pharmacy/ Medical",
      "Hardware Store", "Industrial Machinery & Equipment", "Mobile & Accessories",
      "Nursery/ Plants", "Petroleum Bulk Stations & Terminals/ Petrol",
      "Restaurant/ Hotel", "Footwear", "Paper & Paper Products",
      "Sweet Shop/Bakery", "Gifts & Toys",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Business Category",
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
                  itemCount: businessCategories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(businessCategories[index]),
                      onTap: () {
                        setState(() {
                          selectBusinessCategory = businessCategories[index];
                        });
                        Navigator.pop(context);
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
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  // If in edit mode, cancel editing and revert to original data
                  fetchBusinessProfile();
                  setState(() {
                    isEditing = false;
                  });
                } else {
                  // Otherwise, navigate back or perform cancel action
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                backgroundColor: Colors.grey.shade200,
              ),
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  // Save or update the data
                  saveBusinessProfile();
                } else {
                  // Switch to edit mode
                  setState(() {
                    isEditing = true;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                backgroundColor: Color(0xFFE03537),
              ),
              child: Text(
                isEditing ? "Save" : "Edit",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
        foregroundColor: Colors.black,
        title: Text('Business Profile', style: TextStyle(color: Colors.black)),
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(color: Colors.red, width: 3.0),
                          insets: EdgeInsets.symmetric(horizontal: -50.0),
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
                        height: 650,
                        child: TabBarView(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 16),
                                    TextField(
                                      controller: businessNameController,
                                      readOnly: !isEditing,
                                      decoration: InputDecoration(
                                        labelText: "Business Name",
                                        hintStyle: TextStyle(color: Colors.grey),
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
                                      controller: phoneNumberController,
                                      readOnly: !isEditing,
                                      decoration: InputDecoration(
                                        labelText: "Phone Number",
                                        hintStyle: TextStyle(color: Colors.grey),
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
                                      controller: emailController,
                                      readOnly: !isEditing,
                                      decoration: InputDecoration(
                                        labelText: "Email",
                                        hintStyle: TextStyle(color: Colors.grey),
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
                                      controller: businessAddressController,
                                      readOnly: !isEditing,
                                      decoration: InputDecoration(
                                        labelText: "Business Address",
                                        hintStyle: TextStyle(color: Colors.grey),
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
                                      controller: pincodeController,
                                      readOnly: !isEditing,
                                      decoration: InputDecoration(
                                        labelText: "Pincode",
                                        hintStyle: TextStyle(color: Colors.grey),
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
                                      controller: businessDescriptionController,
                                      readOnly: !isEditing,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        labelText: "Business Description",
                                        hintStyle: TextStyle(color: Colors.grey),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                          borderSide: BorderSide(color: Colors.blueAccent, width: 2.0),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true,
                                      controller: TextEditingController(text: selectedState),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Remix.arrow_down_s_line,
                                          color: Colors.blueAccent,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _showStateSelectionBottomSheet(context);
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true,
                                      controller: TextEditingController(text: selectBusinessType),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Remix.arrow_down_s_line,
                                          color: Colors.blueAccent,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _showBusinessType(context);
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      readOnly: true,
                                      controller: TextEditingController(text: selectBusinessCategory),
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Remix.arrow_down_s_line,
                                          color: Colors.blueAccent,
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onTap: () {
                                        _showBusinessCategory(context);
                                      },
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