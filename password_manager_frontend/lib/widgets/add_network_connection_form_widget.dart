import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/network_connection_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

class AddNetworkConnectionFormWidget extends StatefulWidget {
  final int accountId;
  final int? categoryId;
  final int? userId;

  const AddNetworkConnectionFormWidget({
    Key? key,
    required this.accountId,
    this.categoryId,
    this.userId,
  }) : super(key: key);

  @override
  _AddNetworkConnectionFormWidgetState createState() =>
      _AddNetworkConnectionFormWidgetState();
}

class _AddNetworkConnectionFormWidgetState
    extends State<AddNetworkConnectionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userNicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _ipv4Controller = TextEditingController();
  final _ipv6Controller = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  final NetworkConnectionService _service = NetworkConnectionService();

  Future<void> _submitForm() async {
    print(' Отправка данных на сервер пр создании сетевого подключения:');
    print('⚠️ Название подключения: ${_nameController.text}');
    print('⚠️ Ник пользователя: ${_userNicknameController.text}');
    print('⚠️ Пароль сетевого подключения: ${_passwordController.text}');
    print('⚠️ Электронная почта: ${_emailController.text}');
    print('⚠️ Пароль электронной почты: ${_emailPasswordController.text}');
    print('⚠️ ipv4 адрес: ${_ipv4Controller.text}');
    print('⚠️ ipv6 адрес: ${_ipv6Controller.text}');
    print('⚠️ Описание сетевого подключения: ${_descriptionController.text}');

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    print('⚠️ Контроль: $_isLoading');

    final connection = NetworkConnection(
      id: 0,
      networkConnectionName: _nameController.text,
      nickname: _userNicknameController.text,
      rawPassword: _passwordController.text,
      networkConnectionEmail: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      rawEmailPassword: _emailPasswordController.text,
      ipv4: _ipv4Controller.text.isNotEmpty
          ? _ipv4Controller.text
          : _ipv4Controller.text.trim(),
      ipv6: _ipv6Controller.text.isNotEmpty
          ? _ipv6Controller.text
          : _ipv6Controller.text.trim(),
      networkConnectionDescription: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      accountId: widget.accountId,
      userId: widget.userId,
      categoryId: widget.categoryId ?? 3,
    );
    try {
      final result = await _service.addNetworkConnection(connection);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка при добавлении: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка при добавлении подключения')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить сетевое подключение')),
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
                        decoration: const InputDecoration(
                            labelText: 'Название подключения'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите название'
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
                        decoration: const InputDecoration(
                            labelText: 'Пароль сетевого подключения'),
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
                        controller: _ipv4Controller,
                        decoration: const InputDecoration(
                            labelText: 'IPv4 (необязательно)'),
                      ),
                      TextFormField(
                        controller: _ipv6Controller,
                        decoration: const InputDecoration(
                            labelText: 'IPv6 (необязательно)'),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                            labelText: 'Описание подключения (необязательно)'),
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
