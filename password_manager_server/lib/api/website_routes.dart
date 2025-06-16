import 'dart:convert';

import 'package:hashing_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class WebsiteRoutes {
  final Connection connection;
  final EncryptionUtility encryption;
  final Map<String, String> env;

  WebsiteRoutes(this.connection, this.env)
      : encryption = EncryptionUtility(env);

  Router get router {
    final router = Router();

    router.get('/', _getWebsiteByUserId);
    router.get('/<id>/password', _getDecryptedWebsitePasswordById);
    router.post('/add', _addWebsite);

    return router;
  }

  Future<Response> _getWebsiteByUserId(Request request) async {
    final userIdStr = request.url.queryParameters['user_id'];
    final userId = int.tryParse(userIdStr ?? '');

    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Отсутствует или неверный user id'}),
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
      print('Ошибка при получении сайтов: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении сайтов'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getDecryptedWebsitePasswordById(
      Request request, String id) async {
    final websiteId = int.tryParse(id);

    if (websiteId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Неверный website ID'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(
        Sql.named('SELECT encrypted_password FROM websites WHERE id = @id'),
        parameters: {'id': websiteId},
      );

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Website не найден'}),
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
        body: jsonEncode({'error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addWebsite(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      final encryptedPassword = data['encrypted_password'] as String?;
      final websiteName = data['website_name'] as String?;
      final websiteUrl = data['website_url'] as String?;
      final nickname = data['nickname'] as String?;
      final websiteEmail =
          data['website_email'] as String?; // используется как email_address
      final websiteDescription = data['website_description'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;
      final userId = data['user_id'] as int?;
      final emailEncryptedPassword =
          data['email_encrypted_password'] as String? ?? '';
      final emailDescription = data['email_description'] as String?;

      if ([
        encryptedPassword,
        websiteName,
        websiteUrl,
        nickname,
        accountId,
        categoryId,
        userId,
      ].any((e) => e == null || (e is String && e.trim().isEmpty))) {
        return Response.badRequest(
          body:
              jsonEncode({'error': 'Некоторые обязательные поля отсутствуют'}),
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
        @email,
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
        'email': websiteEmail,
        'emailPassword': emailEncryptedPassword,
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
