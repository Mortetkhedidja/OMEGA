import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisitorProductsScreen extends StatefulWidget {
  const VisitorProductsScreen({super.key});

  @override
  _VisitorProductsScreenState createState() => _VisitorProductsScreenState();
}

class _VisitorProductsScreenState extends State<VisitorProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  Future<String> getSellerName(String sellerEmail) async {
    try {
      // First, try fetching from 'users' collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: sellerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['full_name'] ?? 'Vendeur Inconnu';
      }

      // If not found in 'users', try fetching from 'Fish_users' collection
      final fishUsersSnapshot = await FirebaseFirestore.instance
          .collection('Fisher_users')
          .where('email', isEqualTo: sellerEmail)
          .get();

      if (fishUsersSnapshot.docs.isNotEmpty) {
        return fishUsersSnapshot.docs.first['full_name'] ?? 'Vendeur Inconnu';
      }

      // If no match is found in both collections
      return 'Vendeur Inconnu';
    } catch (e) {
      return 'Erreur';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Products',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0F8A77),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // Action pour le panier
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Rechercher',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('vente')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun produit disponible.'));
                }

                final products = snapshot.data!.docs.where((doc) {
                  final product = doc.data() as Map<String, dynamic>;
                  final name = product['name'].toString().toLowerCase();
                  return name.contains(_searchText);
                }).toList();

                if (products.isEmpty) {
                  return const Center(
                      child: Text('Aucun produit ne correspond à la recherche.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                    products[index].data() as Map<String, dynamic>;

                    return FutureBuilder<String>(
                      future: getSellerName(product['sellerEmail']),
                      builder: (context, sellerNameSnapshot) {
                        final sellerName = sellerNameSnapshot.data ?? '...';
                        return ProductCard(
                          name: product['name'],
                          price: product['price'],
                          imageUrl: product['imageUrl'],
                          sellerFullName: sellerName,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String imageUrl;
  final String sellerFullName;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sellerFullName,
  });

  void _showPurchasePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController phoneController = TextEditingController();
        final TextEditingController emailController = TextEditingController();
        final TextEditingController quantityController = TextEditingController();

        return AlertDialog(
          title: const Text('Formulaire d\'Achat'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom Complet',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de Téléphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () async {
                final fullName = nameController.text.trim();
                final phoneNumber = phoneController.text.trim();
                final email = emailController.text.trim();
                final quantity =
                    int.tryParse(quantityController.text.trim()) ?? 0;

                if (fullName.isEmpty ||
                    phoneNumber.isEmpty ||
                    email.isEmpty ||
                    quantity <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Veuillez remplir tous les champs correctement.')),
                  );
                  return;
                }

                await FirebaseFirestore.instance
                    .collection('achat_effectuer')
                    .add({
                  'productName': name,
                  'price': price,
                  'sellerFullName': sellerFullName,
                  'buyerName': fullName,
                  'phoneNumber': phoneNumber,
                  'email': email,
                  'quantity': quantity,
                  'totalPrice': price * quantity,
                  'purchaseDate': Timestamp.now(),
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Achat effectué avec succès !')),
                );
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.blue),
              onPressed: () => _showPurchasePopup(context),
            ),
          ],
        ),
      ),
    );
  }
}



