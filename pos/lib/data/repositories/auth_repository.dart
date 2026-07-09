import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _client.post(ApiConstants.login, data: {
      'email': email,
      'password': password,
    });
    _client.setToken(data['access_token']);
    return data;
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final data = await _client.post(ApiConstants.register, data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    _client.setToken(data['access_token']);
    return data;
  }

  Future<UserModel> getMe() async {
    final data = await _client.get(ApiConstants.me);
    return UserModel.fromJson(data);
  }

  Future<void> logout() async {
    await _client.post(ApiConstants.logout);
    _client.setToken(null);
  }

  void setToken(String? token) => _client.setToken(token);
}
