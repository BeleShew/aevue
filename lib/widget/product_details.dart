import 'package:aevue/model/products_response.dart';
import 'package:flutter/material.dart';
class ProductDetails extends StatelessWidget {
  const ProductDetails({super.key,required this.product});
  final Product product;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(product.title ?? "",
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5,),
          Text(product.description ?? ""),
          const SizedBox(height: 10,),
          Text("${product.price ?? ""} USD",
              style: const TextStyle(fontSize: 14,
              fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
