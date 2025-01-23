import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_restaurapp/models/product_model.dart';
import 'package:logging/logging.dart';

class ProductService {
  final _firestore = FirebaseFirestore.instance;

  Future<void> createProduct(Product product) async {
    try {
      DocumentReference docRef = await _firestore.collection('products').add({
        'name': product.name,
        'details': product.details,
        'quantity': product.quantity,
        'measure': product.measure,
        'scarseState': product.scarseState,
        'sufficientState': product.sufficientState,
        'thumbnailImage': product.thumbnailImage,
      });
      product.id = docRef.id;

      updateProduct(product);
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      List<Product> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      }).toList();
      return products;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<List<Product>> getScarceProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      List<Product> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      }).toList();
      List<Product> scarceProducts = products
          .where((product) => product.quantity < product.scarseState)
          .toList();
      return scarceProducts;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<Map<String, double>> getProductPercentages() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      List<Product> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      }).toList();

      int totalProducts = products.length;
      int scarceProducts =
          products.where((p) => p.quantity < p.scarseState).length;
      int sufficientProducts = products
          .where((p) =>
              p.quantity >= p.scarseState && p.quantity <= p.sufficientState)
          .length;
      int excellentProducts =
          products.where((p) => p.quantity > p.sufficientState).length;

      return {
        'scarce': (scarceProducts / totalProducts) * 100,
        'sufficient': (sufficientProducts / totalProducts) * 100,
        'excellent': (excellentProducts / totalProducts) * 100,
      };
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Stream<List<Product>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      }).toList();
    });
  }

  Future<Product> getProduct(String id) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('products').doc(id).get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        return Product(
          id: documentSnapshot.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      } else {
        throw Exception('Product not found');
      }
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).update({
        'id': product.id,
        'name': product.name,
        'details': product.details,
        'quantity': product.quantity,
        'measure': product.measure,
        'scarseState': product.scarseState,
        'sufficientState': product.sufficientState,
        'thumbnailImage': product.thumbnailImage,
      });
    } catch (e) {
      Logger('Logger').severe(e);
    }
  }

  Future<List<Product>> getProductsContaining(String substring) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('products').get();
      List<Product> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          quantity: data['quantity'],
          measure: data['measure'],
          scarseState: data['scarseState'],
          sufficientState: data['sufficientState'],
          thumbnailImage: data['thumbnailImage'],
          details: data['details'],
        );
      }).toList();
      List<Product> filteredProducts = products
          .where((product) =>
              product.name.toLowerCase().contains(substring.toLowerCase()))
          .toList();
      return filteredProducts;
    } catch (e) {
      Logger('logger').severe(e);
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      Logger('Logger').severe(e);
    }
  }
}
