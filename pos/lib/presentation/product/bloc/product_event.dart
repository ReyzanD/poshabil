import 'package:equatable/equatable.dart';

import '../../../data/models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final String? search;
  final int? categoryId;
  final bool refresh;

  const LoadProducts({this.search, this.categoryId, this.refresh = true});

  @override
  List<Object?> get props => [search, categoryId, refresh];
}

class LoadMoreProducts extends ProductEvent {
  final String? search;
  final int? categoryId;

  const LoadMoreProducts({this.search, this.categoryId});

  @override
  List<Object?> get props => [search, categoryId];
}

class CreateProduct extends ProductEvent {
  final ProductModel product;

  const CreateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final int id;
  final ProductModel product;

  const UpdateProduct(this.id, this.product);

  @override
  List<Object?> get props => [id, product];
}

class DeleteProduct extends ProductEvent {
  final int id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}
