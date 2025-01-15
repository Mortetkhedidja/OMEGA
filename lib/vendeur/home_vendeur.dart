import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:omegaproject/vendeur/add_prodauct.dart';
import 'package:omegaproject/vendeur/product.dart';

import '../main.dart';

class SellerHomePage extends StatefulWidget {
  @override
  _SellerHomePageState createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  List<Product> products = [];
  bool showMyProducts = false; // Flag to toggle between all and my products

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();  // Log out the user from Firebase
      // Navigate back to MyApp() screen (or the login screen)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()), // Replace with your MyApp screen
      );
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out')),
      );
    }
  }
  // Load products based on the current logged-in user
  Future<void> _loadProducts() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in!");
      return;
    }

    String userEmail = user.email!;

    QuerySnapshot snapshot;

    // If showMyProducts is true, fetch the user's own products
    if (showMyProducts) {
      snapshot = await FirebaseFirestore.instance
          .collection('vente')
          .where('sellerEmail', isEqualTo: userEmail)
          .get();
    } else {
      // Fetch all products (this could be adjusted based on your app logic)
      snapshot = await FirebaseFirestore.instance.collection('vente').get();
    }

    setState(() {
      products = snapshot.docs.map((doc) {
        return Product(
          name: doc['name'],
          price: doc['price'],
          imageUrl: doc['imageUrl'],
          sellerEmail: doc['sellerEmail'],
          id: doc.id,
        );
      }).toList();
    });
  }

  // Method to add a new product
  // Method to add a new product





  // Method to delete a product
  Future<void> _deleteProduct(String productId) async {
    try {
      await FirebaseFirestore.instance
          .collection('vente')
          .doc(productId)
          .delete();
      // Remove the product from the list and refresh UI
      setState(() {
        products.removeWhere((product) => product.id == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error deleting product')),
      );
    }
  }

  // Method to edit a product
  Future<void> _editProduct(Product product) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(
          onProductAdded: (updatedProduct) {
            setState(() {
              // Update the edited product in the list
              int index = products.indexWhere((p) => p.id == updatedProduct.id);
              if (index != -1) {
                products[index] = updatedProduct;
              }
            });
          },
          productToEdit: product, // Pass the product to edit
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //backgroundColor: Colors.transparent, // Make the background transparent
        elevation: 0, // Remove the shadow to prevent the flashback
        title: const Text(
          'Seller Home', // Title text
          style: TextStyle(
            color: Colors.black, // Change text color if needed
            fontSize: 20, // Set the font size for the title
            // Optional: make the title bold
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => _logout(context), // Logout when button is pressed
          ),
        ],

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            /*child: TextField(
              decoration: InputDecoration(
                hintText: "Search Products",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),*/
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Add Product Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddProductScreen(
                        onProductAdded: (product) {
                          setState(() {
                            products.add(product);
                          });
                        },
                      ),
                    ),
                  );
                },
                child: const Text('ADD PRODUCT'),
              ),
              // My Products Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showMyProducts = true; // Toggle to show only the user's products
                    _loadProducts(); // Reload the products
                  });
                },
                child: const Text('My Products'),
              ),
            ],
          ),
          Expanded(
            child: products.isEmpty
                ? Center(child: Text("No products available"))
                : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(products[index].imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(products[index].name),
                          const SizedBox(height: 5),
                          Text("\$${products[index].price}"),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Spacer(),
                          PopupMenuButton<String>(
                            onSelected: (String result) {
                              if (result == 'delete') {
                                _deleteProduct(products[index].id);
                              } else if (result == 'edit') {
                                _editProduct(products[index]);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                            ],
                            icon: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}