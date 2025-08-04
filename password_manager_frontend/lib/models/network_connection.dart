class NetworkConnection {
  final int id;
  final String networkConnectionName;
  final String? nickname;
  final String rawPassword;
  final String? networkConnectionEmail;
  final String? rawEmailPassword;
  final String? ipv4;
  final String? ipv6;
  final String? networkConnectionDescription;
  final int accountId;
  final int? userId;
  final int? nicknameId;
  final int? emailId;
  final int categoryId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  NetworkConnection({
    required this.id,
    required this.networkConnectionName,
    this.nickname,
    required this.rawPassword,
    this.networkConnectionEmail,
    this.rawEmailPassword,
    this.ipv4,
    this.ipv6,
    this.networkConnectionDescription,
    required this.accountId,
    this.userId,
    this.nicknameId,
    this.emailId,
    required this.categoryId,
    this.createdAt,
    this.updatedAt,
  });

  factory NetworkConnection.fromJson(Map<String, dynamic> json) =>
      NetworkConnection(
        id: json['id'],
        networkConnectionName: json['network_connection_name'],
        nickname: json['nickname'],
        rawPassword: '',
        networkConnectionEmail: json['network_connection_email'],
        rawEmailPassword: null,
        ipv4: json['ipv4'],
        ipv6: json['ipv6'],
        networkConnectionDescription: json['network_connection_description'],
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
        'network_connection_name': networkConnectionName,
        'nickname': nickname,
        'raw_password': rawPassword,
        'network_connection_email': networkConnectionEmail,
        'raw_email_password': rawEmailPassword,
        'ipv4': ipv4,
        'ipv6': ipv6,
        'network_connection_description': networkConnectionDescription,
        'account_id': accountId,
        'user_id': userId,
        'email_id': emailId,
        'category_id': categoryId,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
