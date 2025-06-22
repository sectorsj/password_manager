// dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:common_utility_package/encryption_utility.dart';
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
  final _secureStorage = const FlutterSecureStorage();

  EncryptionUtility? _encryptionUtility;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEncryptionUtility();
  }

  Future<void> _loadEncryptionUtility() async {
    final aesKey = await _secureStorage.read(key: 'aes_key');
    if (aesKey == null || aesKey.isEmpty) {
      print('AES ключ не найден');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AES ключ не найден. Повторите вход.')),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _encryptionUtility = EncryptionUtility.fromBase64Key(aesKey);
      _isLoading = false;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_encryptionUtility == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка шифрования')),
      );
      return;
    }

    final encryptedPassword =
        _encryptionUtility!.encryptText(_passwordController.text);

    final website = Website(
      id: 0,
      websiteName: _nameController.text,
      websiteUrl: _urlController.text,
      nicknameId: 0,
      // временно 0, логин пойдёт как nickname
      nickname: _loginController.text,
      websiteEmail: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      encryptedPassword: encryptedPassword,
      websiteDescription: _descriptionController.text,
      accountId: widget.accountId,
      categoryId: widget.categoryId ?? 3,
      // 💡 по умолчанию — категория для сайтов
      userId: widget.userId,
    );

    try {
      final result = await _websiteService.addWebsite(website);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка при добавлении: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении сайта')),
      );
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
                        controller: _loginController,
                        decoration: const InputDecoration(labelText: 'Логин'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите логин'
                            : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Email (необязательно)'),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Пароль'),
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
