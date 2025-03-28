import 'package:billing_sphere/Home/Prefered_underline_appbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profit_and_loss extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => Profitandloss();
}

class Profitandloss extends State<Profit_and_loss> {
  String? selected_timeDuration = "This week";
  final List<String> time_duration_option = [
    'Today',
    'This week',
    'This month',
    'This quarter',
    'This Financial Year',
    'custom'
  ];

  var firstDate = DateTime.now();
  var lastDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

  void _select_firstDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime(DateTime.monthsPerYear),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          firstDate = picked;
        });
      }
    });
  }
  void _select_lastDate(BuildContext context) {
    showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          lastDate = picked;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.grey.shade400,
          statusBarIconBrightness: Brightness.light,
        ),
        surfaceTintColor: Colors.white,
        backgroundColor:Colors.white,
        title: Text(
          "Profit And Loss Report",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: Prefered_underline_appbar(),
        actions: [
          //pdf
          Container(
            height: 25,
            width: 25,
            child: Image.asset("Assets/Images/pdf.png"),
          ),
          //xls
          Container(
            height: 30,
            width: 50,
            child: Image.asset("Assets/Images/xls.png"),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: selected_timeDuration,
                      hint: Text(
                        'This month',
                        style: TextStyle(fontSize: 12),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: Colors.blue,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          selected_timeDuration = newValue;
                        });
                      },
                      items: time_duration_option
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      underline: Container(),
                    ),
                    Container(
                      height: 20,
                      child: VerticalDivider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      Icons.calendar_month,
                      color: Colors.blue,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _select_firstDate(context),
                      child: Text(
                        '${firstDate.day}/${firstDate.month}/${firstDate.year}',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'to',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _select_lastDate(context),
                      child: Text(
                        '${lastDate.day}/${lastDate.month}/${lastDate.year}',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [Colors.lightBlueAccent.shade100,Color(0x88D8E7F1FF)],
                    ),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    children: [
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Gross Profit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.grey),
                                          )),
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "₹100.00",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.greenAccent),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.all(8.0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Column(
                                    children: [
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Net Profit",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.grey),
                                          )),
                                      Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "₹100.00",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.greenAccent),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                buildSectionTitle("Particulars"),
                                Divider(thickness: 1, height: 24),
                                buildRowItem("Sale (+)", "₹ 100.00", Colors.green),
                                buildRowItem("Sale FA (+)", "₹ 0.00", Colors.red),
                                buildRowItem("Cr. Note/Sale Return (-)", "₹ 0.00", Colors.red),
                                buildRowItem("Purchase (-)", "₹ 0.00", Colors.red),
                                buildRowItem("Purchase FA (-)", "₹ 0.00", Colors.red),
                                buildRowItem("Dr. Note/Purchase Return (+)", "₹ 0.00", Colors.green),
                                buildRowItem("Payment Out Discount (+)", "₹ 0.00", Colors.green),
                                Divider(thickness: 1, height: 24),
                                buildSectionTitle("Stocks"),
                                buildRowItem("Opening Stock (-)", "₹ 0.00", Colors.red),
                                buildRowItem("Closing Stock (+)", "₹ 0.00", Colors.green),
                                buildRowItem("Opening FA Stock (-)", "₹ 0.00", Colors.red),
                                buildRowItem("Closing FA Stock (+)", "₹ 0.00", Colors.green),
                                Divider(thickness: 1, height: 24),
                                buildSectionTitle("Direct Expenses (-)"),
                                buildRowItem("Other Direct Expense", "₹ 0.00", Colors.red),
                                buildRowItem("Payment In Discount", "₹ 0.00", Colors.green),
                                Divider(thickness: 1, height: 24),
          
                                buildSectionTitle("Tax Payable (-)"),
                                buildRowItem("GST Payable", "₹ 0.00", Colors.red),
                                buildRowItem("TCS Payable", "₹ 0.00", Colors.red),
                                buildRowItem("TDS Payable", "₹ 0.00", Colors.red),
          
                                buildSectionTitle("Tax Payable (+)"),
                                buildRowItem("GST Receivable", "₹ 0.00", Colors.green),
                                buildRowItem("TCS Receivable", "₹ 0.00", Colors.green),
                                buildRowItem("TDS Receivable", "₹ 0.00", Colors.green),
          
                                buildSectionTitle_Profit("Gross Profit", "₹100.00", Colors.green),
          
                                buildSectionTitle("Other Income (+)"),
                                buildRowItem("Other Income", "₹ 0.00", Colors.green),
          
                                buildSectionTitle("Indirect Expenses (-)"),
                                buildRowItem("Other Expense", "₹ 0.00", Colors.red),
                                buildRowItem("Loan Interest Expense", "₹ 0.00", Colors.red),
                                buildRowItem("Loan Processing Free Expense", "₹ 0.00", Colors.red),
                                buildRowItem("Charges on Loan Expenses", "₹ 0.00", Colors.red),
          
                                buildSectionTitle_Profit("Net Profit", "₹100.00", Colors.green),
          
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          
            ],
          ),
        ),
      )

    );
  }
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
  Widget buildSectionTitle_Profit(String title,String amount,Color amountColor) {
    return Container(
      color: Color(0xFFC5F5E3),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.green),
            ),
            Text(
              amount,
              style: TextStyle(fontSize: 14, color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildRowItem(String title, String amount, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 14, color: amountColor),
          ),
        ],
      ),
    );
  }
}
