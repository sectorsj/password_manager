import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/services/api_service.dart';

class EmailsTab extends StatefulWidget {
  const EmailsTab({Key? key}) : super(key: key);

  @override
  _EmailsTabState createState() => _EmailsTabState();
}

class _EmailsTabState extends State<EmailsTab> {
  final ApiService apiService = ApiService();
  List<dynamic> emails = [];
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    List<dynamic> result = await apiService.getEmailsByAccount(1);  // Пример ID аккаунта
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
          ],
          rows: emails.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var email = entry.value;

            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(email[1])),  // email_address
                DataCell(Row(
                  children: [
                    Text(_showPassword ? email[2] : '****'), // пароль
                    IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: email[2]));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}