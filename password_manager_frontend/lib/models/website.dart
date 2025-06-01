

import 'dart:typed_data';

class Website {
  final int id;
  final Uint8List passwordHash;
  final Uint8List salt;
  final String? websiteDescription;
  final String websiteLogin;
  final String websiteName;
  final int accountId;
  final int categoryId;
  final String? websiteEmail;
  final String websiteUrl;

  Website({
    required this.id,
    required this.passwordHash,
    required this.salt,
    this.websiteDescription,
    required this.websiteLogin,
    required this.websiteName,
    required this.accountId,
    required this.categoryId,
    this.websiteEmail,
    required this.websiteUrl,
  });

  factory Website.fromJson(Map<String, dynamic> json) => Website(
    id: json['id'],
    passwordHash: Uint8List.fromList(List<int>.from(json['password_hash'])),
    salt: Uint8List.fromList(List<int>.from(json['salt'])),
    websiteDescription: json['website_description'],
    websiteLogin: json['website_login'],
    websiteName: json['website_name'],
    accountId: json['account_id'],
    categoryId: json['category_id'],
    websiteEmail: json['website_email'],
    websiteUrl: json['website_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'password_hash': passwordHash,
    'salt': salt,
    'website_description': websiteDescription,
    'website_login': websiteLogin,
    'website_name': websiteName,
    'account_id': accountId,
    'category_id': categoryId,
    'website_email': websiteEmail,
    'website_url': websiteUrl,
  };
}