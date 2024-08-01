import 'package:aevue/model/products_response.dart';
import 'package:aevue/repositories/product_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productProvider = StateNotifierProvider<ProductNotifier, ProductsResponse?>((ref) {
  return ProductNotifier(ref);
});

class ProductNotifier extends StateNotifier<ProductsResponse?> {
  final Ref _ref;
  ProductNotifier(this._ref) : super(null);
  Future<void> getProductLists() async {
    final productRepository = _ref.read(productsRepositoryProvider);
    final product = await productRepository.getProducts();
    state = product;
  }
}