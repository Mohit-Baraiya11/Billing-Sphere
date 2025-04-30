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
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:remixicon/remixicon.dart';

class TransactionDetailsTab extends StatefulWidget {
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

  // Add TextEditingController for search bar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    _searchController.addListener(_filterTransactions); // Listen to search input changes
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  Future<void> fetchTransactions() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/");

    ref.onValue.listen((event) {
      if (event.snapshot.value != null) {
        print("Raw Firebase Transactions: ${event.snapshot.value}");

        Map<dynamic, dynamic> data = Map.from(event.snapshot.value as Map<dynamic, dynamic>);

        List<Map<String, dynamic>> fetchedTransactions = [];

        data.forEach((transactionId, value) {
          String type = value["type"] ?? "N/A";
          String name = "Unknown";
          String phone = value["phone"] ?? "";
          String total = "0.00";
          String balance = "0.00";
          String description = value["description"] ?? "";
          String date = value["date"] ?? "N/A";
          int currentTime = value["current_time"] ?? 0;

          // Mapping values based on transaction type
          if (type == "payment-in") {
            name = value["customer"] ?? "Unknown";
            total = value["received"]?.toString() ?? "0.00";
            balance = value["received"]?.toString() ?? "0.00";
          } else if (type == "sale") {
            name = value["customer"] ?? "Unknown";
            total = value["total_amount"]?.toString() ?? "0.00";
            balance = value["balance_due"]?.toString() ?? "0.00";
          } else if (type == "purchase") {
            name = value["party_name"] ?? "Unknown";
            total = value["total_amount"]?.toString() ?? "0.00";
            balance = value["balance_due"]?.toString() ?? "0.00";
          } else if (type == "payment-out") {
            name = value["party_name"] ?? "Unknown";
            total = value["paid_amount"]?.toString() ?? "0.00";
            balance = value["balance_due"]?.toString() ?? "0.00";
          } else if (type == "expenses") {
            name = value["category"] ?? value["expenses_category"] ?? "Unknown";
            total = value["amount"]?.toString() ?? "0.00";
          }

          // Add transaction data
          fetchedTransactions.add({
            "id": transactionId,
            "name": name,
            "phone": phone,
            "date": date,
            "description": description,
            "total": total,
            "unused": balance,
            "transactionType": type,
            "current_time": currentTime,
          });
        });

        print("📝 Fetched Transactions: ${fetchedTransactions.length}");
        print(fetchedTransactions);

        // Sort by latest transaction
        fetchedTransactions.sort((a, b) => b["current_time"].compareTo(a["current_time"]));

        setState(() {
          transactions = fetchedTransactions;
          isLoading = false;
        });
      } else {
        print("No transactions found");
        setState(() {
          transactions = [];
          isLoading = false;
        });
      }
    });
  }

  // Filter transactions based on search query
  void _filterTransactions() {
    setState(() {});
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

  Future<void> generateSalePDF(String transactionId) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoSansRegular();
    final fontBold = await PdfGoogleFonts.nunitoSansBold();

    // Fetch transaction data based on transactionId
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/$transactionId");

    final snapshot = await ref.get();
    if (!snapshot.exists) {
      print("Transaction not found");
      return;
    }

    Map<dynamic, dynamic> data = Map.from(snapshot.value as Map<dynamic, dynamic>);
    String name = data["customer"] ?? "Unknown";
    String phone = data["phone"] ?? "";
    String total = data["total_amount"]?.toString() ?? "0.00";
    String balance = data["balance_due"]?.toString() ?? "0.00";
    String description = data["description"] ?? "Sale transaction";
    String date = data["date"] ?? "N/A";
    List<Map<String, dynamic>> items = [];
    if (data["items"] != null) {
      items = (data["items"] as Map).entries.map((e) => Map<String, dynamic>.from(e.value)).toList();
    }
    String businessName = data["businessName"] ?? "Your Business Name";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Sale Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer Info
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 16,
                  font: fontBold,
                ),
              ),
              pw.Text(
                'Contact No: $phone',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice Details Table
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
                              'Customer:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              name,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Contact No: $phone',
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
                              'Invoice Details:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              'No: $transactionId',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Date: $date',
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

              // Items Table
              pw.Text(
                'Items:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Item Name', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Quantity', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Rate', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Subtotal', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Tax', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Unit', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                    ],
                  ),
                  ...items.map<pw.TableRow>((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["itemName"] ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["quantity"]?.toString() ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["rate"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["subtotal"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["taxValue"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["unit"] ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                      ],
                    );
                  }).toList(),
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
                            'Total Amount: ₹$total',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Balance Due: ₹$balance',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 14,
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
                            _amountToWords(double.parse(total ?? "0")),
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
                'Description:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                description,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Text(
                'For $businessName:',
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
    final filePath = '${directory.path}/Sale_Invoice_$transactionId.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(filePath);
  }

  Future<void> generatePurchasePDF(String transactionId) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.nunitoSansRegular();
    final fontBold = await PdfGoogleFonts.nunitoSansBold();

    // Fetch transaction data based on transactionId
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in");
      return;
    }

    String userId = user.uid;
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/$userId/Transactions/$transactionId");

    final snapshot = await ref.get();
    if (!snapshot.exists) {
      print("Transaction not found");
      return;
    }

    Map<dynamic, dynamic> data = Map.from(snapshot.value as Map<dynamic, dynamic>);
    String name = data["customer"] ?? "Unknown";
    String phone = data["phone"] ?? "";
    String total = data["total_amount"]?.toString() ?? "0.00";
    String balance = data["balance_due"]?.toString() ?? "0.00";
    String description = data["description"] ?? "Sale transaction";
    String date = data["date"] ?? "N/A";
    List<Map<String, dynamic>> items = [];
    if (data["items"] != null) {
      items = (data["items"] as Map).entries.map((e) => Map<String, dynamic>.from(e.value)).toList();
    }
    String businessName = data["businessName"] ?? "Your Business Name";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Text(
                'Purchase',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer Info
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 16,
                  font: fontBold,
                ),
              ),
              pw.Text(
                'Contact No: $phone',
                style: pw.TextStyle(
                  fontSize: 12,
                  font: font,
                ),
              ),
              pw.SizedBox(height: 20),

              // Invoice Details Table
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
                              'Customer:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              name,
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Contact No: $phone',
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
                              'Invoice Details:',
                              style: pw.TextStyle(
                                font: font,
                                fontSize: 12,
                              ),
                            ),
                            pw.Text(
                              'No: $transactionId',
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 14,
                              ),
                            ),
                            pw.Text(
                              'Date: $date',
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

              // Items Table
              pw.Text(
                'Items:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(width: 0.5),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1),
                  5: const pw.FlexColumnWidth(1),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Item Name', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Quantity', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Rate', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Subtotal', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Tax', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4.0),
                        child: pw.Text('Unit', style: pw.TextStyle(font: fontBold, fontSize: 12)),
                      ),
                    ],
                  ),
                  ...items.map<pw.TableRow>((item) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["itemName"] ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["quantity"]?.toString() ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["rate"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["subtotal"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text('₹${item["taxValue"]?.toString() ?? "0.00"}', style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4.0),
                          child: pw.Text(item["unit"] ?? "N/A", style: pw.TextStyle(font: font, fontSize: 12)),
                        ),
                      ],
                    );
                  }).toList(),
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
                            'Total Amount: ₹$total',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 16,
                            ),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text(
                            'Balance Due: ₹$balance',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 14,
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
                            _amountToWords(double.parse(total ?? "0")),
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
                'Description:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.Text(
                description,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 30),

              // Footer
              pw.Text(
                'For $businessName:',
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
    final filePath = '${directory.path}/Sale_Invoice_$transactionId.pdf';
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(filePath);
  }

  Future<void> generatePaymentOutPDF(Map<String, dynamic> transaction) async {
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
                'Payment-Out',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.SizedBox(height: 20),

              // Party Info
              pw.Text(
                '${transaction["name"] ?? "N/A"}',
                style: pw.TextStyle(fontSize: 16, font: fontBold),
              ),
              pw.Text(
                'Email: ${transaction["email"] ?? "N/A"}',
                style: pw.TextStyle(fontSize: 12, font: font),
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
                            pw.Text('Paid To:', style: pw.TextStyle(font: font, fontSize: 12)),
                            pw.Text(transaction["name"] ?? "N/A", style: pw.TextStyle(font: fontBold, fontSize: 14)),
                            pw.Text('Contact No: ${transaction["phone"] ?? "N/A"}', style: pw.TextStyle(font: font, fontSize: 12)),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Receipt Details:', style: pw.TextStyle(font: font, fontSize: 12)),
                            pw.Text('No: ${transaction["id"]}', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                            pw.Text('Date: ${transaction["date"]}', style: pw.TextStyle(font: fontBold, fontSize: 14)),
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
                            'Paid: ₹${transaction["total"] ?? "0.00"}',
                            style: pw.TextStyle(font: fontBold, fontSize: 16),
                          ),
                          pw.SizedBox(height: 10),
                          pw.Text('Amount in Words:', style: pw.TextStyle(font: font, fontSize: 12)),
                          pw.Text(
                            _amountToWords(double.tryParse(transaction["paid_amount"]?.toString() ?? "0") ?? 0),
                            style: pw.TextStyle(font: fontBold, fontSize: 12),
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
              pw.Text('Description:', style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.Text(transaction["description"] ?? "Payment made", style: pw.TextStyle(font: font, fontSize: 12)),
              pw.SizedBox(height: 30),

              // Footer
              pw.Text('For ${transaction["businessName"] ?? "Your Business Name"}:', style: pw.TextStyle(font: font, fontSize: 12)),
              pw.SizedBox(height: 40),
              pw.Text('Authorized Signatory', style: pw.TextStyle(font: fontBold, fontSize: 12)),
              pw.SizedBox(height: 20),
            ],
          );
        },
      ),
    );

    // Save and open the PDF
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/Payment_Out_${transaction["id"]}.pdf';
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
    // Filter transactions based on search query
    List<Map<String, dynamic>> filteredTransactions = transactions.where((transaction) {
      final searchQuery = _searchController.text.toLowerCase();
      return searchQuery.isEmpty ||
          transaction["name"].toString().toLowerCase().contains(searchQuery) ||
          transaction["transactionType"].toString().toLowerCase().contains(searchQuery) ||
          transaction["date"].toString().toLowerCase().contains(searchQuery);
    }).toList();

    // Apply filter options
    filteredTransactions = filteredTransactions
        .where((transaction) => filter_apply.isEmpty || filter_apply.contains(transaction["transactionType"]))
        .toList();

    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Container(
        color: Colors.blue.shade50,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
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
                              QuickLink(
                                icon: Remix.secure_payment_fill,
                                backgroundColor: Colors.redAccent,
                                label: "Add Txn",
                                onTap: () {
                                  pop_up_modal(context);
                                },
                              ),
                              QuickLink(
                                icon: Remix.file_chart_line,
                                label: "Sale Report",
                                backgroundColor: Colors.lightBlue,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Sale_Report()),
                                  );
                                },
                              ),
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

                    // Search bar
                    if (transactions.isNotEmpty)
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
                                controller: _searchController, // Attach controller
                                decoration: InputDecoration(
                                  hintText: "Search for transaction",
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                  prefixIcon: Icon(
                                    Remix.search_line,
                                    color: Colors.blue,
                                  ),
                                  suffixIcon: IconButton(
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
                                            height: MediaQuery.of(context).size.height * 0.5,
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
                                                                  filter_apply.clear();
                                                                  setState(() {}); // Trigger rebuild to clear filters
                                                                  Navigator.pop(context);
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
                                                                setState(() {}); // Trigger rebuild with applied filters
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
                                    icon: Icon(Remix.filter_2_line, color: Colors.blue),
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
                    isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredTransactions.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20), // Small padding from top
                          Image.asset(
                            "Assets/Images/note.png",
                            height: 100, // Fixed height for image
                            width: 100,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Hey! You have not added any transactions yet.\nAdd your first transaction now.",
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    )
                        : Column(
                      children: filteredTransactions
                          .map((transaction) => GestureDetector(
                        onTap: () {
                          if (transaction["transactionType"] == "payment-in") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Payment_in_Detail(transactionId: transaction["id"])));
                          } else if (transaction["transactionType"] == "sale") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Sale_Invoice_Detail(transactionId: transaction["id"])));
                          } else if (transaction["transactionType"] == "purchase") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Purchase_Details(transactionId: transaction["id"])));
                          } else if (transaction["transactionType"] == "payment-out") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Payment_Out_Detail(transactionId: transaction["id"])));
                          } else if (transaction["transactionType"] == "expenses") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Expenses_Details(transactionId: transaction["id"])));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
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
                                SizedBox(height: 4),
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
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Date",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
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
                                  ],
                                ),
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
                                    borderRadius: BorderRadius.circular(20),
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
                                            ? Color(0xFF38C782)
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
                                SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.4,
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
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                "Balance",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                transaction["unused"],
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
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
                                              onTap: () async {
                                                if (transaction["transactionType"] == "payment-in") {
                                                  await generatePaymentInPDF(transaction);
                                                }
                                                if (transaction["transactionType"] == "sale") {
                                                  await generateSalePDF(transaction["id"]);
                                                }
                                                if (transaction["transactionType"] == "purchase") {
                                                  await generatePurchasePDF(transaction["id"]);
                                                }
                                                if (transaction["transactionType"] == "payment-out") {
                                                  await generatePaymentOutPDF(transaction);
                                                }
                                              },
                                              child: Container(
                                                height: screenHeight * 0.16,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: screenWidth * 0.04,
                                                  vertical: screenHeight * 0.015,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                      EdgeInsets.only(bottom: screenHeight * 0.01),
                                                      child: Text(
                                                        "Share transaction",
                                                        style: TextStyle(
                                                          fontSize: screenWidth * 0.045,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
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
                                                                      borderRadius:
                                                                      BorderRadius.circular(90),
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
                                      icon: Icon(Remix.share_forward_line),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6),
                              ],
                            ),
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                    SizedBox(height: 80), // Space for the floating button
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20, // Changed from 0 to 20 to position button 20 pixels from the bottom
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    backgroundColor: Color(0xFFE03537),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Add_new_Sales()));
                  },
                  child: SizedBox(
                    width: 130,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Remix.money_rupee_circle_line, color: Colors.white, size: 20),
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

