import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../models/message.dart';

class MessagePreviewPage extends StatelessWidget {
  final Message message;

  const MessagePreviewPage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isHtml = message.format == 'html';

    return Scaffold(
      appBar: AppBar(
        title: Text(message.title ?? 'Сообщение'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Закрыть',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: isHtml
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Html(data: message.content),
              )
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  message.content,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
      ),
    );
  }
}
