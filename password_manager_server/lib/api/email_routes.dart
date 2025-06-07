import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:postgres/postgres.dart';

class EmailRoutes {
  final Connection connection;

  EmailRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getEmailsByUserId);
    return router;
  }

  Future<Response> _getEmailsByUserId(
    Request request,
  ) async {
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
                        SELECT id, email_address, email_description, encrypted_password, account_id, category_id, user_id, created_at, updated_at
                        FROM emails
                        WHERE user_id = @userId
                        '''),
        parameters: {'userId': userId},
      );

      final emails = result.map((row) {
        final raw = row.toColumnMap();
        return {
          'id': raw['id'],
          'email_address': raw['email_address'],
          'email_description': raw['email_description'],
          'encrypted_password': raw['encrypted_password'],
          'account_id': raw['account_id'],
          'category_id': raw['category_id'],
          'user_id': raw['user_id'],
          'created_at': (raw['created_at'] as DateTime?)?.toIso8601String(),
          'updated_at': (raw['updated_at'] as DateTime?)?.toIso8601String(),
        };
      }).toList();
      return Response.ok(
        jsonEncode(emails),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении email-аккаунтов: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode(
            {'error': 'Ошибка сервера при получении email-аккаунтов'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getEncryptedPasswordById(Request request, String id) async {
    final emailId = int.tryParse(id);

    if (emailId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Invalid email ID'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('''
        SELECT encrypted_password
        FROM emails
        WHERE id = @id
      '''),
        parameters: {'id': emailId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Email not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final password = result.first.toColumnMap()['encrypted_password'];

      return Response.ok(
        jsonEncode({'encrypted_password': password}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Ошибка при получении расшифрованного пароля: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
