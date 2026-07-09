import 'package:equatable/equatable.dart';

import '../../../data/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  final String? dateFrom;
  final String? dateTo;
  final String? paymentStatus;
  final bool refresh;

  const LoadTransactions({this.dateFrom, this.dateTo, this.paymentStatus, this.refresh = true});

  @override
  List<Object?> get props => [dateFrom, dateTo, paymentStatus, refresh];
}

class LoadMoreTransactions extends TransactionEvent {
  final String? dateFrom;
  final String? dateTo;
  final String? paymentStatus;

  const LoadMoreTransactions({this.dateFrom, this.dateTo, this.paymentStatus});

  @override
  List<Object?> get props => [dateFrom, dateTo, paymentStatus];
}

class CreateTransaction extends TransactionEvent {
  final TransactionModel transaction;

  const CreateTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class LoadTransactionDetail extends TransactionEvent {
  final int id;

  const LoadTransactionDetail(this.id);

  @override
  List<Object?> get props => [id];
}
