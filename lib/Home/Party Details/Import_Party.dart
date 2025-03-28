
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class Import_Party extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ImportParty();
}

class ImportParty extends State<Import_Party> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  List<bool> isChecked = [];
  bool isLoading = true;
  String query = "";
  int count = 0;

  void getContactPermission() async {
    if (await Permission.contacts.isGranted) {
      fetchContacts();
    } else {
      await Permission.contacts.request();
      if (await Permission.contacts.isGranted) {
        fetchContacts();
      } else {
        print("Permission denied. Cannot access contacts.");
      }
    }
  }

  void fetchContacts() async {
    try {
      contacts = await FlutterContacts.getContacts(withProperties: true); // Fetch full details
      isChecked = List<bool>.filled(contacts.length, false);
      filteredContacts = contacts; // Initially show all contacts
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching contacts: $e");
    }
  }

  void updateSearch(String value) {
    setState(() {
      query = value;
      filteredContacts = contacts
          .where((contact) =>
          (contact.displayName ?? "")
              .toLowerCase()
              .contains(query.toLowerCase())) // Filter by name
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getContactPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Import Party from Contacts"),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            // Search Bar
            TextField(
              onChanged: updateSearch,
              decoration: InputDecoration(
                hintText: "Search contacts...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Contact List
            Expanded(
              child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, index) {
                  String phoneNumber = (filteredContacts[index].phones.isNotEmpty)
                      ? filteredContacts[index].phones.first.number
                      : "No phone number";
                  return ListTile(
                    leading: Checkbox(
                        value: isChecked[contacts.indexOf(filteredContacts[index])],
                        onChanged: (bool? newValue) {
                          int actualIndex = contacts.indexOf(filteredContacts[index]);
                          isChecked[actualIndex] = newValue ?? false;
                          if (newValue == true) {
                            setState(() {
                              count++;
                            });
                          }
                          if (newValue == false) {
                            setState(() {
                              count--;
                            });
                          }
                        }),
                    title: Text(filteredContacts[index].displayName ?? "Unknown Name"),
                    subtitle: Text(phoneNumber),
                  );
                },
              ),
            ),

            // Import Button
            if (count > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      //
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 8),
                        Text(
                          "Import ${count} Contact(s)",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
