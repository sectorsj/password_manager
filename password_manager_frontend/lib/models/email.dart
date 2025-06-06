import 'dart:typed_data';

class Email {
  final int id;
  final String emailAddress;
  final String? emailDescription;
  final String encryptedPassword;
  final int accountId;
  final int? categoryId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Email({
    required this.id,
    required this.emailAddress,
    this.emailDescription,
    required this.encryptedPassword,
    required this.accountId,
    this.categoryId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
        id: json['id'],
        emailAddress: json['email_address'],
        encryptedPassword: json['encrypted_password'] as String,
        emailDescription: json['email_description'],
        accountId: json['account_id'],
        categoryId: json['category_id'],
        userId: json['user_id'],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email_address': emailAddress,
        'email_description': emailDescription,
        'encrypted_password': encryptedPassword,
        'account_id': accountId,
        'category_id': categoryId,
        'user_id': userId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
