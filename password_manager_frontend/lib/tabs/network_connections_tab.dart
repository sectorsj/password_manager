import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/network_connection_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';
import 'package:password_manager_frontend/widgets/add_network_connection_form_widget.dart';

class NetworkConnectionsTab extends StatefulWidget {
  const NetworkConnectionsTab({super.key});

  @override
  _NetworkConnectionsTabState createState() => _NetworkConnectionsTabState();
}

class _NetworkConnectionsTabState extends State<NetworkConnectionsTab> {
  final NetworkConnectionService service = NetworkConnectionService();
  List<NetworkConnection> _connections = [];
  final Map<int, bool> _showPasswordMap = {};
  final Map<int, String> _decryptedPasswords = {};

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    final userId = Provider.of<AuthService>(context, listen: false).userId;
    try {
      final result = await service.getNetworkConnectionsByUser(userId);
      if (!mounted) return;
      setState(() {
        _connections = result;
      });
    } catch (e) {
      if (!mounted) return;
      print('Ошибка при загрузке подключений: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить подключения')),
      );
    }
  }

  Future<void> _togglePassword(int index, NetworkConnection conn) async {
    final visible = _showPasswordMap[index] ?? false;
    if (!visible && !_decryptedPasswords.containsKey(index)) {
      try {
        final decrypted = await service.getDecryptedPassword(conn.id);
        if (!mounted) return;
        setState(() {
          _decryptedPasswords[index] = decrypted;
          _showPasswordMap[index] = true;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при расшифровке пароля')),
        );
      }
    } else {
      if (!mounted) return;
      setState(() {
        _showPasswordMap[index] = !visible;
      });
    }
  }

  void _showConnectionDetails(BuildContext context, NetworkConnection conn) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(conn.networkConnectionName),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('IPv4: ${conn.ipv4 ?? '—'}'),
            Text('IPv6: ${conn.ipv6 ?? '—'}'),
            Text('Никнейм: ${conn.nickname ?? '—'}'), // Добавлено
            Text('Эл. почта: ${conn.networkConnectionEmail ?? '—'}'),
            Text('Пароль почты: ${conn.emailEncryptedPassword ?? '—'}'), // Добавлено
            Text('Описание: ${conn.networkConnectionDescription ?? '—'}'),
            Text('Категория: ${conn.categoryId}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Закрыть'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _addConnection(BuildContext context) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNetworkConnectionFormWidget(
          accountId: auth.accountId,
          categoryId: 3, // 💡 фиксированная категория "Интернет"
        ),
      ),
    );
    _loadConnections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сетевые подключения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addConnection(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Название')),
            DataColumn(label: Text('IPv4')),
            DataColumn(label: Text('IPv6')),
            DataColumn(label: Text('Никнейм')),
            DataColumn(label: Text('Пароль')),
            DataColumn(label: Text('Эл. почта')),
            DataColumn(label: Text('Пароль эл. почты')),
            DataColumn(label: Text('Подробнее')),
          ],
          rows: _connections.asMap().entries.map((entry) {
            final index = entry.key;
            final conn = entry.value;
            final isShown = _showPasswordMap[index] ?? false;
            final password = _decryptedPasswords[index] ?? '';

            return DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text(conn.networkConnectionName)),
                DataCell(Text(conn.ipv4 ?? '—')),
                DataCell(Text(conn.ipv6 ?? '—')),
                DataCell(Text(conn.nickname ?? '—')),   // Добавлено
                DataCell(Row(
                  children: [
                    Text(isShown
                        ? (password.isNotEmpty ? password : '[загрузка]')
                        : '****'),
                    IconButton(
                      icon: Icon(
                          isShown ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => _togglePassword(index, conn),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        if (password.isNotEmpty) {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Пароль скопирован')),
                          );
                        }
                      },
                    ),
                  ],
                )),
                DataCell(Text(conn.networkConnectionEmail ?? '—')),
                DataCell(Text(conn.emailEncryptedPassword ?? '—')), // Добавлено
                DataCell(
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'Подробнее',
                    onPressed: () => _showConnectionDetails(context, conn),
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
