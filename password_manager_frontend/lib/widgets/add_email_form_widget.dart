import 'package:common_utility_package/encryption_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    print(
        '⚠️ Контроль: accountId=${widget.accountId}, userId=${widget.userId}, categoryId=${widget.categoryId}');

    final email = Email(
      id: 0,
      emailAddress: _emailController.text,
      rawPassword: _passwordController.text,
      // 🔑 передаём как есть
      emailDescription: _descriptionController.text,
      accountId: widget.accountId,
      categoryId: (widget.categoryId != null && widget.categoryId != 0)
          ? widget.categoryId!
          : 2,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить почту')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Электронная почта'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Введите эл. почту'
                          : null,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                          labelText: 'Пароль электронной почты'),
                      obscureText: true,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Введите пароль'
                          : null,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                          labelText: 'Описание (необязательно)'),
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
    );
  }
}
