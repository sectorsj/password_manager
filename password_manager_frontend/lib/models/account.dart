import 'dart:convert';
import 'dart:typed_data';

class Account {
  final int id;
  final String accountLogin;
  final String accountEmail;
  final String encryptedPassword;

  Account({
    required this.id,
    required this.accountLogin,
    required this.accountEmail,
    required this.encryptedPassword,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    print("DEBUG Account JSON: $json");

    return Account(
      id: json['account_id'] ?? 0,
      accountLogin: json['account_login'] ?? '',
      accountEmail: json['account_email'] ?? '',
      encryptedPassword: json['encrypted_password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'account_login': accountLogin,
        'account_email': accountEmail,
        'encrypted_password': encryptedPassword,
      };
}
