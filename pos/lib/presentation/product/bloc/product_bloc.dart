import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _currentSearch;
  int? _currentCategoryId;

  ProductBloc(ApiClient apiClient)
      : _repository = ProductRepository(apiClient),
        super(ProductInitial()) {
    on<LoadProducts>(_onLoad);
    on<LoadMoreProducts>(_onLoadMore);
    on<CreateProduct>(_onCreate);
    on<UpdateProduct>(_onUpdate);
    on<DeleteProduct>(_onDelete);
  }

  Future<void> _onLoad(
      LoadProducts event, Emitter<ProductState> emit) async {
    _currentPage = 1;
    _hasMore = true;
    _currentSearch = event.search;
    _currentCategoryId = event.categoryId;
    emit(ProductLoading());
    try {
      final result = await _repository.getAll(
        search: _currentSearch,
        categoryId: _currentCategoryId,
        page: 1,
      );
      final products = (result['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      final total = result['total'] ?? 0;
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(ProductsLoaded(products, total: total, hasMore: _hasMore));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadMore(
      LoadMoreProducts event, Emitter<ProductState> emit) async {
    if (!_hasMore) return;
    final current = state;
    if (current is! ProductsLoaded) return;
    _currentPage++;
    try {
      final result = await _repository.getAll(
        search: _currentSearch,
        categoryId: _currentCategoryId,
        page: _currentPage,
      );
      final newItems = (result['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
      final total = result['total'] ?? 0;
      final lastPage = result['last_page'] ?? 1;
      _hasMore = _currentPage < lastPage;
      emit(ProductsLoaded(
        [...current.products, ...newItems],
        total: total,
        hasMore: _hasMore,
      ));
    } catch (e) {
      _currentPage--;
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateProduct event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await _repository.create(event.product);
      emit(const ProductSuccess('Product created'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateProduct event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await _repository.update(event.id, event.product);
      emit(const ProductSuccess('Product updated'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteProduct event, Emitter<ProductState> emit) async {
    emit(ProductLoading());
    try {
      await _repository.delete(event.id);
      emit(const ProductSuccess('Product deleted'));
      add(const LoadProducts());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}