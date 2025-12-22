class ServiceRequest {
  final String id;
  final String customerId;
  final String? technicianId;
  final String serviceCategoryId;
  final String status;
  final String description;
  final List<String> imageUrls;
  final String? voiceNoteUrl;
  final double estimatedPrice;
  final double? finalPrice;
  final double locationLat;
  final double locationLng;
  final String? locationAddress;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? startJobOtp;
  final Map<String, dynamic>? technician;
  final Map<String, dynamic>? serviceCategory;

  ServiceRequest({
    required this.id,
    required this.customerId,
    this.technicianId,
    required this.serviceCategoryId,
    required this.status,
    required this.description,
    required this.imageUrls,
    this.voiceNoteUrl,
    required this.estimatedPrice,
    this.finalPrice,
    required this.locationLat,
    required this.locationLng,
    this.locationAddress,
    required this.createdAt,
    this.completedAt,
    this.startJobOtp,
    this.technician,
    this.serviceCategory,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      customerId: json['customerId'],
      technicianId: json['technicianId'],
      serviceCategoryId: json['serviceCategoryId'],
      status: json['status'],
      description: json['description'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      voiceNoteUrl: json['voiceNoteUrl'],
      estimatedPrice: json['estimatedPrice'].toDouble(),
      finalPrice: json['finalPrice']?.toDouble(),
      locationLat: json['locationLat'].toDouble(),
      locationLng: json['locationLng'].toDouble(),
      locationAddress: json['locationAddress'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      startJobOtp: json['startJobOtp'],
      technician: json['technician'],
      serviceCategory: json['serviceCategory'],
    );
  }
}
