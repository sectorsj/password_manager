import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordStoragePage extends StatefulWidget {
  const PasswordStoragePage({Key? key}) : super(key: key);

  @override
  _PasswordStoragePageState createState() => _PasswordStoragePageState();
}

class _PasswordStoragePageState extends State<PasswordStoragePage> {
  final _passwordController = TextEditingController();
  final List<String> _storedPasswords = [];

  Future<void> _addPassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPasswords.add(_passwordController.text);
      _passwordController.clear();
    });
    prefs.setStringList('passwords', _storedPasswords);
  }

  Future<void> _loadPasswords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPasswords.addAll(prefs.getStringList('passwords') ?? []);
    });
  }

  @override
  void initState() {
    super.initState();
    _loadPasswords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохраненные пароли'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Добавить новый пароль'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _addPassword,
              child: const Text('Добавить'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _storedPasswords.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_storedPasswords[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}