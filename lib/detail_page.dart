import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogwood_app/animal.dart';
import 'package:dogwood_app/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DetailPage extends StatefulWidget {
  final Animal animal;
  const DetailPage({super.key, required this.animal});

  @override
  State<DetailPage> createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  bool vaccineCheck = false;
  bool dewormCheck = false;
  bool fleaCheck = false;
  bool fecalCheck = false;
  String? vaccineType;
  String? dewormType;
  String? fleaType;
  String? fecalLocation;
  DateTime? vaccineTime;
  DateTime? dewormTime;
  DateTime? fleaTime;
  DateTime? fecalTime;
  final ImageController imageController = ImageController();
  String? recognizedNumber;
  TextEditingController _numberController = TextEditingController(text: '');
  String? microchipNum;

  Future<String> recognizeText(File imageFile) async { // https://pub.dev/packages/google_mlkit_text_recognition
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    await textRecognizer.close();
    return recognizedText.text;
  }

  String extractNums(String text) {
    final regex = RegExp(r'\d+'); // looks for numbers (digits) only
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)).join(', '); // separate different sets of numbers with commas in case extra numbers scanned. It's a little buggy, idk how to fix
  }

  @override
  void initState() { // all of this is so if the info already exists in firestore database, that info is loaded here instead of starting empty
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

    microchipNum = widget.animal.microchipNum;

    _numberController = TextEditingController(text: recognizedNumber ?? ''); // if there is a microchip number found, put that here. If not, leave it empty
  }

  @override
  void dispose() { // get rid of controller and stuff when the detail page is destroyed
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _saveToFirestore() async { // save all the animal's newly updated information to it's object in firestore
    final docRef = FirebaseFirestore.instance
        .collection('animals')
        .doc(widget.animal.id);
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
    widget.animal.microchipNum = microchipNum;

    try {
      await docRef.set(widget.animal.toMap(), SetOptions(merge: true));
      print('Animal saved successfully'); // idk why it's telling me not to print stuff, but I'm leaving it because it helps with debugging
    } catch (e) {
      print('Error saving animal: $e');
    }
  }

  Future<void> _deleteFromFirestore() async {
    final docRef = FirebaseFirestore.instance
        .collection('animals')
        .doc(widget.animal.id); 
    await docRef.delete();
  }

  final List<String> vaccineTypes = ['DAP', 'DAPL', 'LEPTO', 'FVRCP', 'Other'];

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

  final List<String> fecalLocations = ['AK', 'Dr. B', 'NT', 'TAH', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.animal.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: vaccineCheck,
                    onChanged: (bool? value) {
                      setState(() => vaccineCheck = value ?? false);
                    },
                    activeColor: Colors.lightBlue,
                  ),
                  Text("Vaccine"),
                  if (vaccineCheck) ...[
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      hint: Text("Type"),
                      value: vaccineType,
                      items: vaccineTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => vaccineType = value);
                      },
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      child: Text(
                        vaccineTime == null
                            ? "${DateTime.now().toLocal()}".split(' ')[0]
                            : "${vaccineTime!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => vaccineTime = picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: dewormCheck,
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
                      items: dewormTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => dewormType = value);
                      },
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      child: Text(
                        dewormTime == null
                            ? "${DateTime.now().toLocal()}".split(' ')[0]
                            : "${dewormTime!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => dewormTime = picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: fleaCheck,
                    onChanged: (bool? value) {
                      setState(() => fleaCheck = value ?? false);
                    },
                    activeColor: Colors.lightBlue,
                  ),
                  Text("Flea"),
                  if (fleaCheck) ...[
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      hint: Text("Type"),
                      value: fleaType,
                      items: fleaTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => fleaType = value);
                      },
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      child: Text(
                        fleaTime == null
                            ? "${DateTime.now().toLocal()}".split(' ')[0]
                            : "${fleaTime!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => fleaTime = picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: fecalCheck,
                    onChanged: (bool? value) {
                      setState(() => fecalCheck = value ?? false);
                    },
                    activeColor: Colors.lightBlue,
                  ),
                  Text("Fecal"),
                  if (fecalCheck) ...[
                    SizedBox(width: 12),
                    DropdownButton<String>(
                      hint: Text("Location"),
                      value: fecalLocation,
                      items: fecalLocations
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => fecalLocation = value);
                      },
                    ),
                    SizedBox(width: 12),
                    OutlinedButton(
                      child: Text(
                        fecalTime == null
                            ? "${DateTime.now().toLocal()}".split(' ')[0]
                            : "${fecalTime!.toLocal()}".split(' ')[0],
                      ),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setState(() => fecalTime = picked);
                        }
                      },
                    ),
                  ],
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text('Microchip'),
                  SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      final cameras = await availableCameras(); // refer to previous work with cameras https://github.com/kbgrizb/SnapShot-Journal
                      final firstCamera = cameras.first;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CameraScreen(
                            camera: firstCamera,
                            imageController: imageController,
                          ),
                        ),
                      );
                      if (imageController.image != null) {
                        final recognizedText = await recognizeText(
                          imageController.image!,
                        );
                        final number = extractNums(recognizedText);
                        setState(() {
                          recognizedNumber = number;
                          _numberController.text = number;
                        });
                      }
                    },
                    iconSize: 30,
                    icon: const Icon(Icons.add, color: Colors.lightBlue),
                  ),
                  if (microchipNum != null && microchipNum!.isNotEmpty) ...[ // if animal has a microchip # display it here
                    SizedBox(width: 12),
                    Text(
                      microchipNum!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 12),
              if (imageController.image != null) ...[ // show image of microchip number for comparison to recognized text
                ClipRect(
                  child: Image.file(
                    imageController.image!,
                    width: 400,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _numberController,
                  decoration: InputDecoration(
                    labelText: 'Number Found - Tap to edit',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    recognizedNumber = value; // allow user to fix microchip number if needed
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 30),
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                heroTag: "delete",
                onPressed: () async {
                  final confirmDelete = await showDialog<bool>( // confirm deletion dialog
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: const Text(
                          'Are you sure you want to delete this animal?',
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.lightBlue),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirmDelete == true) {
                    await _deleteFromFirestore();
                    Navigator.pop(context); // User confirmed deletion
                  }
                },
                backgroundColor: Colors.white,
                label: Text(
                  'Delete Animal',
                  style: TextStyle(
                    color: Colors.lightBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FloatingActionButton(
                onPressed: () async { // when you press save, update all the animal's info
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

                  widget.animal.microchipNum = recognizedNumber;
                  microchipNum = recognizedNumber;

                  
                  await _saveToFirestore(); // save all updates to firestore before closing page
                  Navigator.pop(context);
                },
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                child: Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
