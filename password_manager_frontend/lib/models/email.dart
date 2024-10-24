class Email {
  final int id;
  final String address;
  final String description;
  final String passwordHash;
  final String salt;
  final String accountId;
  final String categoryId;

  Email({
    required this.id,
    required this.address,
    required this.description,
    required this.passwordHash,
    required this.salt,
    required this.accountId,
    required this.categoryId
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
        id: json['id'],
        address: json ['address'],
        description: json ['description'],
        passwordHash: json ['passwordHash'],
        salt: json ['salt'],
        accountId: json ['accountId'],
        categoryId: json ['categoryId']
    );
  }
}