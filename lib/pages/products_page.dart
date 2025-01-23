import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/product_model.dart';
import 'package:flutter_restaurapp/pages/product_detail_page.dart';
import 'package:flutter_restaurapp/services/product_service.dart';

class ProductsPage extends StatelessWidget {
  final ProductService _productService = ProductService();

  ProductsPage({super.key});

  void _navigateToProductDetail(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product ??
              Product(
                id: "",
                name: '',
                quantity: 0.0,
                measure: '',
                scarseState: 0.0,
                sufficientState: 0.0,
                thumbnailImage: '',
                details: '',
              ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: _productService.getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        final products = snapshot.data!;

        return ListView.separated(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            Color circleColor;

            if (product.quantity < product.scarseState) {
              circleColor = Colors.red;
            } else if (product.quantity < product.sufficientState) {
              circleColor = Colors.yellow;
            } else {
              circleColor = Colors.green;
            }

            return InkWell(
              onTap: () {
                _navigateToProductDetail(context, product: product);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipOval(
                        child: product.thumbnailImage.isNotEmpty
                            ? Image.network(
                                product.thumbnailImage,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle, color: Colors.grey),
                              ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        '${product.quantity}${product.measure}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: circleColor),
                      ),
                    ),
                    const Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.arrow_right,
                        color: Colors.grey,
                        size: 20,
                        semanticLabel: 'Product detail',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const Divider();
          },
        );
      },
    );
  }
}
