import 'category_model.dart';

class ProductModel {
  final int? id;
  final int categoryId;
  final String name;
  final String sku;
  final String? description;
  final double price;
  final int stock;
  final String? image;
  final CategoryModel? category;
  final String? createdAt;

  ProductModel({
    this.id,
    required this.categoryId,
    required this.name,
    required this.sku,
    this.description,
    required this.price,
    required this.stock,
    this.image,
    this.category,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'],
        categoryId: json['category_id'],
        name: json['name'],
        sku: json['sku'],
        description: json['description'],
        price: double.parse(json['price'].toString()),
        stock: json['stock'],
        image: json['image'],
        category: json['category'] != null
            ? CategoryModel.fromJson(json['category'])
            : null,
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'stock': stock,
        'image': image,
      };
}
