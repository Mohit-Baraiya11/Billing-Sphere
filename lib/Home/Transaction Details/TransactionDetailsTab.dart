import 'dart:io';
import 'package:billing_sphere/Home/Home.dart';
import 'package:billing_sphere/Home/Sale_Report.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Expense/Expenses.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Expense/Expenses_Details.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Other%20Transaction/p2p_transfer.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Payment-Out/Payment_Out.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Payment-Out/Payment_Out_Detail.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Payment-in/Payment-in-Detail.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Payment-in/payment-in.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Purchase/Purchase_Details.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Purchase/purchase.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Sale%20Invoice/Sale_Invoice_Detail.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Add%20Txn/Sale%20Invoice/add_new_sales.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/add_bank_account.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/all_transaction.dart';
import 'package:billing_sphere/Home/Transaction%20Details/Show%20All/profit&loss.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_remix/flutter_remix.dart';
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';
import 'package:share_plus/share_plus.dart';

class TransactionDetailsTab extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => _TransactionDetailsTab();
}

class _TransactionDetailsTab extends State<TransactionDetailsTab> {
  final Map<String, bool> filterOptions = {
    "payment-in": false,
    "sale": false,
    "purchase": false,
    "payment-out": false,
    "Expenses": false,
  };
  List<String> filter_apply = [];

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    print(filter_apply);
  }

  void fetchTransactions() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/");

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> fetchedTransactions = [];

        data.forEach((transactionId, value) {
          String type = value["type"] ?? "N/A";
          String name = "Unknown";
          String phone = value["phone"];
          String total = "0.00";
          String unused = "0.00";
          String description = value["description"];
          String date = value["date"] ?? "N/A";
          int currentTime = value["current_time"] ?? 0; // Get timestamp

          // Mapping values based on transaction type
          if (type == "payment-in") {
            name = value["customer"] ?? "Unknown";
            total = value["received"] ?? "0.00";
            unused = value["received"] ?? "0.00";
          } else if (type == "sale") {
            name = value["customer"] ?? "Unknown";
            total = value["total_amount"] ?? "0.00";
            unused = value["unused"] ?? "0.00";
          } else if (type == "purchase") {
            name = value["party_name"] ?? "Unknown";
            total = value["total_amount"] ?? "0.00";
            unused = value["unused"] ?? "0.00";
          } else if (type == "payment-out") {
            name = value["party_name"] ?? "Unknown";
            total = value["paid"] ?? "0.00";
            unused = value["unused"] ?? "0.00";
          } else if (type == "expenses") {
            name = value["expenses_category"] ?? "Unknown";
            total = value["total_amount"] ?? "0.00";
            unused = value["unused"] ?? "0.00";
          }

          // Add transaction data with its ID and timestamp
          fetchedTransactions.add({
            "id": transactionId, // Store the transaction ID
            "name": name,
            "phone":phone,
            "date": date,
            "description":description,
            "total": total,
            "unused": unused,
            "transactionType": type,
            "current_time": currentTime, // Add timestamp for sorting
          });
        });

        // Sort transactions by current_time in descending order (Latest first)
        fetchedTransactions.sort((a, b) => b["current_time"].compareTo(a["current_time"]));

        setState(() {
          transactions = fetchedTransactions;
          isLoading = false; // Stop showing the loading indicator
        });
      } else {
        setState(() {
          transactions = [];
          isLoading = false; // Stop loading indicator even if no data
        });
        print("No transactions found");
      }
    });
  }
  Future<void> generatePaymentInPDF(Map<String, dynamic> transaction) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoSansRegular();
    final fontBold = await PdfGoogleFonts.nunitoSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Payment-In',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer Info
              pw.Text(
                '${transaction["name"]}',
                style: pw.TextStyle(
                  fontSize: 16,
                  font: fontBold,
                ),
              ),
              pw.Text(
                'Email: ${transaction["email"] ?? "N/A"}',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 20),

              // Receipt Details Table
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Received From:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              transaction["name"] ?? "N/A",
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Contact No: ${transaction["phone"] ?? "N/A"}',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Receipt Details:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              'No: ${transaction["id"]}',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Date: ${transaction["date"]}',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Amount Section
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Container(), // Empty cell
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Received: ₹${transaction["total"]}',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Amount in Words:',
                            style: pw.TextStyle(
                              font: font,
                              fontSize: 12,
                            ),
                          ),
                          pw.Text(
                            _amountToWords(double.parse(transaction["total"] ?? "0")),
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Divider
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              // Description
              pw.Text(
                'description:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                transaction["description"] ?? "Payment received",
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Text(
                'For ${transaction["businessName"] ?? "Your Business Name"}:',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Authorized Signatory',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    // Save and open the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Payment_In_${transaction["id"]}.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(filePath);
  }

// Helper function to convert amount to words
  String _amountToWords(double amount) {
    // Implement your amount to words conversion logic here
    // You can use a package like 'number_to_words' or implement your own
    return '${amount.toInt()} Rupees only';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue.shade50,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // Quick Links Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 35, bottom: 7),
                            child: Text(
                              "Quick Links",
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            //Add Txn
                            QuickLink(
                              icon: Remix.file_add_line,
                              backgroundColor: Colors.redAccent,
                              label: "Add Txn",
                              onTap: () {
                                pop_up_modal(context);
                              },
                            ),

                            //Sale Report
                            QuickLink(
                              icon: Remix.file_chart_line,
                              label: "Sale Report",
                              backgroundColor: Colors.lightBlue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Sale_Report()),
                                );
                              },
                            ),

                            //Show all
                            QuickLink(
                              icon: Remix.arrow_right_circle_line,
                              label: "Show All",
                              backgroundColor: Colors.lightBlue,
                              onTap: () {
                                ShowAll(context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),


                  //searchbaar
                  if(transactions.isNotEmpty)
                  Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search for transaction",
                                hintStyle:
                                TextStyle(fontSize: 13, color: Colors.grey),
                                prefixIcon: Icon(
                                  Remix.search_line,
                                  color: Colors.blue,
                                ),
                                suffixIcon:IconButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.white,
                                      isScrollControlled: true,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) {
                                        return Container(
                                            height:MediaQuery.of(context).size.height*0.5,
                                            child: StatefulBuilder(
                                              builder: (context, setModalState) {
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text(
                                                                "Filter By",
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 22,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                },
                                                                icon: Icon(Icons.close),
                                                              ),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Expanded(
                                                            child: ListView(
                                                              children: filterOptions.keys.map((filter) {
                                                                return CheckboxListTile(
                                                                  title: Text(filter),
                                                                  value: filterOptions[filter],
                                                                  activeColor: Colors.blue,
                                                                  onChanged: (bool? value) {
                                                                    setModalState(() {
                                                                      filterOptions[filter] = value!;
                                                                      if (value) {
                                                                        if (!filter_apply.contains(filter)) {
                                                                          filter_apply.add(filter);
                                                                        }
                                                                      } else {
                                                                        filter_apply.remove(filter);
                                                                      }
                                                                      print(filter_apply);
                                                                    });
                                                                  },

                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Positioned(
                                                      bottom: 16,
                                                      left: 16,
                                                      right: 16,
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.grey.shade200,
                                                                minimumSize: Size(120, 48),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(90),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                setModalState(() {
                                                                  filterOptions.updateAll((key, value) => false);
                                                                  filter_apply.clear(); // Clear the applied filters list
                                                                });
                                                              },

                                                              child: Text(
                                                                "Clear",
                                                                style: TextStyle(color: Colors.black),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor: Colors.red,
                                                                minimumSize: Size(120, 48),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(90),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text(
                                                                "Apply",
                                                                style: TextStyle(color: Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                        );
                                      },
                                    );
                                  },

                                  icon: Icon(Remix.filter_2_line, color: Colors.blue,),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 10),

                  // Transactions List Section
                  Expanded(
                    child: isLoading
                        ?Center(child: CircularProgressIndicator())
                        : transactions.isEmpty
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 100,
                                width: 100,
                                child: Image.asset("Assets/Images/note.png"),
                              ),
                              const Text(
                                "Hey! You have not added any transactions yet.\nAdd your first transaction now.",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : ListView.builder(
                      itemCount: transactions
                          .where((transaction) =>
                      filter_apply.isEmpty || filter_apply.contains(transaction["transactionType"]))
                          .length,
                      itemBuilder: (context, index) {
                        final filteredTransactions = transactions
                            .where((transaction) =>
                        filter_apply.isEmpty || filter_apply.contains(transaction["transactionType"]))
                            .toList();

                        if (filteredTransactions.isEmpty) {
                          return Center(
                            child: Text(
                              "No transactions found",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          );
                        }

                        final transaction = filteredTransactions[index];

                        return GestureDetector(
                          onTap: () {
                            if (transaction["transactionType"] == "payment-in") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Payment_in_Detail(transactionId: transaction["id"])));
                            } else if (transaction["transactionType"] == "sale") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Sale_Invoice_Detail(transactionId: transaction["id"])));
                            } else if (transaction["transactionType"] == "purchase") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Purchase_Details(transactionId: transaction["id"])));
                            } else if (transaction["transactionType"] == "payment-out") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Payment_Out_Detail(transactionId: transaction["id"])));
                            } else if (transaction["transactionType"] == "expenses") {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Expenses_Details(transactionId: transaction["id"])));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        transaction["name"],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        transaction["date"],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: transaction["transactionType"] == "payment-in"
                                          ? Color(0xFFC0F1E1)
                                          : transaction["transactionType"] == "sale"
                                          ? Color(0xFFC0F1E1)
                                          : transaction["transactionType"] == "purchase"
                                          ? Colors.deepOrange.shade50
                                          : transaction["transactionType"] == "payment-out"
                                          ? Colors.deepOrange.shade50
                                          : transaction["transactionType"] == "expenses"
                                          ? Colors.purple.shade100
                                          : Color(0xFFC0F1E1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                                      child: Text(
                                        transaction["transactionType"],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: transaction["transactionType"] == "payment-in"
                                              ? Color(0xFF38C782)
                                              : transaction["transactionType"] == "sale"
                                              ? Colors.green
                                              : transaction["transactionType"] == "purchase"
                                              ? Colors.deepOrange
                                              : transaction["transactionType"] == "payment-out"
                                              ? Colors.deepOrangeAccent
                                              : transaction["transactionType"] == "expenses"
                                              ? Colors.purple
                                              : Color(0xFFC0F1E1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.4,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Total",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  "₹ ${transaction["total"]}",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Unused",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  transaction["unused"],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                     IconButton(
                                          onPressed: (){
                                            double screenWidth = MediaQuery.of(context).size.width;
                                            double screenHeight = MediaQuery.of(context).size.height;

                                            showModalBottomSheet(
                                              backgroundColor: Colors.white,
                                              context: context,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                              ),
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () async{
                                                    if(transaction["transactionType"]=="payment-in") {
                                                      await generatePaymentInPDF(transaction);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: screenHeight * 0.16, // Responsive height
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: screenWidth * 0.04,
                                                      vertical: screenHeight * 0.015,
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // Share Transaction Header
                                                        Padding(
                                                          padding: EdgeInsets.only(bottom: screenHeight * 0.01),
                                                          child: Text(
                                                            "Share transaction",
                                                            style: TextStyle(
                                                              fontSize: screenWidth * 0.045, // Responsive font size
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),

                                                        // Row for Share as Image & Share as PDF
                                                        Row(
                                                          children: [

                                                            // Share as PDF
                                                            Expanded(
                                                              child: Padding(
                                                                padding: EdgeInsets.all(screenWidth * 0.02),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Color(0xFFE03537),
                                                                    borderRadius: BorderRadius.circular(4),
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(
                                                                    horizontal: screenWidth * 0.04,
                                                                    vertical: screenHeight * 0.015,
                                                                  ),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height: screenHeight * 0.04,
                                                                        width: screenHeight * 0.04,
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.circular(90),
                                                                        ),
                                                                        child: Icon(
                                                                          Remix.file_pdf_2_line,
                                                                          color: Colors.grey,
                                                                          size: screenWidth * 0.06,
                                                                        ),
                                                                      ),
                                                                      SizedBox(width: screenWidth * 0.02),
                                                                      Flexible(
                                                                        child: Text(
                                                                          "Share as PDF",
                                                                          style: TextStyle(
                                                                            color: Colors.white,
                                                                            fontSize: screenWidth * 0.035,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(Remix.share_forward_line)
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                    ,
                  ),


                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    backgroundColor: Colors.red,
                    // shape: RoundedRectangleBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    // ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_new_Sales()));
                  },
                  child: SizedBox(
                    width: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Remix.money_rupee_circle_line,color: Colors.white,size: 20,),
                        const SizedBox(width: 8),
                        Text(
                          "Add New Sale",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
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
var iconOf_moreOption = [
  Remix.bank_line,
  FlutterRemix.sticky_note_line,
  FlutterRemix.arrow_up_down_line,
];
var labelOf_moreOption = [
  "Bank Account",
  "All Txns Report",
  "Profit & Loss",
];
void ShowAll(BuildContext context)
{
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height * 0.20,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale Transactions Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0,top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "More Option",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: (){
                          if(index==0){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Add_Bank_Account()));
                          }
                          if(index==1){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>All_Transaction()));
                          }
                          if(index==2){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Profit_and_loss()));
                          }
                        },
                        child: QuickLink(
                          icon: iconOf_moreOption[index],
                          label: labelOf_moreOption[index],
                          backgroundColor: default_color,
                        ),
                      );
                    },
                    itemCount: iconOf_moreOption.length,
                  ),

                ],
              ),
            ),
          ),

      );
    },
  );
}

