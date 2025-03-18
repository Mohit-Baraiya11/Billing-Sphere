import 'package:flutter/material.dart';

class Reminder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  List<Map<String, dynamic>> activeReminders = [
    {'id': 1, 'date': '2025-02-10', 'task': 'Doctor Appointment'},
    {'id': 2, 'date': '2025-02-12', 'task': 'Pay Bills'},
    {'id': 3, 'date': '2025-02-14', 'task': 'Anniversary Gift'},
  ];

  List<Map<String, dynamic>> completedReminders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text("To do list", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                      Tab(text: 'Reminder'),
                      Tab(text: 'Complted'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildReminderList(),
                        buildCompletedReminderList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReminderList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 10),
          Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blueAccent,
                    ),
                    padding: EdgeInsets.all(8),
                    child: Center(
                      child: Text(
                        'ACTIVE REMINDERS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ...activeReminders.map((reminder) => ListTile(
                    title: Text(reminder['task']),
                    subtitle: Text(reminder['date']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              completedReminders.add(reminder);
                              activeReminders.remove(reminder);
                            });
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              activeReminders.remove(reminder);
                            });
                          },
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCompletedReminderList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      "COMPLETED REMINDERS",
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ...completedReminders.map((reminder) => ListTile(
                  title: Text(reminder['task'], style: TextStyle(decoration: TextDecoration.lineThrough)),
                  subtitle: Text(reminder['date']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        completedReminders.remove(reminder);
                      });
                    },
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
