import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiClient _client;

  CategoryRepository(this._client);

  Future<List<CategoryModel>> getAll() async {
    final data = await _client.get(ApiConstants.categories);
    return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<CategoryModel> getById(int id) async {
    final data = await _client.get('${ApiConstants.categories}/$id');
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> create(CategoryModel category) async {
    final data = await _client.post(ApiConstants.categories, data: category.toJson());
    return CategoryModel.fromJson(data);
  }

  Future<CategoryModel> update(int id, CategoryModel category) async {
    final data = await _client.put('${ApiConstants.categories}/$id', data: category.toJson());
    return CategoryModel.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiConstants.categories}/$id');
  }
}
