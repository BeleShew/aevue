import 'package:aevue/model/products_response.dart';
import 'package:aevue/util/shared_preferences.dart';
import 'package:aevue/widget/product_details.dart';
import 'package:aevue/widget/product_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/product_provider.dart';
import '../util/keys.dart';


class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  String _searchQuery = "";
  List<Product> _filteredProducts = [];
  bool searchEnable=false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productProvider.notifier).getProductLists());
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productProvider);
    return Scaffold(
      body: product != null && product.products != null && product.products!.isNotEmpty
          ? SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),

            buildSearchProduct(product),

            searchEnable&& _filteredProducts.isEmpty?
            buildSearchNotFound():
            buildProductLists(product),
          ],
        ),
      ) : _loadingProductWidget(),
    );
  }

  Padding buildSearchNotFound() {
    return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 38.0),
            child: Center(child: Text("Product not found"),),
          );
  }

  Padding buildSearchProduct(ProductsResponse product) {
    return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  searchEnable=true;
                  filterProduct(product);
                });
              },
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: const TextStyle(color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                contentPadding:const EdgeInsets.only(left: 10),
              ),
            ),
          );
  }

  Expanded buildProductLists(ProductsResponse product) {
    return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:searchEnable?_filteredProducts.length:product.products?.length,
              itemBuilder: (context, index) {
                final productItem = searchEnable?_filteredProducts[index]:product.products?[index];
                return Card(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 20, top: 10, bottom: 10),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ProductImage(imageLink: productItem?.images?.first ?? ""),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ProductDetails(product: productItem??Product()),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () async {
                            setState(() {
                              productItem?.favorites = !(productItem.favorites ?? false);
                            });
                            if (productItem?.favorites ?? false) {
                              await _updateSavedFavoriteList(productItem);
                            } else {
                              await _removeSavedFavoriteList(productItem);
                            }
                            await _updateSavedProductList(productItem);
                          },
                          icon: Icon(
                            productItem?.favorites ?? false ? Icons.favorite_rounded : Icons.favorite_border_sharp,
                            color: productItem?.favorites ?? false ? Colors.amberAccent : Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          );
  }

  List<Product> filterProduct(ProductsResponse? product) {
    if(_searchQuery.isEmpty) {
      return _filteredProducts=product?.products??[];
    }
    return _filteredProducts = product?.products?.where((product) {
    final name = product.title?.toLowerCase() ?? "";
    final query = _searchQuery.toLowerCase();
    return name.contains(query);
  }).toList() ?? [];
  }

  Center _loadingProductWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _updateSavedProductList(Product? product) async {
    var savedListString = await LocalDataBase.getString(Keys.productList);
    if (savedListString != null) {
      var jsonDecoded = ProductsResponse.fromJson(savedListString);
      for (var item in jsonDecoded.products!) {
        if (item.id == product?.id) {
          item.favorites = product?.favorites;
          break;
        }
      }
      await LocalDataBase.saveString(Keys.productList, jsonDecoded.toJson());
    }
  }

  Future<void> _updateSavedFavoriteList(Product? product) async {
    if (product == null) return;
    await LocalDataBase.saveStringList(Keys.productFavorites, product.toJson());
  }

  Future<void> _removeSavedFavoriteList(Product? product) async {
    if (product == null) return;
    var productList = await LocalDataBase.getStringList(Keys.productFavorites);
    if (productList != null) {
      List<Product> response = productList.map((e) => Product.fromJson(e)).toList();
      response.removeWhere((element) => element.id == product.id);
      List<Map<String, dynamic>> updatedList = response.map((product) => product.toJson()).toList();
      await LocalDataBase.saveStringLists(Keys.productFavorites, updatedList);
    }
  }
}

