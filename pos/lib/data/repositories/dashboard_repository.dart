import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

class DashboardRepository {
  final ApiClient _client;

  DashboardRepository(this._client);

  Future<Map<String, dynamic>> getStats() async {
    final data = await _client.get(ApiConstants.dashboardStats);
    return data;
  }
}
