class NetworkConnection {
  final int id;
  final String name;
  final String ipv4;
  final String ipv6;
  final String login;
  final String passwordHash;
  final String salt;
  final int accountId;

  NetworkConnection({
    required this.id,
    required this.name,
    required this.ipv4,
    required this.ipv6,
    required this.login,
    required this.passwordHash,
    required this.salt,
    required this.accountId,
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) {
    return NetworkConnection(
      id: json['id'],
      name: json['connection_name'],
      ipv4: json['ipv4'],
      ipv6: json['ipv6'],
      login: json['network_login'],
      passwordHash: json['password_hash'],
      salt: json['salt'],
      accountId: json['account_id'],
    );
  }
}