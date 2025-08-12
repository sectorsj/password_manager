
class Website {
  final int id;
  final String websiteName;
  final String websiteUrl;
  final String? nickname;
  final String rawPassword;
  final String? websiteEmail;
  final String? rawEmailPassword;
  final String? websiteDescription;
  final int accountId;
  final int? userId;
  final int? nicknameId;
  final int? emailId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Website({
    required this.id,
    required this.websiteName,
    required this.websiteUrl,
    this.nickname,
    required this.rawPassword,
    this.websiteEmail,
    this.rawEmailPassword,
    this.websiteDescription,
    required this.accountId,
    this.userId,
    this.nicknameId,
    this.emailId,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory Website.fromJson(Map<String, dynamic> json) => Website(
        id: json['id'],
        websiteName: json['website_name'],
        websiteUrl: json['website_url'],
        nickname: json['nickname'],
        rawPassword: '',
        websiteEmail: json['website_email'],
        rawEmailPassword: null,
        websiteDescription: json['website_description'],
        accountId: json['account_id'],
        userId: json['user_id'],
        nicknameId: json['nickname_id'],
        emailId: json['email_id'],
        categoryId: json['category_id'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'website_name': websiteName,
        'website_url': websiteUrl,
        'nickname': nickname,
        'raw_password': rawPassword,
        'website_email': websiteEmail,
        'raw_email_password': rawEmailPassword,
        'website_description': websiteDescription,
        'account_id': accountId,
        'user_id': userId,
        'email_id': emailId,
        'category_id': categoryId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
