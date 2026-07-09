import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(ApiClient apiClient)
      : _repository = CategoryRepository(apiClient),
        super(CategoryInitial()) {
    on<LoadCategories>(_onLoad);
    on<CreateCategory>(_onCreate);
    on<UpdateCategory>(_onUpdate);
    on<DeleteCategory>(_onDelete);
  }

  Future<void> _onLoad(
      LoadCategories event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateCategory event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await _repository.create(event.category);
      emit(const CategorySuccess('Category created'));
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onUpdate(
      UpdateCategory event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await _repository.update(event.id, event.category);
      emit(const CategorySuccess('Category updated'));
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteCategory event, Emitter<CategoryState> emit) async {
    emit(CategoryLoading());
    try {
      await _repository.delete(event.id);
      emit(const CategorySuccess('Category deleted'));
      final categories = await _repository.getAll();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}