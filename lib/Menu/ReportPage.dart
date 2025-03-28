import 'package:flutter/material.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  // Static report data
  final List<Map<String, dynamic>> reports = [
    {'index': 1, 'date': '2023-10-01', 'type': 'Payment-In', 'pdfUrl': 'https://example.com/report1.pdf'},
    {'index': 2, 'date': '2023-10-02', 'type': 'Payment-Out', 'pdfUrl': 'https://example.com/report2.pdf'},
    {'index': 3, 'date': '2023-10-03', 'type': 'Payment-In', 'pdfUrl': 'https://example.com/report3.pdf'},
  ];

  String searchQuery = '';

  List<Map<String, dynamic>> get filteredReports {
    return reports.where((report) => report['type'].toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        backgroundColor: Color(0xFF0078AA),
        title: Text("Report", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(90),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2,
                  ),
                ]
              ),
               child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by Type",
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Colors.blue),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),

            // Report Table
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DataTable(
                    columnSpacing: 8, // Reduced spacing to fit within screen
                    dataRowHeight: 40, // Reduced row height
                    headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.withOpacity(0.1)),
                    columns: const [
                      DataColumn(label: Text('Index', style: headerStyle)),
                      DataColumn(label: Text('Date', style: headerStyle)),
                      DataColumn(label: Text('Type', style: headerStyle)),
                      DataColumn(label: Text('Download', style: headerStyle)),
                      DataColumn(label: Text('Delete', style: headerStyle)),
                    ],
                    rows: filteredReports.map((report) {
                      return DataRow(
                        cells: [
                          DataCell(Text(report['index'].toString(), style: rowTextStyle)),
                          DataCell(Text(report['date'], style: rowTextStyle)),
                          DataCell(
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: report['type'] == "Payment-In"
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(report['type'], style: rowTextStyle),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.download, color: Colors.blue, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Downloading ${report['pdfUrl']}')),
                                );
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red, size: 18),
                              onPressed: () {
                                setState(() {
                                  reports.remove(report);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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

// Text styles
const TextStyle headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 14);
const TextStyle rowTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
