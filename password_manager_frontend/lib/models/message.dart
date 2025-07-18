// 📁 models/message.dart
class Message {
  final int id;
  final String messageType;
  final String? title;
  final String content;
  final String format;

  Message({
    required this.id,
    required this.messageType,
    required this.title,
    required this.content,
    required this.format,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      messageType: json['message_type'] as String,
      title: json['title'] as String?,
      content: json['content'] as String,
      format: json['format'] ?? 'markdown',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message_type': messageType,
        'title': title,
        'content': content,
        'format': format,
      };
}
