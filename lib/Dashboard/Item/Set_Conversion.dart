import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_signup/Home/Prefered_underline_appbar.dart';
import 'package:remixicon/remixicon.dart';

class Set_Conversion extends StatefulWidget {
  const Set_Conversion({super.key});
  @override
  State<Set_Conversion> createState() => _Set_ConversionState();
}

class _Set_ConversionState extends State<Set_Conversion> {


  final List<String> units = [
    'BAGS (Bag)',
    'BOTTLES (Btl)',
    'BOX (Box)',
    'BUNDLES (Bdl)',
    'CANS (Can)',
    'CARTONS (Ctn)',
    'DOZENS (Dzn)',
    'GRAMMES (Gm)',
    'KILOGRAMS (Kg)',
    'LITRE (Ltr)',
    'METERS (Mtr)',
    'MILLILITRE (Ml)',
    'NUMBERS (Nos)',
    'PACKS (Pac)',
    'PAIRS (Prs)',
    'PIECES (Pcs)',
    'QUINTAL (Qtl)',
    'ROLLS (Rol)',
    'SQUARE FEET (Sqf)',
    'SQUARE METERS (Sqm)',
    'TABLETS (Tbs)',
  ];



  TextEditingController  base_unit_controller = TextEditingController();
  FocusNode base_unit_focusmode = FocusNode();

  TextEditingController  second_unit_controller = TextEditingController();
  FocusNode second_unit_focusmode = FocusNode();

  TextEditingController  conversion_rate_controller = TextEditingController();
  FocusNode conversion_rate_focusnode = FocusNode();
  bool is_conversion_rate_focused = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        surfaceTintColor: Colors.white,
        title: Text("Set Conversion"),
        backgroundColor: Colors.white,
        bottom: Prefered_underline_appbar(),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              height: 65,
              child: TextField(
                onTap: (){
                  showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      backgroundColor: Colors.white,
                      context: context, builder: (context){
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.95,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Select Units to Add",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              IconButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Remix.close_line)
                              ),
                            ],
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: units.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  title: Text(units[index]),
                                  onTap: () {
                                    setState(() {
                                      base_unit_controller.text = units[index];
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                },
                controller: base_unit_controller,
                focusNode: base_unit_focusmode,
                decoration: InputDecoration(
                  labelText: "Base Unit",
                  suffixIcon: Icon(Remix.arrow_down_s_line),
                  labelStyle: TextStyle(color: Colors.grey),
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
            ),

            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              height: 65,
              child: TextField(
              onTap: (){
                showModalBottomSheet(
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    backgroundColor: Colors.white,
                    context: context, builder: (context){
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.95,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Select Units to Add",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                            IconButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                },
                                icon: Icon(Remix.close_line)
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: units.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                title: Text(units[index]),
                                onTap: () {
                                  setState(() {
                                    second_unit_controller.text = units[index];
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                });
              },
              controller: second_unit_controller,
              focusNode: second_unit_focusmode,
              decoration: InputDecoration(
                  labelText: "Secondory Unit",
                  suffixIcon: Icon(Remix.arrow_down_s_line),
                  labelStyle: TextStyle(color: Colors.grey),
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
            ),


            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
              height: 65,
              child: TextField(
              controller: conversion_rate_controller,
              focusNode: conversion_rate_focusnode,
              onChanged: (value){
                setState(() {
                  conversion_rate_controller.text = value;
                });
              },
              decoration: InputDecoration(
                  labelText: "Conversion Rate",
                  suffixIcon: Icon(Remix.arrow_down_s_line),
                  labelStyle: TextStyle(color: Colors.grey),
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
            ),

            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("1 ${base_unit_controller.text} = ${conversion_rate_controller.text} ${second_unit_controller.text}"),
            ),
          ],
        ),

    );
  }
}
