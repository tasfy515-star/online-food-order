class BannerModel {
  final String id;
  final String image;
  final String title;
  final String subtitle;
  final String promoCode;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.image,
    required this.title,
    required this.subtitle,
    this.promoCode = '',
    this.isActive = true,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] ?? '',
      image: map['image'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      promoCode: map['promoCode'] ?? '',
      isActive: map['isActive'] ?? true,
    );
  }
}