import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class All_Parties_Report extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AllPartiesReportState();
}

class _AllPartiesReportState extends State<All_Parties_Report> {
  bool showZeroBalance = true;
  String selectedSortBy = "Name";
  String selectedShowOption = "All parties";
  String dateFilter = "31/01/2025"; // Default date

  final List<String> sortByOptions = ["Name", "Balance"];
  final List<String> showOptions = ["All parties", "Specific party"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text(
          "Party Report",
          style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          Container(
            height: 30,
            width: 50,
            child: Image.asset("Assets/Images/xls.png"),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Filter Section
              Row(
                children: [
                  Checkbox(
                    value: showZeroBalance,
                    onChanged: (value) {
                      setState(() {
                        showZeroBalance = value!;
                      });
                    },
                  ),
                  const Text("Date Filter"),
                  SizedBox(width: 50,),
                  const Text("Date "),
                  GestureDetector(
                    onTap: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000), // Start of date range
                        lastDate: DateTime(2100), // End of date range
                      );

                      if (selectedDate != null) {
                        setState(() {
                          dateFilter =
                          "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateFilter,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Sorting and Showing Filters
              Row(
                children: [
                  // Show Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedShowOption,
                      decoration: const InputDecoration(
                        labelText: "Show",
                        labelStyle: TextStyle(color: Color(0xFF0078AA)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none
                        ),
                      ),
                      items: showOptions
                          .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedShowOption = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sort By Filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedSortBy,
                      decoration: const InputDecoration(
                        labelText: "Sort by",
                        labelStyle: TextStyle(color: Color(0xFF0078AA)),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: sortByOptions
                          .map((option) => DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSortBy = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(),
              Row(
                children: [
                  // Date Filter Checkbox
                  Checkbox(
                    value: showZeroBalance,
                    onChanged: (value) {
                      setState(() {
                        showZeroBalance = value!;
                      });
                    },
                  ),
                  const Text("Show O balance party"),
                  ],
              ),
              const SizedBox(height: 16),

              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Party name",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          "Credit Limit",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Balance",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Party Data List
              Expanded(
                child: ListView.builder(
                  itemCount: 4, // Replace with actual data count
                  itemBuilder: (context, index) {
                    // Example Data
                    final partyName = ["+919343897723", ".Y", "Ashish", "Mohit"];
                    final balance = [0.00, 0.00, 497.00, 300.00];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              partyName[index],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const Expanded(
                            flex: 1,
                            child: Center(
                              child: Text(
                                "-",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "₹ ${balance[index].toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: balance[index] > 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
