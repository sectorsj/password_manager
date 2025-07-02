import 'dart:convert';
import 'package:common_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class EmailRoutes {
  final Connection connection;

  EmailRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getEmailsByUserId);
    router.get('/<id>/password', _getDecryptedPasswordById);
    router.post('/add', _addEmail);

    return router;
  }

  Future<Response> _getEmailsByUserId(
    Request request,
  ) async {
    print('🔍 Контекст запроса: ${request.context}');
    final userIdStr = request.url.queryParameters['user_id'];
    final userId = int.tryParse(userIdStr ?? '');

    if (userId == null) {
      return Response.badRequest(
        body:
            jsonEncode({'error': 'Отсутствует или неверный user_id: $userId'}),
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

  Future<Response> _getDecryptedPasswordById(Request request, String id) async {
    try {
      final emailId = int.tryParse(id);
      final encryption = request.context['encryption'] as EncryptionUtility?;

      if (emailId == null || encryption == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error':
                'Некорректный идентификатор почты или шифрование отсутствует'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

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
          jsonEncode({'❌ error': 'Email не обнаружен'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final encrypted =
          result.first.toColumnMap()['encrypted_password'] as String;
      final decrypted = encryption.decryptText(encrypted);

      return Response.ok(
        jsonEncode({'decrypted_password': decrypted}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Ошибка при получении расшифрованного пароля: $e');

      return Response.internalServerError(
        body: jsonEncode({'❌ error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addEmail(Request request) async {
    try {
      final encryption = request.context['encryption'] as EncryptionUtility?;
      final userId = request.context['user_id'] as int?;
      if (encryption == null || userId == null) {
        return Response.forbidden(
          jsonEncode({'❌ error': 'Отсутствует токен или пользователь'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final data = jsonDecode(await request.readAsString());
      final emailAddress = data['email_address'] as String?;
      final rawPassword = data['raw_password'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;
      final emailDescription = data['email_description'] as String ?? '';

      if ([emailAddress, rawPassword, accountId]
          .any((v) => v == null || v.toString().trim().isEmpty)) {
        return Response.badRequest(
          body: jsonEncode(
              {'❌ error': 'Некоторые обязательные поля отсутствуют'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final encryptedPassword = encryption.encryptText(rawPassword!);

      final result = await connection.execute(
        Sql.named('''
              SELECT create_email_entry(
                @email_address,
                @email_description,
                @encrypted_password,
                @account_id,
                @category_id,
                @user_id
              )
            '''),
        parameters: {
          'email_address': emailAddress,
          'email_description': emailDescription,
          'encrypted_password': encryptedPassword,
          'account_id': accountId,
          'category_id': categoryId,
          'user_id': userId,
        },
      );

      final insertedId = result.first.toColumnMap().values.first;

      return Response.ok(
        jsonEncode({'message': 'Почта успешно добавлена', 'id': insertedId}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('❌ Ошибка при добавлении почты: $e');
      print(stack);
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при добавлении'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
