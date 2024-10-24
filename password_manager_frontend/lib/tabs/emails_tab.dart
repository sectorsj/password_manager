import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/services/api_service.dart';
import 'package:password_manager_frontend/services/email_service.dart';

class EmailsTab extends StatefulWidget {
  const EmailsTab({Key? key}) : super(key: key);

  @override
  _EmailsTabState createState() => _EmailsTabState();
}

class _EmailsTabState extends State<EmailsTab> {
  final ApiService apiService = ApiService();
  final EmailService emailService = EmailService();
  List<dynamic> emails = [];
  Map<int, bool> _showPasswordMap = {};  // Отображение пароля для каждого элемента

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    // Предполагаем, что ID аккаунта 1 — временное решение
    List<dynamic> result = await emailService.getEmails(1);
    setState(() {
      emails = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emails'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Пароль')),
            DataColumn(label: Text('Описание')),
          ],
          rows: emails.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var email = entry.value;

            // Получаем текущее состояние отображения пароля
            bool _showPassword = _showPasswordMap[index] ?? false;

            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(email['email_address'])),  // email_address
                DataCell(Row(
                  children: [
                    // Отображаем пароль или скрываем его
                    Text(_showPassword ? email['password_hash'] : '****'),
                    IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPasswordMap[index] = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: email['password_hash']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
                DataCell(Text(email['email_description'] ?? '')),  // email_description
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}