import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:omegaproject/vendeur/product.dart';

class AddProductScreen extends StatefulWidget {
  final Function(Product) onProductAdded;
  final Function(Product)? onProductUpdated;
  final Product? productToEdit; // Pour le produit à éditer

  AddProductScreen({
    required this.onProductAdded,
    this.onProductUpdated,
    this.productToEdit,
  });

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _productName = '';
  double _productPrice = 0;
  String _productImageUrl = '';
  String? sellerEmail;
  String? sellerFullName;
  XFile? _pickedImage; // Pour stocker l'image sélectionnée
  final ImagePicker _imagePicker = ImagePicker();
  bool _isPickingImage =
      false; // Variable pour suivre l'état de sélection d'image

  @override
  void initState() {
    super.initState();
    _getCurrentUser();

    // Remplir les champs avec les données du produit à éditer
    if (widget.productToEdit != null) {
      setState(() {
        _productName = widget.productToEdit!.name;
        _productPrice = widget.productToEdit!.price;
        _productImageUrl =
            widget.productToEdit!.imageUrl; // Garder l'URL de l'image
      });
    }
  }

  // Récupérer les informations de l'utilisateur actuellement connecté
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        sellerEmail = user.email; // Récupérer l'email
      });

      // Récupérer le nom complet depuis Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        sellerFullName =
            userDoc['full_name']; // Assurez-vous que full_name est défini
      });
    }
  }

  // Fonction pour sélectionner une image
  Future<void> _selectImage() async {
    if (_isPickingImage) return; // Vérifie si le sélecteur est déjà actif

    setState(() {
      _isPickingImage = true; // Indique que le sélecteur est actif
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImage = pickedFile; // Stocker l'image sélectionnée
        });
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
    } finally {
      setState(() {
        _isPickingImage = false; // Réinitialise l'état
      });
    }
  }

  // Fonction pour télécharger l'image sur Firebase Storage
  Future<String> _uploadImage() async {
    if (_pickedImage == null)
      return _productImageUrl; // Retourne l'URL existante si aucune nouvelle image n'est sélectionnée

    final ref = FirebaseStorage.instance
        .ref()
        .child('product_images')
        .child(DateTime.now().toString() + '.jpg');

    await ref.putFile(File(_pickedImage!.path));
    return await ref.getDownloadURL(); // Retourne l'URL de l'image téléchargée
  }

  // Fonction pour enregistrer le produit
  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = await _uploadImage();

      // Vérifie si on édite un produit ou si on en ajoute un nouveau
      if (widget.productToEdit != null) {
        // Mise à jour du produit
        await FirebaseFirestore.instance
            .collection('vente')
            .doc(widget.productToEdit!.id) // ID du produit à mettre à jour
            .update({
          'name': _productName,
          'price': _productPrice,
          'imageUrl': imageUrl,
          'sellerEmail': sellerEmail,
          // Ajoutez d'autres champs si nécessaire
        });

        // Vérifie si la fonction de mise à jour est définie avant de l'appeler
        if (widget.onProductUpdated != null) {
          widget.onProductUpdated!(Product(
            name: _productName,
            price: _productPrice,
            imageUrl: imageUrl,
            sellerEmail: sellerEmail!,
            id: widget.productToEdit!.id,
          ));
        }
      } else {
        // Ajout d'un nouveau produit
        await FirebaseFirestore.instance.collection('vente').add({
          'name': _productName,
          'price': _productPrice,
          'imageUrl': imageUrl,
          'sellerEmail': sellerEmail,
          // Ajoutez d'autres champs si nécessaire
        });

        // Appelle la fonction de retour avec le nouveau produit
        widget.onProductAdded(Product(
          name: _productName,
          price: _productPrice,
          imageUrl: imageUrl,
          sellerEmail: sellerEmail!,
          id: '',
        ));
      }

      // Retourne à la page vendeur après l'enregistrement
      Navigator.pop(context); // Ferme l'écran après l'enregistrement
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.productToEdit != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                    image: _pickedImage != null
                        ? DecorationImage(
                            image: FileImage(File(_pickedImage!.path)),
                            fit: BoxFit.cover,
                          )
                        : (_productImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_productImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                  ),
                  child: _pickedImage == null && _productImageUrl.isEmpty
                      ? Center(child: Text('Select Image'))
                      : null,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _productName,
                decoration: InputDecoration(labelText: 'Product Name'),
                onChanged: (value) {
                  _productName = value; // Mettre à jour _productName
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: _productPrice.toString(),
                decoration: InputDecoration(labelText: 'Product Price'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _productPrice = double.tryParse(value) ??
                      0; // Mettre à jour _productPrice
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.productToEdit != null
                    ? 'Update Product'
                    : 'Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
