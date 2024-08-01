import 'package:aevue/util/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../model/products_response.dart';
import '../util/keys.dart';
import '../widget/product_details.dart';
import '../widget/product_image.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {

  List<Product>? response;
  @override
  void initState() {
    super.initState();
    init();
  }
  Future<void> init()async{
    var product=await LocalDataBase.getStringList(Keys.productFavorites);
    if(product!=null&& product.isNotEmpty){
      setState(() {
        response=product.map((e) =>Product.fromJson(e)).toList();
      });
    }
    else{
      response=[];
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: response != null && response!.isNotEmpty
          ? SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildHeader(),
            Expanded(
              child: SlidableAutoCloseBehavior(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: response?.length ?? 0,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8,right: 20,top: 10,bottom: 10),
                        child: buildSlidableWidget(index),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 38.0),
          child: Text("Currently, you have no favorite products. Please go to the home page to add products to your favorites."),
        ),
      ),
    );
  }

  Padding buildHeader() {
    return const Padding(
            padding: EdgeInsets.only(left: 15,right: 20,top: 20,bottom: 10),
            child: Text("Favorites",style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.normal)),
          );
  }

   buildSlidableWidget(int index) {
    return Slidable(
      key: Key(response?[index].id?.toString()??""),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 48.0),
            child: InkWell(
              onTap: ()async{
                await _removeSavedFavoriteList(response?[index]);
               setState((){
                 response?[index].favorites=false;
               });
               await _updateSavedProductList(response?[index]);
               await init();
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  color:Colors.transparent,
                  child:const Icon(Icons.delete,color: Colors.red,size: 50,),
                ),
              ),
            ),
          ),
        ],
      ),
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: AspectRatio(
              aspectRatio: 1, // Adjust the aspect ratio as needed
              child: ProductImage(imageLink:response?[index].images?.first ?? "",),
            ),
          ),
          const SizedBox(width: 10,),
          ProductDetails(product:response?[index]??Product()),
        ],
      ),
    );
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
}
