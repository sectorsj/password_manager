class User {
  final int id;
  final String? userPhone;
  final String? userDescription;
  final String? userName;
  final int accountId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
  required this.id,
  this.userPhone,
  this.userDescription,
  this.userName,
  required this.accountId,
  this.createdAt,
  this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    userPhone: json['user_phone'] ,
    userDescription: json['user_description'],
    userName: json['user_name'],
    accountId: json['account_id'] is int ? json['account_id'] : 0,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
  'id': id,
  'user_phone': userPhone,
  'user_description': userDescription,
  'user_name': userName,
  'account_id': accountId,
  'created_at': createdAt?.toIso8601String(),
  'updated_at': updatedAt?.toIso8601String(),
  };
}