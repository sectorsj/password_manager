// welcome_preview_screen.dart
import 'package:flutter/material.dart';

class WelcomePreviewPage extends StatelessWidget {
  const WelcomePreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добро пожаловать в PassKeeper')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: const Text(
                  '''\uD83E\uDDEA Альфа-версия приложения PassKeeper — Обзор возможностей
  Добро пожаловать в альфа-версию PassKeeper — защищённого менеджера цифровых данных!
  \uD83D\uDD10 Безопасность — наш приоритет
  • Все пароли шифруются на сервере
  • Для каждого пользователя создаётся уникальный AES-ключ
  • Авторизация по токенам (JWT), данные не передаются в открытом виде
  \ud83d\udcbc Что уже реализовано:
  ✅ Регистрация и вход
  • Создание аккаунта с логином, никнеймом и почтой
  • Шифрование паролей при сохранении
  • Авторизация через email и пароль
  \ud83c\udf10 Сайты
  • Название, URL, никнейм, пароль
  • Привязка email и пароля к нему
  • Автоматическая расшифровка
  \ud83c\udf0d Сетевые подключения
  • Название, IPv4/IPv6, ник, email
  • Добавление в 1 клик
  • Шифрование паролей
  \ud83d\udce7 Email-аккаунты
  • Добавление отдельных email-учеток
  • Расшифровка email-пароля
  • Привязка к сайтам и сетям
  \ud83d\udc64 Структура
  • Один аккаунт — несколько пользователей (в будущем)
  • Свои никнеймы, email и подключения
  • Всё привязано к защищённой учётке
  \ud83d\udce6 Что дальше?
  • Сбор обратной связи
  • План: категории, фильтры, мобильные версии, облачная синхронизация
  \ud83e\uddea Готовы тестировать?
  Попробуйте добавить сайт, email или сеть — и расшифровать пароли!
  Если что-то непонятно или не работает — сообщите команде “InIT” :)
  ''',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Продолжить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
