class BookingModel {
  String? id;
  String userId;
  String serviceId;
  String serviceName;
  String serviceCategory;
  String serviceImage;
  String customerName;
  String customerPhone;
  String customerAddress;
  String bookingDate;
  String bookingTime;
  String status; // pending, confirmed, completed, cancelled
  String issueDescription;
  String? uploadedImage;
  double totalAmount;
  DateTime createdAt;

  BookingModel({
    this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.serviceImage,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.bookingDate,
    required this.bookingTime,
    required this.status,
    required this.issueDescription,
    this.uploadedImage,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceCategory': serviceCategory,
      'serviceImage': serviceImage,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'bookingDate': bookingDate,
      'bookingTime': bookingTime,
      'status': status,
      'issueDescription': issueDescription,
      'uploadedImage': uploadedImage,
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      serviceId: json['serviceId'] ?? '',
      serviceName: json['serviceName'] ?? '',
      serviceCategory: json['serviceCategory'] ?? '',
      serviceImage: json['serviceImage'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerAddress: json['customerAddress'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      bookingTime: json['bookingTime'] ?? '',
      status: json['status'] ?? 'pending',
      issueDescription: json['issueDescription'] ?? '',
      uploadedImage: json['uploadedImage'],
      totalAmount: (json['totalAmount'] is int)
          ? (json['totalAmount'] as int).toDouble()
          : (json['totalAmount'] as double?) ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}