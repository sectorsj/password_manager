class Category {
  final int id;
  final String categoryName;
  final String? categoryDescription;

  Category({
    required this.id,
    required this.categoryName,
    this.categoryDescription
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
      id: json['id'],
      categoryName: json['category_name'],
      categoryDescription: json['category_description']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_name': categoryName,
    'category_description': categoryDescription
  };
}