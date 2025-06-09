class Nickname {
  final int id;
  final String nickname;

  Nickname({required this.id, required this.nickname});

  factory Nickname.fromJson(Map<String, dynamic> json) =>
      Nickname(id: json['id'], nickname: json['nickname']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
      };
}
