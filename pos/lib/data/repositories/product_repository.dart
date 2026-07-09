import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiClient _client;

  ProductRepository(this._client);

  Future<Map<String, dynamic>> getAll({
    String? search,
    int? categoryId,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId;
    final data = await _client.get(ApiConstants.products, queryParams: params);
    return data;
  }

  Future<ProductModel> getById(int id) async {
    final data = await _client.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> create(ProductModel product) async {
    final data = await _client.post(ApiConstants.products, data: product.toJson());
    return ProductModel.fromJson(data);
  }

  Future<ProductModel> update(int id, ProductModel product) async {
    final data = await _client.put('${ApiConstants.products}/$id', data: product.toJson());
    return ProductModel.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiConstants.products}/$id');
  }
}
