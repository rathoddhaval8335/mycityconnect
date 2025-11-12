class ServiceModel {
  String? id;
  String name;
  String description;
  String category;
  String phone;
  String address;
  String imageUrl;
  double? rating;

  ServiceModel({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.phone,
    required this.address,
    required this.imageUrl,
    this.rating,
  });

  // Add toJson and fromJson methods if not present
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'phone': phone,
      'address': address,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as double?) ?? 0.0,
    );
  }
}