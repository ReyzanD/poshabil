class CategoryModel {
  final int? id;
  final String name;
  final String? description;
  final int? productsCount;
  final String? createdAt;

  CategoryModel({
    this.id,
    required this.name,
    this.description,
    this.productsCount,
    this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        productsCount: json['products_count'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
      };
}
