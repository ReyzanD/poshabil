import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final ApiClient _client;

  TransactionRepository(this._client);

  Future<Map<String, dynamic>> getAll({
    String? dateFrom,
    String? dateTo,
    String? paymentMethod,
    String? paymentStatus,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (dateFrom != null) params['date_from'] = dateFrom;
    if (dateTo != null) params['date_to'] = dateTo;
    if (paymentMethod != null) params['payment_method'] = paymentMethod;
    if (paymentStatus != null) params['payment_status'] = paymentStatus;
    final data = await _client.get(ApiConstants.transactions, queryParams: params);
    return data;
  }

  Future<TransactionModel> getById(int id) async {
    final data = await _client.get('${ApiConstants.transactions}/$id');
    return TransactionModel.fromJson(data);
  }

  Future<TransactionModel> create(TransactionModel transaction) async {
    final data = await _client.post(ApiConstants.transactions, data: transaction.toJson());
    return TransactionModel.fromJson(data);
  }
}
