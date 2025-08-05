// NetworkConnectionRoutes.dart

import 'dart:convert';

import 'package:common_utility_package/encryption_utility.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class NetworkConnectionRoutes {
  final Connection connection;

  NetworkConnectionRoutes(this.connection);

  Router get router {
    final router = Router();

    router.get('/', _getNetworkConnectionsByUserId);
    router.get('/<id>/password', _getDecryptedPasswordById);
    router.post('/add', _addNetworkConnection);
    router.post('/add2', _addNetworkConnectionNew);

    return router;
  }

  EncryptionUtility? _getEncryption(Request request) {
    return request.context['encryption'] as EncryptionUtility?;
  }

  int? _getUserId(Request request) {
    return request.context['user_id'] as int?;
  }

  Future<Response> _getNetworkConnectionsByUserId(Request request) async {
    final userId = _getUserId(request);

    if (userId == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'Нет доступа: пользователь не найден'}),
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
      print('⚠️ Контроль: Ошибка при получении подключений: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при получении подключений'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getDecryptedPasswordById(Request request, String id) async {
    try {
      final connId = int.tryParse(id);
      final encryption = _getEncryption(request);

      if (connId == null || encryption == null) {
        return Response.badRequest(
          body: jsonEncode({
            'error':
                'Неверный идентификатор сет.подключения или нет ключа шифрования'
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final result = await connection.execute(Sql.named('''
              SELECT encrypted_password
              FROM network_connections
              WHERE id = @id
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
      print('⚠️ Контроль: Ошибка при расшифровке пароля: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _addNetworkConnection(Request request) async {
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

      final connectionName = data['network_connection_name'] as String?;
      final nickname = data['nickname'] as String?;
      final rawPassword = data['raw_password'] as String;
      final encryptedPassword =
          rawPassword.trim().isNotEmpty
              ? encryption.encryptText(rawPassword)
              : null;
      final emailAddress = data['network_connection_email'] as String?;
      final rawEmailPassword = data['raw_email_password'] as String?;
      final encryptedEmailPassword =
          rawEmailPassword != null && rawEmailPassword.trim().isNotEmpty
              ? encryption.encryptText(rawEmailPassword)
              : null;
      final ipv4 = data['ipv4'] as String?;
      final ipv6 = data['ipv6'] as String?;
      final description = data['network_connection_description'] as String?;
      final emailDescription = data['email_description'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;

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
        @emailEncryptedPassword,
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
        'emailEncryptedPassword': encryptedEmailPassword,
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



  Future<Response> _addNetworkConnectionNew(Request request) async {
    try {
      final encryption = _getEncryption(request);
      final userId = _getUserId(request);

      if (encryption == null || userId == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Нет доступа: отсутствует ключ или пользователь'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final data = jsonDecode(await request.readAsString());
      print('📥 Получены данные: ${jsonEncode(data)}');

      final connectionName = data['network_connection_name'] as String?;
      final nickname = data['nickname'] as String?;
      final rawPassword = data['raw_password'] as String?;
      final accountId = data['account_id'] as int?;
      final categoryId = data['category_id'] as int?;
      final ipv4 = data['ipv4'] as String?;
      final ipv6 = data['ipv6'] as String?;
      final description = data['network_connection_description'] as String?;
      final emailAddress = data['network_connection_email'] as String?;
      final emailDescription = data['email_description'] as String?;

      final rawEmailPassword = data['raw_email_password'] as String?;
      final encryptedEmailPassword = (emailAddress != null &&
              rawEmailPassword != null &&
              rawEmailPassword.trim().isNotEmpty)
          ? encryption.encryptText(rawEmailPassword)
          : null;

      final encryptedPassword = (rawPassword != null &&
              rawPassword.trim().isNotEmpty)
          ? encryption.encryptText(rawPassword)
          : null;
      
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
        SELECT create_network_connection_with_nickname_email_and_ip(
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
          @emailEncryptedPassword,
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
        'emailEncryptedPassword': encryptedEmailPassword,
        'emailDescription': emailDescription,
      });

       return Response.ok(
        jsonEncode({'message': 'Подключение успешно добавлено'}),
        headers: {'Content-Type': 'application/json'},
      );

    } catch(e, stack) {
      print('❌ Ошибка при добавлении подключения: $e\n$stack');
      return Response.internalServerError(
        body: jsonEncode({'error': 'Ошибка сервера при добавлении подключения'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}