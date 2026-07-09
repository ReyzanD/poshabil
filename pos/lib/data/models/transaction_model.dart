import 'customer_model.dart';
import 'transaction_item_model.dart';
import 'user_model.dart';

class TransactionModel {
  final int? id;
  final String invoiceNumber;
  final int? userId;
  final int? customerId;
  final double total;
  final String paymentMethod;
  final String paymentStatus;
  final UserModel? user;
  final CustomerModel? customer;
  final List<TransactionItemModel>? items;
  final String? createdAt;

  TransactionModel({
    this.id,
    required this.invoiceNumber,
    this.userId,
    this.customerId,
    required this.total,
    required this.paymentMethod,
    required this.paymentStatus,
    this.user,
    this.customer,
    this.items,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'],
        invoiceNumber: json['invoice_number'],
        userId: json['user_id'],
        customerId: json['customer_id'],
        total: double.parse(json['total'].toString()),
        paymentMethod: json['payment_method'],
        paymentStatus: json['payment_status'],
        user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
        customer: json['customer'] != null
            ? CustomerModel.fromJson(json['customer'])
            : null,
        items: json['items'] != null
            ? (json['items'] as List)
                .map((e) => TransactionItemModel.fromJson(e))
                .toList()
            : null,
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'customer_id': customerId,
        'payment_method': paymentMethod,
        'items': items?.map((e) => e.toJson()).toList(),
      };
}
