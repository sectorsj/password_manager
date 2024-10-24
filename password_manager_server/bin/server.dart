import 'dart:convert';

import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:hashing_utility_package/hashing_utility.dart'; // Подключение вашего класса HashingUtility

final dotenv = DotEnv();

void main() async {

  dotenv.load(['.env']);

  // Подключение к базе данных
  final connection = await createConnection();

  // Создаем маршруты API
  final router = Router();

  // API для регистрации нового пользователя (с JSON-обработкой)
  router.post('/register', (Request request) async {
    var data = await request.readAsString();
    var body = jsonDecode(data);  // Используем jsonDecode для работы с JSON

    // API для получения данных из запроса
    String username = body['username']!;
    String email = body['email']!;
    String passwordHash = body['password']!;
    String salt = body['salt']!;

    //  API для добавления нового аккаунта в базу данных
    try {
      await connection.query(
        'INSERT INTO accounts (account_login, email, password_hash, salt) VALUES (@username, @email, @password, @salt)',
        substitutionValues: {
          'username': username,
          'email': email,
          'password': passwordHash,
          'salt': salt,
        },
      );
      print('Пользователь зарегистрирован: $username');
      return Response.ok('Пользователь зарегистрирован успешно');
    } catch (e) {
      print('Ошибка при регистрации пользователя: $e');
      return Response.internalServerError(body: 'Ошибка при регистрации пользователя');
    }
  });

  // API для входа пользователя (с JSON-обработкой)
  router.post('/login', (Request request) async {
    var data = await request.readAsString();
    var body = jsonDecode(data);

    String username = body['username']!;
    String password = body['password']!;

    try {
      var result = await connection.query(
        'SELECT password_hash, salt FROM accounts WHERE account_login = @username',
        substitutionValues: {'username': username},
      );

      if (result.isNotEmpty) {
        String storedHash = result.first.toColumnMap()['password_hash'];
        String storedSalt = result.first.toColumnMap()['salt'];

        bool passwordMatch = await HashingUtility.verifyPassword(password, storedSalt, storedHash);

        if (passwordMatch) {
          return Response.ok(jsonEncode({'message': 'Авторизация прошла успешно'}),
              headers: {'Content-Type': 'application/json'});
        } else {
          return Response.forbidden(jsonEncode({'ошибка!': 'Неверное имя пользователя или пароль'}),
              headers: {'Content-Type': 'application/json'});
        }
      } else {
        return Response.forbidden(jsonEncode({'ошибка!': 'Неверное имя пользователя или пароль'}),
            headers: {'Content-Type': 'application/json'});
      }
    } catch (e) {
      return Response.internalServerError(body: 'Error logging in');
    }
  });


  // API для получения всех email для аккаунта
  router.get('/emails/<accountId>', (Request request, String accountId) async {
    List<List<dynamic>> results = await connection.query(
      'SELECT * FROM emails WHERE account_id = @accountId',
      substitutionValues: {'accountId': int.parse(accountId)},
    );
    return Response.ok(results.toString());
  });

  // API для добавления email
  router.post('/emails/add', (Request request) async {
    var data = await request.readAsString();
    var body = Uri.splitQueryString(data);

    await connection.query(
      'INSERT INTO emails (email_address, password_hash, salt, email_description, account_id, category_id) VALUES (@address, @password, @salt, @description, @accountId, @categoryId)',
      substitutionValues: {
        'address': body['email_address'],
        'password': body['password_hash'],
        'salt': body['salt'],
        'description': body['email_description'],
        'accountId': int.parse(body['account_id']!),
        'categoryId': int.parse(body['category_id']!),
      },
    );
    return Response.ok('Email added successfully');
  });

  // API для получения всех сетевых подключений
  router.get('/network-connections/<accountId>', (Request request, String accountId) async {
    List<List<dynamic>> results = await connection.query(
      'SELECT * FROM network_connections WHERE account_id = @accountId',
      substitutionValues: {'accountId': int.parse(accountId)},
    );
    return Response.ok(results.toString());
  });

  // API для добавления сетевого подключения
  router.post('/network-connections/add', (Request request) async {
    var data = await request.readAsString();
    var body = Uri.splitQueryString(data);

    await connection.query(
      'INSERT INTO network_connections (connection_name, ipv4, ipv6, network_login, password_hash, salt, account_id) VALUES (@name, @ipv4, @ipv6, @login, @password, @salt, @accountId)',
      substitutionValues: {
        'name': body['connection_name'],
        'ipv4': body['ipv4'],
        'ipv6': body['ipv6'],
        'login': body['network_login'],
        'password': body['password_hash'],
        'salt': body['salt'],
        'accountId': int.parse(body['account_id']!),
      },
    );
    return Response.ok('Network connection added successfully');
  });

  // API для получения всех сайтов для аккаунта
  router.get('/websites/<accountId>', (Request request, String accountId) async {
    List<List<dynamic>> results = await connection.query(
      'SELECT * FROM websites WHERE account_id = @accountId',
      substitutionValues: {'accountId': int.parse(accountId)},
    );
    return Response.ok(results.toString());
  });

  // API для добавления сайта
  router.post('/websites/add', (Request request) async {
    var data = await request.readAsString();
    var body = Uri.splitQueryString(data);

    await connection.query(
      'INSERT INTO websites (website_name, url, website_login, password_hash, salt, website_description, account_id) VALUES (@name, @url, @login, @password, @salt, @description, @accountId)',
      substitutionValues: {
        'name': body['website_name'],
        'url': body['url'],
        'login': body['website_login'],
        'password': body['password_hash'],
        'salt': body['salt'],
        'description': body['website_description'],
        'accountId': int.parse(body['account_id']!),
      },
    );
    return Response.ok('Website added successfully');
  });

  // Настройка CORS и логирования
  final handler = const Pipeline()
      .addMiddleware(logRequests())  // Логирование запросов
      .addMiddleware(corsHeaders(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      },
  ))
      .addHandler(router);

  // Запуск сервера
  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print('Сервер запушен по адресу: http://${server.address.host}:${server.port}');
}


// Настройка подключения к базе данных Postgres
Future<PostgreSQLConnection> createConnection() async {
  final connection = PostgreSQLConnection(
    dotenv['DB_HOST']!,  // Чтение из переменных окружения
    int.parse(dotenv['DB_PORT']!),
    dotenv['DB_NAME']!,
    username: dotenv['DB_USER']!,
    password: dotenv['DB_PASSWORD']!,
  );

  await connection.open();
  print('Подключение к базе данных установлено');
  return connection;
}