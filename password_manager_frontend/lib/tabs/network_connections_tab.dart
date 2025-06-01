import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/models/network_connection.dart';
import 'package:password_manager_frontend/services/network_connection_service.dart';

class NetworkConnectionsTab extends StatefulWidget {
  const NetworkConnectionsTab({Key? key}) : super(key: key);

  @override
  _NetworkConnectionsTabState createState() => _NetworkConnectionsTabState();
}

class _NetworkConnectionsTabState extends State<NetworkConnectionsTab> {
  final NetworkConnectionService networkConnectionServiceService = NetworkConnectionService();
  List<NetworkConnection> _connections = [];
  Map<int, bool> _showPasswordMap = {};

  @override
  void initState() {
    super.initState();
    _loadNetworkConnections();
  }

  Future<void> _loadNetworkConnections() async {
    List<NetworkConnection> connections = await networkConnectionServiceService.getNetworkConnectionsByAccount(1);  // Пример ID аккаунта
    setState(() {
      _connections = connections;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connections'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('№')),
            DataColumn(label: Text('Название')),
            DataColumn(label: Text('IPv4')),
            DataColumn(label: Text('IPv6')),
            DataColumn(label: Text('Имя пользователя')),
            DataColumn(label: Text('Пароль')),
          ],
          rows: _connections.asMap().entries.map((entry) {
            int index = entry.key;
            NetworkConnection connection = entry.value;

            bool _showPassword = _showPasswordMap[index] ?? false;

            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())),
                DataCell(Text(connection.networkConnectionName)),  // connection_name
                DataCell(Text(connection.ipv4 ?? '—')),  // ipv4
                DataCell(Text(connection.ipv6 ?? '—')),  // ipv6
                DataCell(Text(connection.networkConnectionLogin)),  // login
                DataCell(Row(
                  children: [
                    Text(_showPassword ? String.fromCharCodes(connection.passwordHash) : '****'), // пароль
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
                        Clipboard.setData(
                            ClipboardData(text: base64Encode(connection.passwordHash)));
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