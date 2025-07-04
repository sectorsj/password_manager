import 'dart:convert';

import 'package:common_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class WebsiteRoutes {
  final Connection connection;

  WebsiteRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getWebsiteByUserId);
    router.get('/<id>/password', _getDecryptedWebsitePasswordById);
    router.post('/add', _addWebsite);

    return router;
  }

  EncryptionUtility? _getEncryption(Request request) {
    return request.context['encryption'] as EncryptionUtility?;
  }

  int? _getUserId(Request request) {
    return request.context['user_id'] as int?;
  }

  Future<Response> _getWebsiteByUserId(Request request) async {
    final userId = _getUserId(request);

    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Нет доступа: пользователь не найден'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('''
          SELECT w.id,
                 w.encrypted_password,
                 w.website_description,
                 w.website_name,
                 w.website_url,
                 w.account_id,
                 w.category_id,
                 w.user_id,
                 w.nickname_id,
                 n.nickname AS nickname,
                 w.email_id,
                 e.email_address AS website_email,
                 w.created_at,
                 w.updated_at
          FROM websites w
          LEFT JOIN nicknames n ON w.nickname_id = n.id
          LEFT JOIN emails e ON w.email_id = e.id
          WHERE w.user_id = @userId
        '''),
        parameters: {'userId': userId},
      );

      final websites = result.map((row) {
        final map = row.toColumnMap();
        if (map['created_at'] is DateTime) {
          map['created_at'] = (map['created_at'] as DateTime).toIso8601String();
        }
        if (map['updated_at'] is DateTime) {
          map['updated_at'] = (map['updated_at'] as DateTime).toIso8601String();
        }
        return map;
      }).toList();

      return Response.ok(
        jsonEncode(websites),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('⚠️ Контроль: Ошибка при получении сайтов: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении вебсайтов'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getDecryptedWebsitePasswordById(
      Request request, String id) async {
    final websiteId = int.tryParse(id);
    final encryption = _getEncryption(request);

    if (websiteId == null || encryption == null) {
      return Response.badRequest(
        body: jsonEncode({
          'error': 'Неверный идентификатор вебсайта или нет ключа шифрования'
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('''
           SELECT encrypted_password
           FROM websites WHERE id = @id
        '''),
        parameters: {'id': websiteId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Вебсайт не найден'}),
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
      print('⚠️ Контроль: Ошибка при расшифровке пароля: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addWebsite(Request request) async {
    try {
      final encryption = _getEncryption(request);
      final userId = _getUserId(request);

      if (encryption == null || userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Нет доступа: не найден ключ или пользователь'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final data = jsonDecode(await request.readAsString());

      final websiteName = data['website_name'] as String?;
      final websiteUrl = data['website_url'] as String?;
      final nickname = data['nickname'] as String?;
      final rawPassword =
          data['raw_password'] as String?; // Основной пароль сайта
      final encryptedPassword =
          rawPassword != null && rawPassword.trim().isNotEmpty
              ? encryption.encryptText(rawPassword)
              : null;
      final emailAddress = data['website_email'] as String?;
      final rawEmailPassword = data['raw_email_password'] as String?;
      // Email-пароль (необязательный)
      final encryptedEmailPassword =
          rawEmailPassword != null && rawEmailPassword.trim().isNotEmpty
              ? encryption.encryptText(rawEmailPassword)
              : null;
      final websiteDescription = data['website_description'] as String?;
      final emailDescription = data['email_description'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;

      if ([
        websiteName,
        websiteUrl,
        nickname,
        encryptedPassword,
        accountId,
        categoryId,
        userId,
      ].any((v) => v == null || (v is String && v.trim().isEmpty))) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Отсутствуют обязательные поля'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      await connection.execute(Sql.named('''
      SELECT create_website_with_nickname_and_email(
        @accountId,
        @userId,
        @categoryId,
        @nickname,
        @encryptedPassword,
        @websiteName,
        @websiteUrl,
        @websiteDescription,
        @emailAddress,
        @emailPassword,
        @emailDescription
      )
    '''), parameters: {
        'accountId': accountId,
        'userId': userId,
        'categoryId': categoryId,
        'nickname': nickname,
        'encryptedPassword': encryptedPassword,
        'websiteName': websiteName,
        'websiteUrl': websiteUrl,
        'websiteDescription': websiteDescription,
        'emailAddress': emailAddress,
        'emailPassword': encryptedEmailPassword,
        'emailDescription': emailDescription,
      });

      return Response.ok(
        jsonEncode({'message': 'Сайт успешно добавлен'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при добавлении сайта: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при добавлении сайта'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
