import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omegaproject/Fisher/seller_fisher.dart';

import '../main.dart';
import '../vendeur/accueil.dart';
import '../vendeur/home_vendeur.dart';
import 'Fisher_interfaces/Map.dart';
import 'Fisher_interfaces/Map_Fish.dart';
import 'Fisher_interfaces/Weather_interface/weather_screen.dart';

class Interface extends StatefulWidget {
  @override
  _InterfaceState createState() => _InterfaceState();
}

class _InterfaceState extends State<Interface> {
  String? fullName;
  String? creationDate;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> assignUniqueIdToUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final counterDoc = FirebaseFirestore.instance.collection('Metadata').doc('user_counter');

        // Use a transaction to safely increment the counter
        final newId = await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(counterDoc);

          int currentCounter = snapshot.exists ? snapshot['counter'] as int : 0;
          int nextCounter = currentCounter + 1;

          transaction.set(counterDoc, {'counter': nextCounter});

          return nextCounter;
        });

        // Pad the ID to ensure a consistent format like 0001
        String formattedId = newId.toString().padLeft(4, '0');

        // Save the unique ID to the user's Firestore document
        await FirebaseFirestore.instance.collection('Fisher_users').doc(user.uid).update({
          'uid': formattedId,
        });

      } catch (e) {
        print('Error assigning unique ID: $e');
      }
    }
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userData = await FirebaseFirestore.instance
            .collection('Fisher_users')
            .doc(user.uid)
            .get();
        setState(() {
          fullName = userData['full_name'];
          creationDate = userData['uid']; // Fetch the unique ID
          //creationDate = user.metadata.creationTime?.toString().split(' ')[0];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("   Fisherman's Home  ",
          style: TextStyle(
            color: Colors.black, // Change text color if needed
            fontSize: 20, // Set the font size for the title
            // Optional: make the title bold
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Navigate to the login screen after signing out
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => MyApp()), // Replace LoginScreen() with your actual login widget
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF012B2E), Color(0xFF0F4235)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              // "Compte" Section
              Card(
                color: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.account_circle, size: 40),
                          Text(
                             '0001',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        fullName ?? 'Nom Prénom',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 70),
              // Main Content
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  children: [
                    _buildGridTile(context, 'Store', 'assets/images/store.jpg', Seller()),
                    _buildGridTile(context, 'Météo', 'assets/images/weather.jpg', WeatherScreen()),
                    _buildGridTile(context, 'Mapsfich', 'assets/images/mapfish.jpg', MapPage()),
                    _buildGridTile(context, 'Maps', 'assets/images/map.jpg', MapInterface()),
                  ],
                ),
              ),
              // Logout Button

            ],
          ),
        ),
      ),
    );
  }


  Widget _buildGridTile(BuildContext context, String title, String imagePath, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent, // Background removed as the image will cover it
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
              Container(
                color: Colors.black.withOpacity(0.5), // Adds a semi-transparent overlay
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
