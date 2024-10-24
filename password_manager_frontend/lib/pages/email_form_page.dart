import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/email_service.dart';
import 'package:hashing_utility_package/hashing_utility.dart';

class EmailFormPage extends StatefulWidget {
  const EmailFormPage({Key? key}) : super(key: key);

  @override
  _EmailFormPageState createState() => _EmailFormPageState();
}

class _EmailFormPageState extends State<EmailFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final EmailService _emailService = EmailService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Email'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    Map<String, String> hashedData =
                        await HashingUtility.hashPassword(
                            _passwordController.text);

                    String email = _emailController.text;
                    String password = hashedData['hash']!;
                    String salt = hashedData['salt']!;
                    String description = _descriptionController.text;
                    int accountId = 1; // Предполагаем, что ID аккаунта 1

                    String result = await _emailService.addEmail(
                      email,
                      password,
                      salt,
                      description,
                      accountId,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result)),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
