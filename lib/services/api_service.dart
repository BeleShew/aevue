import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../util/keys.dart';
import '../util/shared_preferences.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;
  ApiService() : _dio = Dio();
  Future<Map<String, dynamic>> getProductList({Map<String, dynamic>? queryParameter}) async {
    try {
      var mapData=await LocalDataBase.getString(Keys.productList);
      if(mapData!=null){
        return mapData;
      }
      else{
        final response = await _dio.get(Keys.url,queryParameters: queryParameter);
        await LocalDataBase.saveString(Keys.productList,response.data);
        return response.data;
      }
    } catch (e) {
      throw Exception('Failed to load user data');
    }
  }
}
