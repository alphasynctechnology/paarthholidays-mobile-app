class OfferModel {
  final String image;
  final String name;
  final String url;

  OfferModel({
    required this.image,
    required this.name,
    this.url = '',
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  static List<OfferModel> listFromJson(List<dynamic> json) {
    return json.map((item) => OfferModel.fromJson(item)).toList();
  }
} 