import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

class To_do_list extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _to_do_list();
}

class _to_do_list extends State<To_do_list> {
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
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(color: Colors.blueAccent, width: 3.0),
                      insets: EdgeInsets.symmetric(horizontal: -50.0),
                    ),
                    indicatorColor: Colors.blueAccent,
                    indicatorWeight: 2.0,
                    labelColor: Colors.blueAccent,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'Tasks'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Missed'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildToDoList(context),
                        buildCompletedList(),
                        buildMissedList(),
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
// Add these controllers and variables at the top of your existing code
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _addCategoryController = TextEditingController();
  String _selectedCategory = 'No Category';
  DateTime _selectedDate = DateTime.now();
  List<String> _categories = ['No Category'];
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final User? _user = FirebaseAuth.instance.currentUser;

// Add these functions to your existing code
  Future<void> _loadCategories() async {
    if (_user == null) return;

    final snapshot = await _databaseRef
        .child('users/${_user!.uid}/To_do_list/Categories')
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _categories = ['No Category', ...data.keys.cast<String>()];
      });
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _addNewCategory() async {
    if (_addCategoryController.text.isEmpty || _user == null) return;

    final newCategory = _addCategoryController.text.trim();

    await _databaseRef
        .child('users/${_user!.uid}/To_do_list/Categories/$newCategory')
        .set(true);

    setState(() {
      _categories.add(newCategory);
      _selectedCategory = newCategory;
    });

    _addCategoryController.clear();
    Navigator.pop(context); // Close the add category dialog
  }

  Future<void> _addNewTask() async {
    if (_taskController.text.isEmpty || _user == null) return;

    final taskId = _databaseRef.push().key;
    final taskData = {
      'task': _taskController.text,
      'category': _selectedCategory,
      'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      'is_complete': false,
    };

    await _databaseRef
        .child('users/${_user!.uid}/To_do_list/Tasks/$taskId')
        .set(taskData);

    _taskController.clear();
    await _loadTasks(); // Refresh the task list
    Navigator.pop(context);
  }
