//import 'dart:ffi';

class Product {
  final String id; // Ajoutez cet attribut
  final String name;
  final double price;
  final String imageUrl;
  final String sellerEmail;
  //final String sellerFullName;

  Product({
    required this.id, // Incluez l'ID dans le constructeur
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.sellerEmail,
    // required this.sellerFullName,
  });
}
