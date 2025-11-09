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

    DocumentReference
    docRef = await FirebaseFirestore.instance.collection('animals').add({
      ...newAnimal.toMap(), // add the new animal to collection
      'createdAt':
          FieldValue.serverTimestamp(), // keep track of when animal was created to sort by most recent
    });
    newAnimal.id = docRef.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('images/Logo3.png', height: 90, fit: BoxFit.contain),
            SizedBox(width: 10),
            Text('Home Page', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
      body: Consumer<ApplicationState>(
        builder: (context, appState, _) {
          return ListView(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  AuthFunc(
                    // this is the login/logout button
                    loggedIn: appState.loggedIn,
                    signOut: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                  if (appState.loggedIn)
                    SizedBox(width: 10), // only show search box if logged in
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextField(
                        controller: widget.textController,
                        decoration: InputDecoration(
                          labelText: 'Search by name',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF0A5879),
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value
                                .toLowerCase(); // ignore case differences in search
                          });
                        },
                      ),
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
                child: StreamBuilder<QuerySnapshot>(
                  // build the list based on firestore database
                  stream: FirebaseFirestore.instance
                      .collection('animals')
                      .orderBy(
                        'createdAt',
                        descending: true,
                      ) // order by most recently added
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Please log in to view animals',
                      ); // if anything is going wrong, probably not logged in
                    }
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final animals = snapshot
                        .data!
                        .docs // create list of animals based on firestore data
                        .map(
                          (doc) => Animal.fromMap(
                            doc.data() as Map<String, dynamic>,
                            id: doc.id,
                          ),
                        )
                        .toList();
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      return Text('Please log in to view animals');
                    }
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('animalViews') // animalViews = user-specific list of each animal the user has viewed
                          .snapshots(),
                      builder: (context, userViewsSnapshot) { // userViews = logged-in user's personal animalViews list
                        if (!userViewsSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final userViews = userViewsSnapshot.data!.docs;

                        for (var animal in animals) { // for each animal, match animal's id to user's animalViews id for said animal
                          final matchingDocs = userViews.where( 
                            (doc) => doc.id == animal.id,
                          );
                          if (matchingDocs.isNotEmpty) { // if matching id exists (animal has been viewed)
                            final viewDoc = matchingDocs.first; // viewDoc = matched animal id in user's view - used to access lastViewed time
                            animal.lastViewed = // update animal's lastViewed time in user's animalViews
                                viewDoc['lastViewed'] as Timestamp?; // my brain hurts. hopefully if i return to this code these comments will be enough to remember what i'm doing here. sorry future me i'm confused too but it works
                          }
                        }

                        final filteredAnimals = animals.where((animal) {
                          return animal.name.toLowerCase().contains(
                            searchQuery,
                          ); // if something in search box, only show animals that contain letters from search
                        }).toList();

                        return Column(
                          children: filteredAnimals.map((animal) {
                            return ListTile(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(width: 2, color: Colors.white),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor: Color(0xFF0A5879),
                              title: Row(
                                children: [
                                  Text(
                                    animal.name,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  if (animal.lastViewed == null || // if animal was never viewed
                                      (animal.lastUpdated != null && // or animal was updated more recently than it has been last viewed
                                          animal.lastUpdated!.compareTo(
                                                animal.lastViewed!,) > 0))
                                    Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Icon( // show "new" icon to show new info has been added
                                        Icons.fiber_new,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      animal: animal,
                                    ), // if animal tile is pressed, go to its page
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
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
                backgroundColor: Color(0xFF0A5879),
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
