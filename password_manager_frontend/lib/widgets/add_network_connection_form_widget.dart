import 'package:common_utility_package/encryption_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  final _ipv4Controller = TextEditingController();
  final _ipv6Controller = TextEditingController();
  final _loginController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final NetworkConnectionService _service = NetworkConnectionService();
  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final connection = NetworkConnection(
      id: 0,
      networkConnectionName: _nameController.text,
      ipv4: _ipv4Controller.text.isNotEmpty ? _ipv4Controller.text : null,
      ipv6: _ipv6Controller.text.isNotEmpty ? _ipv6Controller.text : null,
      password: _passwordController.text,
      // \u2705 plain password (ИСПРАВЛЕНО)
      networkConnectionDescription: _descriptionController.text,
      accountId: widget.accountId,
      userId: authService.userId,
      networkConnectionEmail: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      nickname: _loginController.text,
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
      appBar: AppBar(title: const Text('Добавить подключение')),
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
                        controller: _loginController,
                        decoration: const InputDecoration(labelText: 'Логин'),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Введите логин'
                            : null,
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
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'Эл. почта (необязательно)'),
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
            ),
    );
  }
}
