import 'package:flutter/material.dart';
import 'package:password_manager_frontend/utils/ui_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomePreviewPage extends StatelessWidget {
  const WelcomePreviewPage({super.key});

  void _launchTelegram() async {
    final Uri uri = Uri.parse(UiRoutes.telegramGroup);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добро пожаловать в PassKeeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Закрыть',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🧪 Альфа-версия приложения PassKeeper — Обзор возможностей\n',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Добро пожаловать в альфа-версию PassKeeper — защищённого менеджера цифровых данных!',
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      '🔐 Безопасность — наш приоритет\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('• Все пароли шифруются на сервере'),
                    const Text(
                        '• Для каждого пользователя создаётся уникальный AES-ключ'),
                    const Text(
                        '• Авторизация по токенам (JWT), данные не передаются в открытом виде'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      '💼 Что уже реализовано:\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('✅ Регистрация и вход'),
                    const Text(
                        '• Создание аккаунта с логином, никнеймом и почтой'),
                    const Text('• Шифрование паролей при сохранении'),
                    const Text('• Авторизация через email и пароль'),
                    const SizedBox(height: 8),
                    const Text('🌐 Сайты'),
                    const Text('• Название, URL, никнейм, пароль'),
                    const Text('• Привязка email и пароля к нему'),
                    const Text('• Автоматическая расшифровка'),
                    const SizedBox(height: 8),
                    const Text('🌍 Сетевые подключения'),
                    const Text('• Название, IPv4/IPv6, ник, email'),
                    const Text('• Добавление в 1 клик'),
                    const Text('• Шифрование паролей'),
                    const SizedBox(height: 8),
                    const Text('📧 Email-аккаунты'),
                    const Text('• Добавление отдельных email-учеток'),
                    const Text('• Расшифровка email-пароля'),
                    const Text('• Привязка к сайтам и сетям'),
                    const SizedBox(height: 8),
                    const Text('👤 Структура'),
                    const Text(
                        '• Один аккаунт — несколько пользователей (в будущем)'),
                    const Text('• Свои никнеймы, email и подключения'),
                    const Text('• Всё привязано к защищённой учётке'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      '📦 Что дальше?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('• Сбор обратной связи'),
                    const Text(
                        '• План: категории, фильтры, мобильные версии, облачная синхронизация'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const Text(
                      '🧪 Готовы тестировать?\n',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                        'Попробуйте добавить сайт, email или сеть — и расшифровать пароли!'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Если что-то непонятно или не работает — '),
                        TextButton(
                          onPressed: _launchTelegram,
                          child: const Text('сообщите команде “InIT” →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
