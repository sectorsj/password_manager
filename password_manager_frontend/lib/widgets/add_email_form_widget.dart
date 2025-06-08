// dart
import 'package:flutter/material.dart';
import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/email_service.dart';

class AddEmailFormWidget extends StatefulWidget {
  final int accountId;
  final int? categoryId;
  final int? userId;

  const AddEmailFormWidget({
    Key? key,
    required this.accountId,
    this.categoryId,
    this.userId,
  }) : super(key: key);

  @override
  _AddEmailFormWidgetState createState() => _AddEmailFormWidgetState();
}

class _AddEmailFormWidgetState extends State<AddEmailFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final EmailService _emailService = EmailService();
  final EncryptionUtility _encryptionUtility = EncryptionUtility.fromEnv();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить почту')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Введите email' : null,
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

                    final email = Email(
                      id: 0,
                      emailAddress: _emailController.text,
                      encryptedPassword: encryptedPassword,
                      emailDescription: _descriptionController.text,
                      accountId: widget.accountId,
                      categoryId: widget.categoryId,
                      userId: widget.userId,
                    );

                    try {
                      final result = await _emailService.addEmail(email);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result)),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ошибка при добавлении')),
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
    );
  }
}
