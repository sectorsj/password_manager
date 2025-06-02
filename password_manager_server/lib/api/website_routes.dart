import 'dart:convert';

import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class WebsiteRoutes {
  final Connection connection;

  WebsiteRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getWebsiteByUserId);
    return router;
  }

  // === ПОЛУЧЕНИЕ СПИСКА ВЕБСАЙТОВ ДЛЯ АККАУНТА ===
  Future<Response> _getWebsiteByUserId(Request request) async {
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
          SELECT *
          FROM websites
          WHERE account_id = (SELECT account_id FROM users WHERE id = @userId)
          '''),
        parameters: {'userId': userId},
      );

      final websites = result.map((row) {
        final raw = row.toColumnMap();
        return {
          'id': raw['id'],
          'password_hash': raw['password_hash'],
          'salt': raw['salt'],
          'website_description': raw['website_description'],
          'website_login': raw['website_login'],
          'website_name': raw['website_name'],
          'account_id': raw['account_id'],
          'category_id': raw['category_id'],
          'website_email': raw['website_email'],
          'website_url': raw['website_url'],
          'created_at': (raw['created_at'] as DateTime?)?.toIso8601String(),
          'updated_at': (raw['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList();

      return Response.ok(
        jsonEncode(websites),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении сайтов: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении сайтов'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
