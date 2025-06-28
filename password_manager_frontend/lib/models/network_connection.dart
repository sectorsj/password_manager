class NetworkConnection {
  final int id;
  final String networkConnectionName;
  final String? ipv4;
  final String? ipv6;
  final String password;
  final String? networkConnectionDescription;
  final int accountId;
  final int? userId;
  final int? nicknameId;
  final String? nickname;
  final int? emailId;
  final String? networkConnectionEmail;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NetworkConnection({
    required this.id,
    required this.networkConnectionName,
    this.ipv4,
    this.ipv6,
    required this.password,
    this.networkConnectionDescription,
    required this.accountId,
    this.userId,
    this.nicknameId,
    this.nickname,
    this.emailId,
    this.networkConnectionEmail,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) =>
      NetworkConnection(
        id: json['id'],
        networkConnectionName: json['network_connection_name'],
        ipv4: json['ipv4'],
        ipv6: json['ipv6'],
        password: '',
        networkConnectionDescription: json['network_connection_description'],
        accountId: json['account_id'],
        userId: json['user_id'],
        nicknameId: json['nickname_id'],
        nickname: json['nickname'],
        emailId: json['email_id'],
        networkConnectionEmail: json['network_connection_email'],
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
        'network_connection_name': networkConnectionName,
        'ipv4': ipv4,
        'ipv6': ipv6,
        'password': password,
        'network_connection_description': networkConnectionDescription,
        'account_id': accountId,
        'user_id': userId,
        'nickname': nickname,
        'email_id': emailId,
        'network_connection_email': networkConnectionEmail,
        'category_id': categoryId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
