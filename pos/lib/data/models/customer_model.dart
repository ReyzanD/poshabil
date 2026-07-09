class CustomerModel {
  final int? id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String? createdAt;

  CustomerModel({
    this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        address: json['address'],
        createdAt: json['created_at'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
      };
}
