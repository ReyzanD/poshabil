import 'package:equatable/equatable.dart';

import '../../../data/models/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductModel> products;
  final int total;
  final bool hasMore;

  const ProductsLoaded(this.products, {this.total = 0, this.hasMore = true});

  @override
  List<Object?> get props => [products, total, hasMore];
}

class ProductSuccess extends ProductState {
  final String message;

  const ProductSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
