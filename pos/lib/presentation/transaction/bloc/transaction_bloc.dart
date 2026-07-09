import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentPaymentStatus;

  TransactionBloc(ApiClient apiClient)
      : _repository = TransactionRepository(apiClient),
        super(TransactionInitial()) {
    on<LoadTransactions>(_onLoad);
    on<LoadMoreTransactions>(_onLoadMore);
    on<CreateTransaction>(_onCreate);
    on<LoadTransactionDetail>(_onLoadDetail);
  }

  Future<void> _onLoad(
      LoadTransactions event, Emitter<TransactionState> emit) async {
    _currentPage = 1;
    _hasMore = true;
    _currentPaymentStatus = event.paymentStatus;
    emit(TransactionLoading());
    try {
      final result = await _repository.getAll(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        paymentStatus: event.paymentStatus,
        page: 1,
      );
      final transactions = (result['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(TransactionsLoaded(transactions, hasMore: _hasMore));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreTransactions event, Emitter<TransactionState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is! TransactionsLoaded) return;
    _currentPage++;
    try {
      final result = await _repository.getAll(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        paymentStatus: _currentPaymentStatus,
        page: _currentPage,
      );
      final newItems = (result['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList();
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(TransactionsLoaded(
        [...current.transactions, ...newItems],
        hasMore: _hasMore,
      ));
    } catch (e) {
      _currentPage--;
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateTransaction event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _repository.create(event.transaction);
      emit(const TransactionSuccess('Transaction created'));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadDetail(
      LoadTransactionDetail event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transaction = await _repository.getById(event.id);
      emit(TransactionDetailLoaded(transaction));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}