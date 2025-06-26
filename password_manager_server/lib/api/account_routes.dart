import 'dart:convert';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class AccountRoutes {
  final Connection connection;

  AccountRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/<id>', _getAccountById);
    return router;
  }

  // === ПОЛУЧЕНИЕ ИНФОРМАЦИИ ОБ АККАУНТЕ ===
  // === ПОЛУЧЕНИЕ ДАННЫХ АККАУНТА ===
  Future<Response> _getAccountById(Request request, String id) async {
    try {
      final accountId = int.tryParse(id);

      if (accountId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Неверный ID аккаунта'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      print('Запрос информации об аккаунте с ID: $accountId');

      final result = await connection.execute(
        Sql.named('''
        SELECT
          a.id,
          a.account_login,
          e.email_address AS account_email,
          u.user_name,
          u.user_phone,
          u.user_description
        FROM accounts a
        LEFT JOIN users u ON a.id = u.account_id
        LEFT JOIN emails e ON a.email_id = e.id
        WHERE a.id = @accountId
      '''),
        parameters: {'accountId': accountId},
      );

      if (result.isEmpty) {
        print('Аккаунт с ID $accountId не найден');
        return Response.notFound(
          jsonEncode({'error': 'Аккаунт не найден'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final row = result.first.toColumnMap();
      print('Найден аккаунт: ${row['account_login']}');

      return Response.ok(
        jsonEncode({
          'accountLogin': row['account_login'],
          'accountEmail': row['account_email'],
          'userName': row['user_name'],
          'userPhone': row['user_phone'],
          'userDescription': row['user_description'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении аккаунта: $e');
      print('Stack trace: $stack');

      return Response.internalServerError(
        body: jsonEncode(
            {'error': 'Ошибка сервера при получении данных аккаунта'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
