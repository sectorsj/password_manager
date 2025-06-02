import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class UserRoutes {
  final Connection connection;

  UserRoutes(this.connection);

  Router get router {
    final router = Router();
    router.get('<id>', _getUserById);
    return router;
  }

  Future<Response> _getUserById(Request request, String id) async {
    // === ПОЛУЧЕНИЕ ДАННЫХ ПОЛЬЗОВАТЕЛЯ ===
    try {
      final userId = int.parse(id);
      final result = await connection.execute(
        Sql.named('''
                  SELECT
                      u.id,
                      u.account_id,
                      u.user_name,
                      u.user_phone,
                      u.user_description,
                      u.created_at,
                      u.updated_at
                    FROM users u
                    JOIN accounts a ON u.account_id = a.id
                    WHERE u.id = @id
                  '''),
        parameters: {'id': userId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      return Response.ok(
        jsonEncode({
          'id': row['id'],
          'account_id': row['account_id'],
          'user_name': row['user_name'],
          'user_phone': row['user_phone'],
          'user_description': row['user_description'],
          'created_at': row['created_at']?.toIso8601String(),
          'updated_at': row['updated_at']?.toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Ошибка при получении пользователя: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