var saleTransaction_label = [
  "Payment-in",
  "Sale invoice",
  "Purchase",
  "Payment-Out",
  "Expenses",
  "P2P Transfer",
];
var saleTransaction_icon = [
  FlutterRemix.download_cloud_2_line,
  Remix.discount_percent_line,
  FlutterRemix.shopping_cart_2_line,
  FlutterRemix.money_cny_box_line,
  FlutterRemix.wallet_3_line,
  Remix.p2p_line,
];

void pop_up_modal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return Container(
        color: Colors.white,
        child: FractionallySizedBox(
          heightFactor: 0.30, // 95% of the screen height
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sale Transactions Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 18.0,top: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Sale Transactions",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  // Sale Transactions Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {

                      return InkWell(
                        onTap: (){
                          if(index==0){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){return Payment_in();}));
                          }
                          if(index==1){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>Add_new_Sales()));
                          }
                          if(index==2){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>Purchase()));
                          }
                          if(index==3){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>Payment_Out()));
                          }
                          if(index==4){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>Expenses()));
                          }
                          if(index==5){
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>P2P_Transfer()));
                          }
                        },
                        child: QuickLink(
                          icon: saleTransaction_icon[index],
                          label: saleTransaction_label[index],
                          backgroundColor: index == 0 ? Color(0XFF90D5FF) : default_color,
                        ),
                      );
                    },
                    itemCount: saleTransaction_label.length,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}