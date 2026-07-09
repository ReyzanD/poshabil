import 'product_model.dart';

class TransactionItemModel {
  final int? id;
  final int? transactionId;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final ProductModel? product;

  TransactionItemModel({
    this.id,
    this.transactionId,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) =>
      TransactionItemModel(
        id: json['id'],
        transactionId: json['transaction_id'],
        productId: json['product_id'],
        quantity: json['quantity'],
        price: double.parse(json['price'].toString()),
        subtotal: double.parse(json['subtotal'].toString()),
        product: json['product'] != null
            ? ProductModel.fromJson(json['product'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'quantity': quantity,
      };
}
