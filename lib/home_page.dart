// Copyright 2022 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dogwood_app/animal.dart';
import 'package:dogwood_app/animal_dialog.dart';
import 'package:dogwood_app/detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_state.dart';
import 'src/authentication.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  final TextEditingController textController = TextEditingController();
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';

  Future<void> handleNewAnimal(String animalName) async {
    Animal newAnimal = Animal(
      name: animalName,
      vaccineStatus: false,
      dewormStatus: false,
      fleaStatus: false,
      fecalStatus: false,
    );

    DocumentReference docRef = await FirebaseFirestore.instance
        .collection('animals')
        .add({
          ...newAnimal.toMap(), // add the new animal to collection
          'createdAt': FieldValue.serverTimestamp(), // keep track of when animal was created to sort by most recent
        }); 
    newAnimal.id = docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) {
          return ListView(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  AuthFunc( // this is the login/logout button
                    loggedIn: appState.loggedIn,
                    signOut: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                  if (appState.loggedIn) SizedBox(width: 10), // only show search box if logged in
                  Expanded(
                    child: TextField(
                      controller: widget.textController,
                      decoration: InputDecoration(
                        labelText: 'Search by name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase(); // ignore case differences in search
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 10.0,
                ),
                child: StreamBuilder<QuerySnapshot>( // build the list based on firestore database
                  stream: FirebaseFirestore.instance
                      .collection('animals')
                      .orderBy('createdAt', descending: true) // order by most recently added
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Please log in to view animals'); // if anything is going wrong, probably not logged in
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final animals = snapshot.data!.docs // create list of animals based on firestore data
                        .map(
                          (doc) => Animal.fromMap(
                            doc.data() as Map<String, dynamic>,
                            id: doc.id,
                          ),
                        )
                        .toList();
                    final filteredAnimals = animals.where((animal) {
                      return animal.name.toLowerCase().contains(searchQuery); // if something in search box, only show animals that contain letters from search
                    }).toList();

                    return Column(
                      children: filteredAnimals.map((animal) {
                        return ListTile(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 2, color: Colors.lightBlue),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(animal.name),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailPage(animal: animal), // if animal tile is pressed, go to its page
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ApplicationState>(
        builder: (context, appState, _) => appState.loggedIn
            ? FloatingActionButton(
                key: const Key("AddButton"),
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
                child: const Icon(Icons.add),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AnimalDialog(onListAdded: handleNewAnimal),
                  );
                },
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
