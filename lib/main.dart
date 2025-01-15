import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:omegaproject/Fisher/Login_Fisher.dart';
import 'package:omegaproject/auth/Login_Interface.dart';
import 'package:omegaproject/vendeur/accueil.dart';

import 'package:omegaproject/visiteurs/home_visiteur.dart';

import 'Fisher/Fisher_auth/register.dart'; // Import the MatchYourStyleScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: 'Detecting Fish',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const UserSelectionPage(),
        '/login/pecheur': (context) => Register(),
        '/login/vendeur': (context) => RegisterScreen(), // Route to LoginInterface
        '/home_vendeur': (context) => StorePage(), // Home page for sellers
        /*'/StorePage': (context) =>
            StorePage(),*/ // StorePage route  CardInfoScreen

        /*'/MatchYourStyleScreen': (context) =>
            const MatchYourStyleScreen(), // Add MatchYourStyleScreen route*/
      },

    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/');
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/FigmaFishing.png'), // Path to your image
            fit: BoxFit.cover, // Makes the image cover the entire screen
          ),
        ),
      ),
    );
  }
}


class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFF012B2E), // Updated background color to match the design
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.jpeg'), // Replace with your logo path
          const SizedBox(height: 60),
          CustomButton(
            text: 'Fisherman',
            onPressed: () {
              Navigator.pushNamed(context, '/login/pecheur');
            },
          ),
          CustomButton(
            text: 'Seller',
            onPressed: () async {
              // Vérifier si le vendeur est déjà connecté
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                // Rediriger vers StorePage si connecté
                Navigator.pushReplacementNamed(context, '/login/vendeur');
              } else {
                // Sinon, rediriger vers la page de connexion
                Navigator.pushNamed(context, '/login/vendeur');
              }
            },
          ),
          CustomButton(
            text: 'Visitor',
            onPressed: () {
              // Rediriger directement vers MatchYourStyleScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VisitorProductsScreen()),
              );
            },
          ),
          const SizedBox(height: 30),
          /*TextButton(
            onPressed: () {
              // Code to change language here
            },
            child: const Text(
              'changer la langue',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),*/
        ],
      ),
    );
  }
}

// CustomButton widget for consistency in button design
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 40, vertical: 12), // Controls outer spacing
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF20D0C4), // Button color from the design
          padding:
              const EdgeInsets.symmetric(vertical: 20), // Controls inner height
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Rounded corners
          ),
          minimumSize: const Size(250, 60), // Sets minimum size (width, height)
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 22, // Font size inside the button
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
