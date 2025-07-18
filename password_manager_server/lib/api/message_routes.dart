import 'dart:convert';
import 'package:password_manager_server/api/base_route.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class MessageRoutes extends BaseRoute {
  final Connection connection;

  MessageRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getMessageByType);

    return router;
  }

  Future<Response> _getMessageByType(Request request) async {
    final type = request.url.queryParameters['type'] ?? 'welcome';

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT id, message_type, title, content, format, require_auth
          FROM messages
          WHERE message_type = @type AND is_active = true
          ORDER BY created_at DESC
          LIMIT 1
        '''),
        parameters: {'type': type},
      );

      if (result.isEmpty) {
        return Response.notFound(jsonEncode({'error': 'Не найдено'}));
      }

      final row = result.first.toColumnMap();

      // Если message требует авторизации, а её нет — отказ
      final requireAuth = row['require_auth'] == true;
      final userId = request.context['user_id'];

      if (requireAuth && userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Требуется авторизация'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode({
          'id': row['id'],
          'message_type': row['message_type'],
          'title': row['title'],
          'content': row['content'],
          'format': row['format'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('❌ Ошибка при получении сообщения: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