// Modify your existing _showAddCategoryDialog function
  void _showAddCategoryDialog(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.white,
        context: context,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              height: MediaQuery.of(context).size.height * 0.25,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Add Category", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close)
                        ),
                      ],
                    ),
                  ),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    height: 45,
                    child: TextField(
                      controller: _addCategoryController,
                      decoration: InputDecoration(
                        labelText: "Add new category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4.0),
                          borderSide: BorderSide(color: Colors.grey, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: _addNewCategory,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }



  List<Map<dynamic, dynamic>> _tasks = [];
  List<Map<dynamic, dynamic>> _incompleteTasks = [];
  Future<void> _loadTasks() async {
    if (_user == null) return;

    final snapshot = await _databaseRef
        .child('users/${_user!.uid}/To_do_list/Tasks')
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _tasks = data.entries.map((entry) {
          return {
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value)
          };
        }).toList();

        _incompleteTasks = _tasks.where((task) => task['is_complete'] == false).toList();
      });
    }
  }
  Future<void> _completeTask(String taskId) async {
    if (_user == null) return;

    await _databaseRef
        .child('users/${_user!.uid}/To_do_list/Tasks/$taskId/is_complete')
        .set(true);

    await _loadTasks(); // Refresh the task list
  }
  void _showCompletionDialog(String taskId, String taskName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Complete Task"),
          content: Text("Are you sure you completed '$taskName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                _completeTask(taskId);
                Navigator.pop(context);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  Widget buildToDoList(BuildContext context) {
    return Scaffold(
      body: Column(
        children:[
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.where((task) => task['is_complete'] == false).length,
              itemBuilder: (context, index) {
                final task = _tasks.where((task) => task['is_complete'] == false).elementAt(index);
                return  Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Radio<bool>(
                      value: false,
                      groupValue: true,
                      onChanged: (bool? value) {
                        _showCompletionDialog(task['id'], task['task']);
                      },
                    ),
                    title: Text(task['task']), // No strikethrough needed
                    subtitle: Text("${task['category']} • ${task['date']}"),
                    trailing: Icon(Icons.pending, color: Colors.orange), // Only show pending icon
                  ),
                );              },
            ),
          ),
       ]
      ),
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
                      height: MediaQuery.of(context).size.height * 0.4,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Task Input Field
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: 'Input new task here',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              maxLines: 3,
                              minLines: 1,
                            ),
                          ),
                          SizedBox(height: 16),

                          // Category Selection
                          SizedBox(
                            height: 50,
                            child: TextField(
                              onTap: () {
                                showModalBottomSheet(
                                  backgroundColor: Colors.white,
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Container(
                                          height: MediaQuery.of(context).size.height * 0.85,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: Colors.white,
                                          ),
                                          child: Stack(
                                            children: [
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Select Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                                        IconButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                            },
                                                            icon: Icon(Icons.close)
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(color: Colors.grey.shade200, thickness: 1),
                                                  SizedBox(height: 10),

                                                  // Add New Category Tile
                                                  ListTile(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      _showAddCategoryDialog(context);
                                                    },
                                                    dense: true,
                                                    visualDensity: VisualDensity.compact,
                                                    title: Text("Add New Category", style: TextStyle(color: Colors.blueAccent)),
                                                    trailing: Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                                                  ),
                                                  Divider(color: Colors.grey.shade200, thickness: 1),

                                                  // Categories List
                                                  Expanded(
                                                    child: _categories.isEmpty
                                                        ? Center(child: Text("No categories found"))
                                                        : ListView.separated(
                                                      itemCount: _categories.length,
                                                      separatorBuilder: (context, index) {
                                                        return Divider(color: Colors.grey.shade200, thickness: 1);
                                                      },
                                                      itemBuilder: (context, index) {
                                                        return ListTile(
                                                          dense: true,
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                                          visualDensity: VisualDensity.compact,
                                                          title: Text(_categories[index]),
                                                          trailing: Radio<String>(
                                                            activeColor: Colors.blueAccent,
                                                            value: _categories[index],
                                                            groupValue: _selectedCategory,
                                                            onChanged: (value) {
                                                              setModalState(() {
                                                                _selectedCategory = value!;
                                                              });
                                                            },
                                                          ),
                                                          onTap: () {
                                                            setModalState(() {
                                                              _selectedCategory = _categories[index];
                                                            });
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Positioned(
                                                bottom: 20,
                                                left: 0,
                                                right: 0,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.all(14),
                                                    backgroundColor: Colors.blueAccent,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    "Apply",
                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: "Category",
                                hintText: _selectedCategory,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey,width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey,width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey,width: 1),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Date Picker
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(DateFormat('dd MMM yyyy').format(_selectedDate)),
                                        Spacer(),
                                        Text('Change', style: TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Submit Button
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
                              onPressed: _addNewTask,
                              child: Text('Add Task', style: TextStyle(color: Colors.white)),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(90),
        ),
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue.shade300,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

// Call _loadCategories in your initState
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTasks();
  }


  Widget buildCompletedList() {
    return Scaffold(
      body: Column(
          children:[
            Expanded(
              child: _tasks.where((task) => task['is_complete'] == true).length == 0
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Remix.survey_line, size: 100, color: Colors.blueAccent),
                    Text("No completed Task"),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _tasks.where((task) => task['is_complete'] == true).length,
                itemBuilder: (context, index) {
                  final task = _tasks.where((task) => task['is_complete'] == true).elementAt(index);
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text(
                        task['task'],
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      subtitle: Text(
                        "${task['category']} • ${task['date']}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.restore_from_trash, color: Colors.red),
                        onPressed: () {
                          _showRestoreDialog(task['id'], task['task'],context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ]
      ),
      backgroundColor: Colors.white,
    );
  }

  void _showRestoreDialog(String taskId, String taskName,BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Mark Task as Pending?"),
          content: Text("Do you want to mark '$taskName' as incomplete?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _databaseRef
                    .child('users/${_user!.uid}/To_do_list/Tasks/$taskId/is_complete')
                    .set(false)
                    .then((_) {
                  _loadTasks();
                  Navigator.pop(context);
                });
              },
              child: Text(
                "Restore",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }




  ///missed tasks
  Widget buildMissedList() {
    // Get current date (without time)
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Filter tasks that are missed (date is past and not completed)
    final missedTasks = _tasks.where((task) {
      try {
        final taskDate = DateFormat('yyyy-MM-dd').parse(task['date']);
        return taskDate.isBefore(today) && task['is_complete'] == false;
      } catch (e) {
        return false;
      }
    }).toList();

    return Scaffold(
      body: missedTasks.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text("No missed tasks", style: TextStyle(fontSize: 18)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: missedTasks.length,
        itemBuilder: (context, index) {
          final task = missedTasks[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.red.shade50, // Light red background for missed tasks
            child: ListTile(
              leading: Icon(Icons.warning_amber, color: Colors.orange),
              title: Text(
                task['task'],
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Category: ${task['category']}"),
                  Text("Due: ${task['date']} (Missed)"),
                ],
              ),
              trailing: Icon(Icons.block, color: Colors.grey), // Indicates cannot edit
            ),
          );
        },
      ),
    );
  }
  bool isTaskMissed(Map<dynamic, dynamic> task) {
    try {
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final taskDate = DateFormat('yyyy-MM-dd').parse(task['date']);
      return taskDate.isBefore(today) && task['is_complete'] == false;
    } catch (e) {
      return false;
    }
  }
}
