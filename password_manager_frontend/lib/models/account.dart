import 'dart:convert';
import 'dart:typed_data';

class Account {
  final int id;
  final String accountLogin;
  final String accountEmail;
  final Uint8List passwordHash;
  final Uint8List? salt;

  Account({
    required this.id,
    required this.accountLogin,
    required this.accountEmail,
    required this.passwordHash,
    this.salt
  });



  factory Account.fromJson(Map<String, dynamic> json) {
    print("DEBUG Account JSON: $json");

    return Account(
      id: json['account_id'] ?? 0,
      accountLogin: json['account_login'] ?? '',
      accountEmail: json['account_email'] ?? '',
      passwordHash: Uint8List.fromList(
        List<int>.from(json['password_hash'] ?? []),
      ),
      salt: json['salt'] != null
          ? Uint8List.fromList(List<int>.from(json['salt']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'account_login': accountLogin,
    'account_email': accountEmail,
    'password_hash': passwordHash,
    'salt': salt
  };
}