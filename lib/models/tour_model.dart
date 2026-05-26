class TourModel {
  final String id;
  final String name;
  final String image;
  final String location;
  final String price;
  final String duration;
  final String departureDate;
  final String description;
  final String url;

  TourModel({
    required this.id,
    required this.name,
    required this.image,
    this.location = '',
    this.price = '',
    this.duration = '',
    this.departureDate = '',
    this.description = '',
    this.url = '',
  });

  factory TourModel.fromJson(Map<String, dynamic> json) {
    return TourModel(
      id: json['id']?.toString() ?? json['plan_id']?.toString() ?? '',
      name: json['name'] ?? json['plan_name'] ?? '',
      image: json['image'] ?? json['img'] ?? '',
      location: json['location'] ?? json['sector'] ?? '',
      price: json['price']?.toString() ?? '',
      duration: json['duration'] ?? '',
      departureDate: json['departure_date'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  static List<TourModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => TourModel.fromJson(json)).toList();
  }
}
