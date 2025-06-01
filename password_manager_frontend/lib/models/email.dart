import 'dart:typed_data';

class Email {
  final int id;
  final String emailAddress;
  final String? emailDescription;
  final Uint8List? passwordHash;  // Бинарный хэш пароля
  final Uint8List? salt;          // Бинарная соль
  final int accountId;
  final int? categoryId;
  final int? userId;

  Email({
    required this.id,
    required this.emailAddress,
    this.emailDescription,
    this.passwordHash,
    this.salt,
    required this.accountId,
    this.categoryId,
    this.userId
  });

  factory Email.fromJson(Map<String, dynamic> json) => Email(
    id: json['id'],
    emailAddress: json ['email_address'],
    emailDescription: json ['email_description'],
    passwordHash: json ['password_hash'] != null ? Uint8List.fromList(List<int>.from(json['password_hash'])) : null,
    salt: json ['salt'] != null ? Uint8List.fromList(List<int>.from(json['salt'])) : null,
    accountId: json ['account_id'],
    categoryId: json ['category_id'],
    userId: json ['user_id']
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email_address': emailAddress,
    'email_description': emailDescription,
    'password_hash': passwordHash,
    'salt': salt,
    'account_id': accountId,
    'category_id': categoryId,
    'user_id': userId,
  };
}