// ... (QuickLink widget and other methods like ShowAll, pop_up_modal remain unchanged)

var iconOf_moreOption = [
  Remix.bank_line,
  Remix.sticky_note_line,
  Remix.arrow_up_down_line,
];
var labelOf_moreOption = [
  "Bank Account",
  "All Txns Report",
  "Profit & Loss",
];
void ShowAll(BuildContext context) {
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
                  padding: const EdgeInsets.only(bottom: 18.0, top: 8.0),
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
                      onTap: () {
                        if (index == 0) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Add_Bank_Account()));
                        }
                        if (index == 1) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => All_Transaction()));
                        }
                        if (index == 2) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Profit_and_loss()));
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
];
var saleTransaction_icon = [
  Remix.download_cloud_2_line,
  Remix.discount_percent_line,
  Remix.shopping_cart_2_line,
  Remix.money_cny_box_line,
  Remix.wallet_3_line,
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
                    padding: const EdgeInsets.only(bottom: 18.0, top: 8.0),
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
                        onTap: () {
                          if (index == 0) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Payment_in()));
                          }
                          if (index == 1) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Add_new_Sales()));
                          }
                          if (index == 2) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Purchase()));
                          }
                          if (index == 3) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Payment_Out()));
                          }
                          if (index == 4) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => Expenses()));
                          }
                          if (index == 5) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder) => P2P_Transfer()));
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