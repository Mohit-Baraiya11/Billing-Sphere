import 'package:flutter/material.dart';
import 'package:google_signup/Dashboard/Bank/Bank_Adjustment.dart';
import 'package:google_signup/Dashboard/Bank/Bank_Transfer.dart';
import 'package:google_signup/Dashboard/Bank/Bank_to_Bank_Transfer.dart';
import 'package:remixicon/remixicon.dart';

import '../../Home/Prefered_underline_appbar.dart';
import '../../Home/Transaction Details/Show All/add_bank_account.dart';

class Bank_Details extends StatefulWidget {
  @override
  State<Bank_Details> createState() => _Bank_Details();
}

class _Bank_Details extends State<Bank_Details> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('Bank Details', style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Add_Bank_Account()));
              },
              icon: Icon(Remix.pencil_line)
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
                    color: Colors.white,
                    child: Text("HDFC",style: TextStyle(fontSize: 16),),
                  ),
                  SizedBox(height: 10,),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),
                      decoration: BoxDecoration(
                        color:Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Balance",style: TextStyle(fontSize: 13,color: Colors.black54),),
                          SizedBox(height: 10,),
                          Text(" ₹58.00",style: TextStyle(fontSize: 18,color: Color(0xFF38C782),),),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child:Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Transaction Details"),
                                    Text("Amount")
                                  ],
                                ),
                              ),
                              Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: 1,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text('Payment-out - Mitesh'),
                                          subtitle: Text('06 Feb 2025'),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                          trailing: Text(
                                            '₹58.00',
                                            style: TextStyle(color:Color(0xFFE03537), fontWeight: FontWeight.w500,fontSize: 16),
                                          ),
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  )

                ],
              ),

            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    backgroundColor: Color(0xFFE03537),
                  ),
                  onPressed: () {
                    _showTransferOptions(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Deposit/Withdraw",
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
  void _showTransferOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          color: Colors.white,
          height: MediaQuery.of(context).size.height*0.35,
          child: Column(
            children: [
              SizedBox(height:20,),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BankTransferPage(transferType: "Deposit",)));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.bank_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Cash\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>BankTransferPage(transferType: "Withdraw",)));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.bank_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Cash to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_To_Bank_Transfer()));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.bank_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),
                    Expanded(
                      child: Center(
                          child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Bank_Adjustment()));
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 90,
                                  width: 90,
                                  padding:EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(90)
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                        Icon(Remix.arrow_right_line,size: 18,),
                                        Icon(Remix.money_rupee_circle_line,size: 18,),
                                      ],
                                    ),
                                  ),
                                ),
                                Text("Bank to Bank\n Transfer",style: TextStyle(fontSize: 14),textAlign: TextAlign.center,)
                              ],
                            ),
                          )
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

}