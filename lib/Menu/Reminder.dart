import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Reminder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Reminder();
}

class _Reminder extends State<Reminder> {
  final TextEditingController _taskController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("User not logged in")),
      );
    }

    final DatabaseReference reminderRef = _database
        .ref()
        .child("users")
        .child(user.uid)
        .child("Reminder");

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      padding: EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: 'Input new Reminder here',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade300,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                final String reminderText = _taskController.text.trim();
                                if (reminderText.isNotEmpty) {
                                  final newReminderRef = reminderRef.push(); // generate unique id
                                  await newReminderRef.set({
                                    'text': reminderText,
                                    'timestamp': DateTime.now().toIso8601String(),
                                  });
                                  _taskController.clear();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text('Add Reminder', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue.shade300,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text("Reminder list", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder(
        stream: reminderRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(child: Text("No Reminders Yet"));
          }

          Map<dynamic, dynamic> reminders = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> reminderList = reminders.entries.map((entry) {
            return {
              'id': entry.key,
              'text': entry.value['text'] ?? '',
              'timestamp': entry.value['timestamp'] ?? '',
            };
          }).toList();

          reminderList.sort((a, b) =>
              DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: reminderList.length,
            itemBuilder: (context, index) {
              final reminder = reminderList[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ListTile(
                  title: Text(reminder['text']),
                  subtitle: Text(
                    DateTime.tryParse(reminder['timestamp']) != null
                        ? '${DateTime.parse(reminder['timestamp']).toLocal()}'
                        : '',
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      reminderRef.child(reminder['id']).remove();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
