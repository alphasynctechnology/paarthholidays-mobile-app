class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String image;
  final String publishedAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.image,
    required this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? json['description'] ?? '',
      body: json['body'] ?? json['content'] ?? '',
      image: json['image'] ?? '',
      publishedAt: json['published_at'] ?? json['date'] ?? '',
    );
  }

  static List<NewsModel> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => NewsModel.fromJson(json)).toList();
  }
}
