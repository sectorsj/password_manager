// dart
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/website.dart';
import 'package:password_manager_frontend/services/website_service.dart';

class AddWebsiteFormWidget extends StatefulWidget {
  final int accountId;
  final int? categoryId;
  final int? userId;

  const AddWebsiteFormWidget({
    super.key,
    required this.accountId,
    this.categoryId,
    this.userId,
  });

  @override
  _WebsiteFormPageState createState() => _WebsiteFormPageState();
}

class _WebsiteFormPageState extends State<AddWebsiteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _userNicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  final WebsiteService _websiteService = WebsiteService();

  Future<void> _submitForm() async {
    print(' Отправка данных на сервер при создании нового вебсайта:');
    print('⚠️ Название вебсайта: ${_nameController.text}');
    print('⚠️ URL адрес вебсайта: ${_urlController.text}');
    print('⚠️ Ник пользователя: ${_userNicknameController.text}');
    print('⚠️ Пароль вебсайта: ${_passwordController.text}');
    print('⚠️ Электронная почта: ${_emailController.text}');
    print('⚠️ Пароль электронной почты: ${_emailPasswordController.text}');
    print('⚠️ Описание вебсайта: ${_descriptionController.text}');

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    print('⚠️ Контроль: $_isLoading');

    final website = Website(
      id: 0,
      websiteName: _nameController.text,
      websiteUrl: _urlController.text,
      nickname: _userNicknameController.text,
      rawPassword: _passwordController.text,
      websiteEmail: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      rawEmailPassword: _emailPasswordController.text,
      websiteDescription: _descriptionController.text,
      accountId: widget.accountId,
      userId: widget.userId,
      categoryId: widget.categoryId ?? 3,
      // 💡 по умолчанию — категория для сайтов
      nicknameId: 0,
      // временно 0, логин пойдёт как nickname
    );

    try {
      final result = await _websiteService.addWebsite(website);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка при добавлении: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении сайта')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить сайт')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: 'Название сайта'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите название'
                            : null,
                      ),
                      TextFormField(
                        controller: _urlController,
                        decoration: const InputDecoration(labelText: 'URL'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите URL'
                            : null,
                      ),
                      TextFormField(
                        controller: _userNicknameController,
                        decoration: const InputDecoration(
                            labelText: 'Ник пользователя'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите никнейм'
                            : null,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration:
                            const InputDecoration(labelText: 'Пароль вебсайта'),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите пароль'
                            : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Эл. почта (необязательно)'),
                      ),
                      TextFormField(
                        controller: _emailPasswordController,
                        decoration: const InputDecoration(
                            labelText: 'Пароль эл. почты'),
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите пароль'
                            : null,
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Описание сайта (необязательно)'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
