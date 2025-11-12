class UserModel {
  String? id;
  String name;
  String email;
  String phone;
  String city;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'city': city,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      city: json['city'],
    );
  }
}

