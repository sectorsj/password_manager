// dart
import 'package:flutter/material.dart';
import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:password_manager_frontend/models/website.dart';
import 'package:password_manager_frontend/services/website_service.dart';

class AddWebsiteFormWidget extends StatefulWidget {
  final int accountId;
  final int? categoryId;
  final int? userId;

  const AddWebsiteFormWidget({
    Key? key,
    required this.accountId,
    this.categoryId,
    this.userId,
  }) : super(key: key);

  @override
  _WebsiteFormPageState createState() => _WebsiteFormPageState();
}

class _WebsiteFormPageState extends State<AddWebsiteFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final WebsiteService _websiteService = WebsiteService();
  final EncryptionUtility _encryptionUtility = EncryptionUtility.fromEnv();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить сайт')),
      body: Form(
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
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите URL' : null,
                ),
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(labelText: 'Логин'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите логин' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration:
                      const InputDecoration(labelText: 'Email (необязательно)'),
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите пароль' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final encryptedPassword = _encryptionUtility
                          .encryptText(_passwordController.text);

                      final website = Website(
                        id: 0,
                        websiteName: _nameController.text,
                        websiteUrl: _urlController.text,
                        websiteLogin: _loginController.text,
                        websiteEmail: _emailController.text,
                        encryptedPassword: encryptedPassword,
                        websiteDescription: _descriptionController.text,
                        accountId: widget.accountId,
                        categoryId: widget.categoryId!,
                      );

                      try {
                        final result =
                            await _websiteService.addWebsite(website);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result)),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Ошибка при добавлении')),
                        );
                      }
                    }
                  },
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
