// dart
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/website.dart';
import 'package:password_manager_frontend/services/website_service.dart';
import 'package:password_manager_frontend/widgets/password_field.dart';

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
  bool _addNewEmail = false;  // флаг для чекбокса, отвечающего за добавление новой почты
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
      websiteEmail: _addNewEmail ? _emailController.text.trim() : null,
      rawEmailPassword: _addNewEmail
          ? _emailPasswordController.text.trim()
          : null,
      websiteDescription: _descriptionController.text,
      accountId: widget.accountId,
      userId: widget.userId,
      categoryId: widget.categoryId ?? 3, // 💡 по умолчанию "3" - категория для сайтов
      nicknameId: 0, // временно 0, логин пойдёт как nickname
    );

    try {
      final result = await _websiteService.addWebsite(
        website,
        useNewRoute: !_addNewEmail,
      );
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

                      PasswordField(
                        controller: _passwordController,
                        labelText: 'Пароль вебсайта',
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите пароль'
                            : null,
                      ),

                      // Чекбокс: Добавить новую почту
                      CheckboxListTile(
                        title: const Text('Добавить новую почту'),
                        value: _addNewEmail,
                        onChanged: (value) {
                          setState(() {
                            _addNewEmail = value ?? false;
                          });
                        },
                      ),

                      // Поля почты — только если чекбокс включён
                      if (_addNewEmail) ...[
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Эл. почта'),
                          validator: (value) {
                            if (_addNewEmail &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Введите эл. почту';
                            }
                            return null;
                          },
                        ),

                        PasswordField(
                          controller: _emailPasswordController,
                          labelText: 'Пароль эл. почты',
                          validator: (value) {
                            if (_addNewEmail &&
                                (value == null || value.trim().isEmpty)) {
                              return 'Введите пароль эл. почты';
                            }
                            return null;
                          },
                        ),
                      ],

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