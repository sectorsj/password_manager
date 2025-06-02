import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class NetworkConnectionRoutes {
  final Connection connection;

  NetworkConnectionRoutes(this.connection);

  Router get router {
    final router = Router();
    router.get('/',
        _getNetworkConnectionsByUserId); // соответствует /network-connections?user_id=...
    return router;
  }

  Future<Response> _getNetworkConnectionsByUserId(Request request) async {
    final userIdStr = request.url.queryParameters['user_id'];
    final userId = int.tryParse(userIdStr ?? '');

    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Missing or invalid user_id'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('''
                        SELECT id, network_connection_name, network_connection_login,
                               network_connection_description, ipv4, ipv6, password_hash, salt,
                               account_id, category_id, created_at, updated_at
                        FROM network_connections
                        WHERE account_id = (SELECT account_id FROM users WHERE id = @userId)
                        '''),
        parameters: {'userId': userId},
      );
      final connections = result.map((row) {
        final raw = row.toColumnMap();
        return {
          'id': raw['id'],
          'network_connection_name': raw['network_connection_name'],
          'network_connection_login': raw['network_connection_login'],
          'network_connection_description':
              raw['network_connection_description'],
          'ipv4': raw['ipv4'],
          'ipv6': raw['ipv6'],
          'password_hash': raw['password_hash'],
          'salt': raw['salt'],
          'account_id': raw['account_id'],
          'category_id': raw['category_id'],
          'created_at': (raw['created_at'] as DateTime?)?.toIso8601String(),
          'updated_at': (raw['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList();

      return Response.ok(
        jsonEncode(connections),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении сетевых подключений: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode(
            {'error': 'Ошибка сервера при получении сетевых подключений'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
