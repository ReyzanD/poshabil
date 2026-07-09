import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentSearch;

  CustomerBloc(ApiClient apiClient)
      : _repository = CustomerRepository(apiClient),
        super(CustomerInitial()) {
    on<LoadCustomers>(_onLoad);
    on<LoadMoreCustomers>(_onLoadMore);
    on<CreateCustomer>(_onCreate);
    on<UpdateCustomer>(_onUpdate);
    on<DeleteCustomer>(_onDelete);
  }

  Future<void> _onLoad(
      LoadCustomers event, Emitter<CustomerState> emit) async {
    _currentPage = 1;
    _hasMore = true;
    _currentSearch = event.search;
    emit(CustomerLoading());
    try {
      final result = await _repository.getAll(
        search: _currentSearch,
        page: 1,
      );
      final customers = (result['data'] as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList();
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(CustomersLoaded(customers, hasMore: _hasMore));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreCustomers event, Emitter<CustomerState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is! CustomersLoaded) return;
    _currentPage++;
    try {
      final result = await _repository.getAll(
        search: _currentSearch,
        page: _currentPage,
      );
      final newItems = (result['data'] as List)
          .map((e) => CustomerModel.fromJson(e))
          .toList();
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(CustomersLoaded(
        [...current.customers, ...newItems],
        hasMore: _hasMore,
      ));
    } catch (e) {
      _currentPage--;
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      await _repository.create(event.customer);
      emit(const CustomerSuccess('Customer created'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      await _repository.update(event.id, event.customer);
      emit(const CustomerSuccess('Customer updated'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteCustomer event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());
    try {
      await _repository.delete(event.id);
      emit(const CustomerSuccess('Customer deleted'));
      add(const LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}