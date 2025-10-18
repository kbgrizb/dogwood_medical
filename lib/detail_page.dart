
import 'package:dogwood_app/animal.dart';
import 'package:flutter/material.dart';           


class DetailPage extends StatefulWidget {
  final Animal animal;
  const DetailPage({super.key, required this.animal});

  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage>{
  bool vaccineCheck = false;
  bool dewormCheck = false;
  bool fleaCheck = false;
  bool fecalCheck = false;
  String? vaccineType;
  String? dewormType;
  String? fleaType;
  String?fecalLocation;
  DateTime? vaccineTime;
  DateTime? dewormTime;
  DateTime? fleaTime;
  DateTime? fecalTime;

  @override
  void initState() {
    super.initState();
    vaccineCheck = widget.animal.vaccineStatus;
    vaccineType = widget.animal.vaccineType;
    vaccineTime = widget.animal.vaccineTime;

    dewormCheck = widget.animal.dewormStatus;
    dewormType = widget.animal.dewormType;
    dewormTime = widget.animal.dewormTime;

    fleaCheck = widget.animal.fleaStatus;
    fleaType = widget.animal.fleaType;
    fleaTime = widget.animal.fleaTime;

    fecalCheck = widget.animal.fecalStatus;
    fecalLocation = widget.animal.fecalLocation;
    fecalTime = widget.animal.fecalTime;
  }

  final List<String> vaccineTypes = [
    'DAP',
    'DAPL',
    'LEPTO',
    'FVRCP',
    'Other',
  ];

  final List<String> dewormTypes = [
    'Metro',
    'Panacur',
    'Ponazuril',
    'Strongid',
    'Other',
  ];

  final List<String> fleaTypes = [
    'Bravecto',
    'Capstar',
    'Cheristin',
    'Credelio Quattro',
    'First Shield Trio',
    'Nexgard Plus',
    'Revolution',
    'Other',
  ];

  final List<String> fecalLocations = [
    'AK',
    'Dr. B',
    'NT',
    'TAH',
    'Other',
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.animal.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: vaccineCheck, 
                  onChanged: (bool? value) {setState(() => vaccineCheck = value ?? false);},
                  activeColor: Colors.lightBlue,
                  ),
                  Text("Vaccine"),
                  if (vaccineCheck) ...[
                    
                  SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: Text("Type"),
                    value: vaccineType,
                    items: vaccineTypes.map((type) => DropdownMenuItem(
                            value: type, child: Text(type))).toList(),
                    onChanged: (value) {
                      setState(() => vaccineType = value);
                    },
                  ),
                   SizedBox(width: 12),
                  OutlinedButton(
                    child: Text(vaccineTime == null
                        ? "${DateTime.now().toLocal()}".split(' ')[0]
                        : "${vaccineTime!.toLocal()}".split(' ')[0]),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030));
                      if (picked != null) {
                        setState(() => vaccineTime = picked);
                      }
                    },
                  ),
                  ]
              ],),
              Row(
                children: [
                  Checkbox(value: dewormCheck,
                  onChanged: (bool? value) {
                    setState(() => dewormCheck = value ?? false);
                  },
                  activeColor: Colors.lightBlue,
                  ),
                  Text("Deworm"),
                if (dewormCheck) ...[
                  SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: Text("Type"),
                    value: dewormType,
                    items: dewormTypes.map((type) => DropdownMenuItem(
                            value: type, child: Text(type))).toList(),
                    onChanged: (value) {
                      setState(() => dewormType = value);
                    },
                  ),
                   SizedBox(width: 12),
                  OutlinedButton(
                    child: Text(dewormTime == null
                        ? "${DateTime.now().toLocal()}".split(' ')[0]
                        : "${dewormTime!.toLocal()}".split(' ')[0]),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030));
                      if (picked != null) {
                        setState(() => dewormTime = picked);
                      }
                    },
                  ),
                ],
          ]),
          Row(
              children: [
                Checkbox(
                  value: fleaCheck, 
                  onChanged: (bool? value) {setState(() => fleaCheck = value ?? false);},
                  activeColor: Colors.lightBlue,
                  ),
                  Text("Flea"),
                  if (fleaCheck) ...[
                
                  SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: Text("Type"),
                    value: fleaType,
                    items: fleaTypes.map((type) => DropdownMenuItem(
                            value: type, child: Text(type))).toList(),
                    onChanged: (value) {
                      setState(() => fleaType = value);
                    },
                  ),
                  SizedBox(width: 12),
                  OutlinedButton(
                    child: Text(fleaTime == null
                        ? "${DateTime.now().toLocal()}".split(' ')[0]
                        : "${fleaTime!.toLocal()}".split(' ')[0]),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030));
                      if (picked != null) {
                        setState(() => fleaTime = picked);
                      }
                    },
                  ),
                  ]
              ],),
              Row(
              children: [
                Checkbox(
                  value: fecalCheck, 
                  onChanged: (bool? value) {setState(() => fecalCheck = value ?? false);},
                  activeColor: Colors.lightBlue,
                  ),
                  Text("Fecal"),
                  if (fecalCheck) ...[
                    
                  SizedBox(width: 12),
                  DropdownButton<String>(
                    hint: Text("Location"),
                    value: fecalLocation,
                    items: fecalLocations.map((type) => DropdownMenuItem(
                            value: type, child: Text(type))).toList(),
                    onChanged: (value) {
                      setState(() => fecalLocation = value);
                    },
                  ),
                   SizedBox(width: 12),
                  OutlinedButton(
                    child: Text(fecalTime == null
                        ? "${DateTime.now().toLocal()}".split(' ')[0]
                        : "${fecalTime!.toLocal()}".split(' ')[0]),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030));
                      if (picked != null) {
                        setState(() => fecalTime = picked);
                      }
                    },
                  ),
                  ]
              ],),
              SizedBox(height: 15,),
              Row(
                children: [
                  Text('Microchip'),
                  SizedBox(width: 12),
                  IconButton( 
                    onPressed: null,
                    iconSize: 30,
                    icon: const Icon(
                      Icons.add,
                      color: Colors.lightBlue,
                      ),
                    )
                    ],
                    ),
          ],
          ),
      ),
      floatingActionButton: FloatingActionButton(
      onPressed: () {
        widget.animal.vaccineStatus = vaccineCheck;
        widget.animal.vaccineType = vaccineType;
        widget.animal.vaccineTime = vaccineTime;

        widget.animal.dewormStatus = dewormCheck;
        widget.animal.dewormType = dewormType;
        widget.animal.dewormTime = dewormTime;

        widget.animal.fleaStatus = fleaCheck;
        widget.animal.fleaType = fleaType;
        widget.animal.fleaTime = fleaTime;

        widget.animal.fecalStatus = fecalCheck;
        widget.animal.fecalLocation = fecalLocation;
        widget.animal.fecalTime = fecalTime; 
        Navigator.pop(context, widget.animal);},
      backgroundColor: Colors.lightBlue,
      foregroundColor: Colors.white,
      child: Text('DONE'),
      ),
      );
  }
}