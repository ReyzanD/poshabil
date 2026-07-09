import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final ApiClient _apiClient;

  AuthBloc(ApiClient apiClient)
      : _repository = AuthRepository(apiClient),
        _apiClient = apiClient,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthEvent>(_onCheckAuth);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response = await _repository.login(event.email, event.password);
      final token = response['access_token'] as String;
      _apiClient.setToken(token);
      emit(Authenticated(
        UserModel.fromJson(response['user']),
        token,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final response =
          await _repository.register(event.name, event.email, event.password);
      final token = response['access_token'] as String;
      _apiClient.setToken(token);
      emit(Authenticated(
        UserModel.fromJson(response['user']),
        token,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      await _repository.logout();
    } catch (_) {}
    _apiClient.setToken(null);
    emit(Unauthenticated());
  }

  Future<void> _onCheckAuth(
      CheckAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final token = await _apiClient.restoreToken();
      if (token == null || token.isEmpty) {
        emit(Unauthenticated());
        return;
      }
      final user = await _repository.getMe();
      emit(Authenticated(user, token));
    } catch (_) {
      _apiClient.setToken(null);
      emit(Unauthenticated());
    }
  }
}