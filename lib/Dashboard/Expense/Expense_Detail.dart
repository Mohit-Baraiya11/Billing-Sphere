import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../Home/Prefered_underline_appbar.dart';

class Expense_Detail extends StatefulWidget {
  String Expense_Category;
  Expense_Detail({super.key,required this.Expense_Category});
  @override
  State<Expense_Detail> createState() => _Expense_DetailState(Expense_Category: this.Expense_Category);
}

class _Expense_DetailState extends State<Expense_Detail> {
  _Expense_DetailState({required this.Expense_Category});
  String Expense_Category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: Text("${Expense_Category}",style: TextStyle(fontSize: 18),),
        bottom: Prefered_underline_appbar(),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Remix.search_2_line)),
          IconButton(onPressed: (){}, icon: Icon(Remix.pencil_line)),
        ],
      ),
      backgroundColor: Colors.white,
      body: Container(
        height:double.infinity,
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Text("Total :",style: TextStyle(color: Colors.grey,fontSize: 13),),
                          Text("₹ 400",style: TextStyle(color: Colors.blueAccent,fontSize: 14,fontWeight: FontWeight.w500),),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: 2,
                    separatorBuilder: (context,index){
                      return Divider(color: Colors.grey.shade300,thickness: 1,);
                    },
                    itemBuilder: (context,index){
                      return Container(
                        padding: EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Total : ₹ 400",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                Text("Balance : ₹ 400",style: TextStyle(fontWeight: FontWeight.w500,fontSize: 14,),),
                              ],
                            ),
                            Row(
                              children: [
                                Text("02 Feb",style: TextStyle(color: Colors.grey,fontSize: 12),),
                                IconButton(onPressed: (){}, icon: Icon(Remix.more_2_line)),
                              ],
                            ),
                          ],
                        ),
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
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(14),
                    backgroundColor: Color(0xFFE03537),
                  ),
                  onPressed: () {

                  },
                  child:Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Remix.add_circle_fill,color: Colors.white,size: 20,),
                      const SizedBox(width: 8),
                      Text(
                        "Add Expenses",
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
