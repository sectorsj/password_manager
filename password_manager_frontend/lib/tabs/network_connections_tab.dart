import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Для копирования пароля
import 'package:password_manager_frontend/services/network_connection_service.dart';

class NetworkConnectionsTab extends StatefulWidget {
  const NetworkConnectionsTab({Key? key}) : super(key: key);

  @override
  _NetworkConnectionsTabState createState() => _NetworkConnectionsTabState();
}

class _NetworkConnectionsTabState extends State<NetworkConnectionsTab> {
  final NetworkConnectionService networkConnectionServiceService = NetworkConnectionService();
  List<dynamic> connections = [];
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadNetworkConnections();
  }

  Future<void> _loadNetworkConnections() async {
    List<dynamic> result = await networkConnectionServiceService.getNetworkConnectionsByAccount(1);  // Пример ID аккаунта
    setState(() {
      connections = result;
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
          rows: connections.asMap().entries.map((entry) {
            int index = entry.key + 1;
            var connection = entry.value;

            return DataRow(
              cells: [
                DataCell(Text(index.toString())),
                DataCell(Text(connection[1])),  // connection_name
                DataCell(Text(connection[2])),  // ipv4
                DataCell(Text(connection[3])),  // ipv6
                DataCell(Text(connection[4])),  // login
                DataCell(Row(
                  children: [
                    Text(_showPassword ? connection[5] : '****'), // пароль
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
                        Clipboard.setData(ClipboardData(text: connection[5]));
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