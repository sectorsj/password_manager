// dart
import 'package:flutter/material.dart';
import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/network_connection_service.dart';

class AddNetworkConnectionFormWidget extends StatefulWidget {
  final int accountId;
  final int? categoryId;

  const AddNetworkConnectionFormWidget({
    Key? key,
    required this.accountId,
    this.categoryId,
  }) : super(key: key);

  @override
  _NetworkConnectionFormPageState createState() =>
      _NetworkConnectionFormPageState();
}

class _NetworkConnectionFormPageState
    extends State<AddNetworkConnectionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ipv4Controller = TextEditingController();
  final _ipv6Controller = TextEditingController();

  final NetworkConnectionService _service = NetworkConnectionService();
  final EncryptionUtility _encryptionUtility = EncryptionUtility.fromEnv();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить подключение')),
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
                      const InputDecoration(labelText: 'Название подключения'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Введите название'
                      : null,
                ),
                TextFormField(
                  controller: _loginController,
                  decoration: const InputDecoration(labelText: 'Логин'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите логин' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Пароль'),
                  obscureText: true,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Введите пароль' : null,
                ),
                TextFormField(
                  controller: _ipv4Controller,
                  decoration:
                      const InputDecoration(labelText: 'IPv4 (необязательно)'),
                ),
                TextFormField(
                  controller: _ipv6Controller,
                  decoration:
                      const InputDecoration(labelText: 'IPv6 (необязательно)'),
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

                      final connection = NetworkConnection(
                        id: 0,
                        networkConnectionName: _nameController.text,
                        networkConnectionLogin: _loginController.text,
                        encryptedPassword: encryptedPassword,
                        networkConnectionDescription:
                            _descriptionController.text,
                        ipv4: _ipv4Controller.text.isNotEmpty
                            ? _ipv4Controller.text
                            : null,
                        ipv6: _ipv6Controller.text.isNotEmpty
                            ? _ipv6Controller.text
                            : null,
                        accountId: widget.accountId,
                        categoryId: widget.categoryId!,
                      );

                      try {
                        final result =
                            await _service.addNetworkConnection(connection);
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
