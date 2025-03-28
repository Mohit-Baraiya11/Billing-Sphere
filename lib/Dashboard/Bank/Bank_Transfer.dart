import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';

import '../../Home/Prefered_underline_appbar.dart';

class BankTransferPage extends StatefulWidget {
  String transferType;
  BankTransferPage({required this.transferType});
  @override
  _BankTransferPageState createState() => _BankTransferPageState(transferType: this.transferType);
}

class _BankTransferPageState extends State<BankTransferPage> {
  _BankTransferPageState({required this.transferType});

  String transferType;
  TextEditingController dateController = TextEditingController();
  FocusNode date_focusenode = FocusNode();
  bool is_date_focused = false;
  Future<void> chhoseDate()async{
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2025, 3, 18),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }


  TextEditingController deposit_to_controller = TextEditingController();
  TextEditingController withdraw_from_controller = TextEditingController();

  TextEditingController amount_controller = TextEditingController();
  FocusNode amount_focusnode = FocusNode();
  bool is_amount_focused = false;

  TextEditingController description_controller = TextEditingController();
  FocusNode description_focusnode = FocusNode();
  bool is_description_focused = false;

  @override
  void initState() {
    super.initState();

    dateController.text = DateFormat("dd/MM/yyyy").format(DateTime.now());
    date_focusenode.addListener((){
      setState(() {
        is_date_focused = date_focusenode.hasFocus;
      });
    });

    amount_focusnode.addListener((){
      setState(() {
        is_amount_focused = amount_focusnode.hasFocus;
      });
    });

    description_focusnode.addListener((){
      setState(() {
        is_description_focused = description_focusnode.hasFocus;
      });
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: const Text(
          'Bank Transfer',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: Container(
        height: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Deposit'),
                            value: 'Deposit',
                            activeColor: Colors.blueAccent,
                            groupValue: transferType,
                            onChanged: (value) {
                              setState(() {
                                transferType = value.toString();
                                withdraw_from_controller.text = "Withdraw From";
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: const Text('Withdraw'),
                            value: 'Withdraw',
                            activeColor: Colors.blueAccent,
                            groupValue: transferType,
                            onChanged: (value) {
                              setState(() {
                                transferType = value.toString();
                                deposit_to_controller.text = "Cash";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    TextField(
                      readOnly: true,
                      controller: dateController,
                      focusNode: date_focusenode,
                      decoration: InputDecoration(
                        labelText: "Transfer Date",
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: is_date_focused?Colors.blueAccent:Colors.grey),
                        suffixIcon: Icon(Remix.calendar_2_line),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey,width: 1),
                        )
                      ),
                    ),

                    SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: (){
                        transferType=="Deposit"?
                        showModalBottomSheet(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)
                            ),
                            context: context, builder: (context){
                          return Container(
                            height: MediaQuery.of(context).size.height*0.2,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Deposit From",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                      IconButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Remix.close_line)
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Colors.grey.shade200,thickness: 1,),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: 2,
                                      itemBuilder: (context,index){
                                        return ListTile(
                                          onTap: (){
                                            setState(() {
                                              deposit_to_controller.text = "HDFC";
                                            });
                                            Navigator.pop(context);
                                          },
                                          dense: true,
                                          title: Text("HDFC"),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }
                                  ),
                                ),
                              ],
                            ),
                          );
                        }):null;
                      },
                      controller: deposit_to_controller,
                      decoration: InputDecoration(
                          labelText: "Deposit to",
                          labelStyle: TextStyle(color: Colors.grey),
                          suffixIcon:transferType=="Deposit"?Icon(Remix.arrow_down_s_line):null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          )
                      ),
                    ),

                    SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      onTap: (){
                        transferType=="Withdraw"?
                        showModalBottomSheet(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)
                            ),
                            context: context, builder: (context){
                          return Container(
                            height: MediaQuery.of(context).size.height*0.2,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 2),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Deposit From",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),),
                                      IconButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Remix.close_line)
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(color: Colors.grey.shade200,thickness: 1,),
                                Expanded(
                                  child: ListView.builder(
                                      itemCount: 2,
                                      itemBuilder: (context,index){
                                        return ListTile(
                                          onTap: (){
                                            setState(() {
                                              deposit_to_controller.text = "HDFC";
                                            });
                                            Navigator.pop(context);
                                          },
                                          dense: true,
                                          title: Text("HDFC"),
                                          visualDensity: VisualDensity.compact,
                                        );
                                      }
                                  ),
                                ),
                              ],
                            ),
                          );
                        }):null;
                      },
                      controller: withdraw_from_controller,
                      decoration: InputDecoration(
                          labelText: "Withdraw From",
                          labelStyle: TextStyle(color: Colors.grey),
                          suffixIcon: transferType=="Withdraw"?Icon(Remix.arrow_down_s_line):null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          )
                      ),
                    ),


                    SizedBox(height: 16),
                    TextField(
                      controller: amount_controller,
                      focusNode: amount_focusnode,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Enter Amount",
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle: TextStyle(color: is_amount_focused?Colors.blueAccent:Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent,width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey,width: 1),
                          )
                      ),
                    ),




                    SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: TextField(
                        controller: description_controller,
                        focusNode: description_focusnode,
                        maxLines: 5, // Allows multi-line input
                        decoration: InputDecoration(
                          labelText: "Enter Description (optional)",
                          labelStyle: TextStyle(color: Colors.grey),
                          floatingLabelStyle:
                          TextStyle(color: is_description_focused ? Colors.blueAccent : Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                      ),
                    ),


                    SizedBox(height: 16),
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 30,
                        color: Colors.grey,
                      ),
                    ),

                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Row(
                children:[
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(14),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        )
                      ),
                      onPressed: () {
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Save",
                            style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
