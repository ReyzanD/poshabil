import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final ApiClient _client;

  CustomerRepository(this._client);

  Future<Map<String, dynamic>> getAll({String? search, int page = 1, int perPage = 20}) async {
    final params = <String, dynamic>{'page': page, 'per_page': perPage};
    if (search != null) params['search'] = search;
    final data = await _client.get(ApiConstants.customers, queryParams: params);
    return data;
  }

  Future<CustomerModel> getById(int id) async {
    final data = await _client.get('${ApiConstants.customers}/$id');
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> create(CustomerModel customer) async {
    final data = await _client.post(ApiConstants.customers, data: customer.toJson());
    return CustomerModel.fromJson(data);
  }

  Future<CustomerModel> update(int id, CustomerModel customer) async {
    final data = await _client.put('${ApiConstants.customers}/$id', data: customer.toJson());
    return CustomerModel.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _client.delete('${ApiConstants.customers}/$id');
  }
}
