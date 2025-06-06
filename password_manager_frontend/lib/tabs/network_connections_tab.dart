// dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/network_connection_service.dart';
import 'package:password_manager_frontend/services/auth_service.dart';

class NetworkConnectionsTab extends StatefulWidget {
  const NetworkConnectionsTab({Key? key}) : super(key: key);

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
      setState(() {
        _connections = result;
      });
    } catch (e) {
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
        setState(() {
          _decryptedPasswords[index] = decrypted;
          _showPasswordMap[index] = true;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при расшифровке пароля')),
        );
      }
    } else {
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
            Text('Логин: ${conn.networkConnectionLogin}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сетевые подключения')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Имя подключения')),
            DataColumn(label: Text('IPv4')),
            DataColumn(label: Text('IPv6')),
            DataColumn(label: Text('Логин')),
            DataColumn(label: Text('Пароль')),
            DataColumn(label: Text('')),
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
                DataCell(Text(conn.networkConnectionLogin)),
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
                        Clipboard.setData(ClipboardData(text: password));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Пароль скопирован')),
                        );
                      },
                    ),
                  ],
                )),
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
