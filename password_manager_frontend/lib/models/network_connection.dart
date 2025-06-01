import 'dart:typed_data';

class NetworkConnection {
  final int id;
  final String networkConnectionName;
  final String? ipv4;
  final String? ipv6;
  final String networkConnectionLogin;
  final Uint8List passwordHash;
  final Uint8List salt;
  final int accountId;
  final int categoryId;
  final String? networkConnectionDescription;

  NetworkConnection({
    required this.id,
    required this.networkConnectionName,
    this.ipv4,
    this.ipv6,
    required this.networkConnectionLogin,
    required this.passwordHash,
    required this.salt,
    required this.accountId,
    required this.categoryId,
    this.networkConnectionDescription
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) => NetworkConnection(
    id: json['id'],
    networkConnectionName: json['network_connection_name'],
    ipv4: json['ipv4'],
    ipv6: json['ipv6'],
    networkConnectionLogin: json['network_connection_login'],
    passwordHash: Uint8List.fromList(List<int>.from(json['password_hash'])),
    salt: Uint8List.fromList(List<int>.from(json['salt'])),
    accountId: json['account_id'],
    categoryId: json['category_id'],
    networkConnectionDescription: json['network_connection_description'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'network_connection_name': networkConnectionName,
    'ipv4': ipv4,
    'ipv6': ipv6,
    'network_connection_login': networkConnectionLogin,
    'password_hash': passwordHash,
    'salt': salt,
    'account_id': accountId,
    'category_id': categoryId,
    'network_connection_description': networkConnectionDescription
  };
}