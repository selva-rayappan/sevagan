class ServiceCategory {
  final String id;
  final String name;
  final String nameEn;
  final String nameTa;
  final String? description;
  final double basePrice;
  final double minPrice;
  final double maxPrice;
  final double commissionPercent;
  final String? iconUrl;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameTa,
    this.description,
    required this.basePrice,
    required this.minPrice,
    required this.maxPrice,
    required this.commissionPercent,
    this.iconUrl,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'],
      name: json['name'],
      nameEn: json['nameEn'],
      nameTa: json['nameTa'],
      description: json['description'],
      basePrice: json['basePrice'].toDouble(),
      minPrice: json['minPrice'].toDouble(),
      maxPrice: json['maxPrice'].toDouble(),
      commissionPercent: json['commissionPercent'].toDouble(),
      iconUrl: json['iconUrl'],
    );
  }
}
