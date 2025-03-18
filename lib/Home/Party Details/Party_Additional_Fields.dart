import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';

class Party_Additional_Fields extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PartyAdditionalFields();
}

class PartyAdditionalFields extends State<Party_Additional_Fields> {

  bool field_1 = false;
  bool field_2 = false;
  bool field_3 = false;
  bool date_field = false;

  bool field_1_print = true;
  bool field_2_print = true;
  bool field_3_print = true;
  bool date_field_print = true;

  String date_format = "dd/mm/yyyy";
  List<String> date_format_list = ["dd/mm/yyyy","mm/yyyy"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Party Addional Field",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFDAE7F2),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 0.5,
              color: Color(0xFFDAE7F2),
            ),
          ]
        ),
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the screen
                },
                child: Text("CANCEL"),
              ),
            ),
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () {
                  // Implement Save Logic Here
                },
                child: Text("SAVE"),
              ),
            ),
          ],
        ),
      ),

      body: Container(
        color: Colors.white,
        height: double.infinity,
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                children: [
                  Align(
                      alignment:Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Party Additional Fields"),
                      )
                  ),
                  Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blue,
                          value: field_1,
                          onChanged: (bool?newvalue){
                            setState(() {
                              field_1 = newvalue??false;
                            });
                          }
                      ),
                      Text("Addional Field 1"),
                    ],
                  ),
                  if (field_1 == true)
                  Padding(
                  padding: const EdgeInsets.only(left: 60.0, bottom: 10,right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          labelText: "Field Name*",
                          labelStyle: TextStyle(color: Colors.black),
                          floatingLabelStyle: TextStyle(color: Color(0xFF0078AA)),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Adjust spacing
                      Row(
                        children: [
                          Spacer(),
                          Text("Show in print", style: TextStyle(fontSize: 14)),
                          SizedBox(width: 10,),
                          Switch(
                            activeColor: Color(0xFFDAE7F2),
                            activeTrackColor: Colors.blue[100],
                            value: field_1_print,
                            onChanged: (bool? newValue) {
                              setState(() {
                                field_1_print = newValue ?? false;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            
                  Row(
                    children: [
                      Checkbox(
                          activeColor: Colors.blue,
                          value: field_2,
                          onChanged: (bool?newvalue){
                            setState(() {
                              field_2 = newvalue??false;
                            });
                          }
                      ),
                      Text("Addional Field 2"),
                    ],
                  ),
                  if(field_2==true)
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, bottom: 10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Field Name*",
                              labelStyle: TextStyle(color: Colors.black),
                              floatingLabelStyle: TextStyle(color: Color(0xFF0078AA)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8), // Adjust spacing
                          Row(
                            children: [
                              Spacer(),
                              Text("Show in print", style: TextStyle(fontSize: 14)),
                              SizedBox(width: 10,),
                              Switch(
                                activeColor: Color(0xFFDAE7F2),
                                activeTrackColor: Colors.blue[100],
                                value: field_2_print,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    field_2_print = newValue ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            
                  Row(
                    children: [
                      Checkbox(
                          activeColor: Colors.blue,
                          value: field_3,
                          onChanged: (bool?newvalue){
                            setState(() {
                              field_3 = newvalue??false;
                            });
                          }
                      ),
                      Text("Addional Field 3"),
                    ],
                  ),
                  if(field_3==true)
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, bottom: 10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Field Name*",
                              labelStyle: TextStyle(color: Colors.black),
                              floatingLabelStyle: TextStyle(color: Color(0xFF0078AA)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8), // Adjust spacing
                          Row(
                            children: [
                              Spacer(),
                              Text("Show in print", style: TextStyle(fontSize: 14)),
                              SizedBox(width: 10,),
                              Switch(
                                activeColor: Color(0xFFDAE7F2),
                                activeTrackColor: Colors.blue[100],
                                value: field_3_print,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    field_3_print = newValue ?? false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            
                  Row(
                    children: [
                      Checkbox(
                          activeColor: Colors.blue,
                          value: date_field,
                          onChanged: (bool?newvalue){
                            setState(() {
                              date_field = newvalue??false;
                            });
                          }
                      ),
                      Text("Date Field"),
                    ],
                  ),
                  if(date_field==true)
                    Padding(
                      padding: const EdgeInsets.only(left: 60.0, bottom: 10,right: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Field Name*",
                              labelStyle: TextStyle(color: Colors.black),
                              floatingLabelStyle: TextStyle(color: Color(0xFF0078AA)),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF0078AA), width: 2.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                        DropdownButton<String>(
                            value: date_format,
                            hint: Text('Date Format'),
                            onChanged: (String? newValue) {
                            setState(() {
                                date_format = newValue!;
                            });
                            },
                            items: date_format_list.map<DropdownMenuItem<String>>((String value)
                            {
                              return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                              );
                            }).toList(),
                            ),
                          ]
                        ),
                    ),
                  if(date_field==true)
                    Row(
                       children: [
                              Spacer(),
                              Text("Show in print", style: TextStyle(fontSize: 14)),
                              SizedBox(width: 10,),
                              Switch(
                                activeColor: Color(0xFFDAE7F2),
                                activeTrackColor: Colors.blue[100],
                                value: date_field_print,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    date_field_print = newValue ?? false;
                                  });
                                },
                              ),
                            ],
                          ),



                ],
                      ),
                ),
                  ),
          ),

    );
  }
}
