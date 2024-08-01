import 'package:aevue/model/products_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository(ref);
});

class ProductsRepository {
  final Ref _ref;

  ProductsRepository(this._ref);

  Future<ProductsResponse> getProducts() async {
    final apiService = _ref.read(apiServiceProvider);
    final data = await apiService.getProductList(queryParameter: {"q":"phone"});
    return ProductsResponse.fromJson(data);
  }
}
