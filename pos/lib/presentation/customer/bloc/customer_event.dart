import 'package:equatable/equatable.dart';

import '../../../data/models/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {
  final String? search;

  const LoadCustomers({this.search});

  @override
  List<Object?> get props => [search];
}

class LoadMoreCustomers extends CustomerEvent {
  const LoadMoreCustomers();
}

class CreateCustomer extends CustomerEvent {
  final CustomerModel customer;

  const CreateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class UpdateCustomer extends CustomerEvent {
  final int id;
  final CustomerModel customer;

  const UpdateCustomer(this.id, this.customer);

  @override
  List<Object?> get props => [id, customer];
}

class DeleteCustomer extends CustomerEvent {
  final int id;

  const DeleteCustomer(this.id);

  @override
  List<Object?> get props => [id];
}
