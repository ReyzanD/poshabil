import 'package:equatable/equatable.dart';

import '../../../data/models/customer_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomersLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final bool hasMore;

  const CustomersLoaded(this.customers, {this.hasMore = false});

  @override
  List<Object?> get props => [customers, hasMore];
}

class CustomerSuccess extends CustomerState {
  final String message;

  const CustomerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
