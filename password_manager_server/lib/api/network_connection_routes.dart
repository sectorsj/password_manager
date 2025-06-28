// NetworkConnectionRoutes.dart

import 'dart:convert';

import 'package:common_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class NetworkConnectionRoutes {
  final Connection connection;
  final EncryptionUtility encryption;

  NetworkConnectionRoutes(this.connection, Map<String, String> env)
      : encryption = EncryptionUtility.fromEnv(env);

  Router get router {
    final router = Router();

    router.get('/', _getNetworkConnectionsByUserId);
    router.get('/<id>/password', _getDecryptedPasswordById);
    router.post('/add', _addNetworkConnection);

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
      final result = await connection.execute(Sql.named('''
        SELECT nc.id,
               nc.network_connection_name,
               nc.encrypted_password,
               nc.network_connection_description,
               nc.ipv4,
               nc.ipv6,
               nc.account_id,
               nc.category_id,
               nc.user_id,
               nc.nickname_id,
               n.nickname,
               nc.email_id,
               e.email_address AS network_connection_email,
               nc.created_at,
               nc.updated_at
        FROM network_connections nc
        LEFT JOIN nicknames n ON nc.nickname_id = n.id
        LEFT JOIN emails e ON nc.email_id = e.id
        WHERE nc.user_id = @userId
      '''), parameters: {'userId': userId});

      final connections = result.map((row) {
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
        jsonEncode(connections),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при получении подключений: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении подключений'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getDecryptedPasswordById(Request request, String id) async {
    final connId = int.tryParse(id);

    if (connId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Неверный connection ID'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final result = await connection.execute(Sql.named('''
        SELECT encrypted_password FROM network_connections WHERE id = @id
      '''), parameters: {'id': connId});

      if (result.isEmpty) {
        return Response.notFound(
          jsonEncode({'error': 'Соединение не найдено'}),
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
      print('Ошибка при расшифровке пароля: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addNetworkConnection(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body);

      // Основной пароль подключения (обязательный)
      final rawPassword = data['password'] as String?;
      final encryptedPassword =
          rawPassword != null ? encryption.encryptText(rawPassword) : null;

      // Email-пароль (необязательный)
      final rawEmailPassword = data['email_password'] as String?;
      final encryptedEmailPassword = rawEmailPassword != null
          ? encryption.encryptText(rawEmailPassword)
          : '';

      final connectionName = data['network_connection_name'] as String?;
      final ipv4 = data['ipv4'] as String?;
      final ipv6 = data['ipv6'] as String?;
      final nickname = data['nickname'] as String?;
      final emailAddress = data['email_address'] as String?;
      final description = data['network_connection_description'] as String?;
      final emailDescription = data['email_description'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;
      final userId = data['user_id'] as int?;

      if ([
        encryptedPassword,
        connectionName,
        nickname,
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
      SELECT create_network_connection_with_nickname_and_email(
        @accountId,
        @userId,
        @categoryId,
        @nickname,
        @encryptedPassword,
        @connectionName,
        @ipv4,
        @ipv6,
        @description,
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
        'connectionName': connectionName,
        'ipv4': ipv4,
        'ipv6': ipv6,
        'description': description,
        'emailAddress': emailAddress,
        'emailPassword': encryptedEmailPassword,
        'emailDescription': emailDescription,
      });

      return Response.ok(
        jsonEncode({'message': 'Подключение успешно добавлено'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stack) {
      print('Ошибка при добавлении подключения: $e\n$stack');
      return Response.internalServerError(
        body:
            jsonEncode({'error': 'Ошибка сервера при добавлении подключения'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
