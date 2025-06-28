import 'dart:typed_data';

class Website {
  final int id;
  final String password;
  final String? websiteDescription;
  final int nicknameId;
  final String? nickname;
  final String websiteName;
  final int accountId;
  final int categoryId;
  final String? websiteEmail;
  final int? userId;
  final String websiteUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Website({
    required this.id,
    required this.password,
    this.websiteDescription,
    required this.nicknameId,
    this.nickname,
    required this.websiteName,
    required this.accountId,
    required this.categoryId,
    this.websiteEmail,
    this.userId,
    required this.websiteUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Website.fromJson(Map<String, dynamic> json) => Website(
        id: json['id'],
        password: '',
        websiteDescription: json['website_description'],
        nicknameId: json['nickname_id'],
        nickname: json['nickname'],
        websiteName: json['website_name'],
        accountId: json['account_id'],
        categoryId: json['category_id'],
        websiteEmail: json['website_email'],
        userId: json['user_id'],
        websiteUrl: json['website_url'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'password': password,
        'website_description': websiteDescription,
        'nickname': nickname,
        'website_name': websiteName,
        'account_id': accountId,
        'category_id': categoryId,
        'website_email': websiteEmail,
        'user_id': userId,
        'website_url': websiteUrl,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
