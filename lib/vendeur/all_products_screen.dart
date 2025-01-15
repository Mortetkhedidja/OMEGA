import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllProductsScreen extends StatefulWidget {
  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String? sellerEmail; // Email du vendeur connecté

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Récupérer l'email de l'utilisateur connecté
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        sellerEmail = user.email;
      });
    }
  }

  // Extraire tous les produits du vendeur actuel
  Stream<QuerySnapshot> _getProductsByCurrentUser() {
    return FirebaseFirestore.instance
        .collection('vente')
        .where('sellerEmail', isEqualTo: sellerEmail)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tous les produits")),
      body: sellerEmail == null
          ? Center(
              child:
                  CircularProgressIndicator()) // Affichage en cours de chargement
          : StreamBuilder<QuerySnapshot>(
              stream: _getProductsByCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Une erreur est survenue"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Aucun produit trouvé"));
                }
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> product =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(product['name']),
                      subtitle: Text("${product['price']} €"),
                      leading: Image.network(
                        product['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
