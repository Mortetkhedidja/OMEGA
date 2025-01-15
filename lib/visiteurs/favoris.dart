import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Récupérer l'utilisateur actuellement connecté
    final currentUser = FirebaseAuth.instance.currentUser;

    // Si l'utilisateur n'est pas connecté, afficher un message
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Favoris"),
          backgroundColor: Color(0xFF0F8A77),
        ),
        body: Center(
            child: Text("Veuillez vous connecter pour voir vos favoris.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Favoris"),
        backgroundColor: Color(0xFF0F8A77),
      ),
      // Utilisation d'un StreamBuilder pour récupérer les données en temps réel depuis Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid) // Document spécifique à l'utilisateur actuel
            .collection(
                'favorites') // Sous-collection 'favorites' de l'utilisateur
            .snapshots(),
        builder: (context, snapshot) {
          // Si la connexion est en cours, afficher un indicateur de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Si aucun favori n'est trouvé, afficher un message
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Aucun favori trouvé."));
          }

          // Récupérer tous les produits favoris de l'utilisateur
          final favoriteProducts = snapshot.data!.docs;

          // Affichage de la liste des favoris
          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final favoriteProductId = favoriteProducts[index].id;

              // FutureBuilder pour charger les détails de chaque produit favori
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection(
                        'vente') // Collection 'vente' où sont stockés les produits
                    .doc(favoriteProductId) // Document du produit spécifique
                    .get(),
                builder: (context, snapshot) {
                  // Afficher un indicateur de chargement pendant le chargement des détails du produit
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  // Si le produit n'est pas trouvé, afficher un message
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text("Produit introuvable");
                  }

                  // Récupérer les données du produit en tant que map
                  final product = snapshot.data!.data() as Map<String, dynamic>;

                  // Affichage de chaque produit en tant que ProductCard
                  return ProductCard(
                    name: product['name'],
                    price: product['price'],
                    imageUrl: product['imageUrl'],
                    sellerFullName: product['sellerFullName'],
                    isFavorite:
                        true, // Le produit est forcément en favori dans cette page
                    onFavoriteToggle:
                        () {}, // Action désactivée dans cette page
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final String sellerFullName;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ProductCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sellerFullName,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Informations du produit
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom du produit
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Prix du produit
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Nom du vendeur
                  Text(
                    'Vendu par: $sellerFullName',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Icône de favori
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle, // Action désactivée ici
            ),
          ],
        ),
      ),
    );
  }
}
