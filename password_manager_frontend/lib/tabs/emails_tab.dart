
import 'package:flutter/material.dart';
import 'package:password_manager_frontend/models/email.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/services/email_service.dart';
import 'package:password_manager_frontend/widgets/add_email_form_widget.dart';
import 'package:provider/provider.dart';

import '../mixins/add_item_mixin.dart';
import '../mixins/data_loading_mixin.dart';
import '../mixins/delete_item_mixin.dart';
import '../mixins/details_dialog_mixin.dart';
import '../mixins/password_visibility_mixin.dart';

class EmailsTab extends StatefulWidget {
  const EmailsTab({super.key});

  @override
  _EmailsTabState createState() => _EmailsTabState();
}

class _EmailsTabState extends State<EmailsTab>
  with
    DataLoadingMixin,
    DetailsDialogMixin,
    PasswordVisibilityMixin,
    AddItemMixin,
    DeleteItemMixin {

  final EmailService emailService = EmailService();
  List<Email> _emails = [];

  @override
  void initState() {
    super.initState();
    _loadEmails();
  }

  Future<void> _loadEmails() async {
    await loadData(
      fetchData: () => emailService.getEmails(
        Provider.of<AuthService>(context, listen: false).userId,
      ),
      onDataLoaded: (emails) {
        setState(() {
          _emails = emails;
        });
      },
      context: context,
      errorMessage: 'Не удалось загрузить список почт',
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронные почты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addItem(
              context: context,
              buildForm: () => AddEmailFormWidget(
                accountId: Provider.of<AuthService>(context, listen: false).accountId,
              ),
              onItemAdded: _loadEmails,
            ),
          ),
        ],
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
          rows: _emails.asMap().entries.map((entry) {
            final index = entry.key;
            final email = entry.value;

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(email.emailAddress)),
                DataCell(Row(
                  children: [
                    Text(showPasswordMap[index] ?? false
                        ? decryptedPasswords[index] ?? '****'
                        : '****'),
                    IconButton(
                      icon: Icon(showPasswordMap[index] ?? false
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => togglePasswordVisibility(
                        index: index,
                        fetchPassword: () =>
                            emailService.getDecryptedPassword(email.id),
                        context: context,
                      ),
                    ),
                  ],
                )),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () => showDetailsDialog(
                      context: context,
                      title: email.emailAddress,
                      details: [
                        Text('Описание: ${email.emailDescription ?? '—'}'),
                        Text('Категория: ${email.categoryId}'),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => deleteItem(
                      deleteFunction: () => emailService.deleteEmail(email.id),
                      onItemDeleted: _loadEmails,
                      context: context,
                      errorMessage: 'Не удалось удалить email'
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
