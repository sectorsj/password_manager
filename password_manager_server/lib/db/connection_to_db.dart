import 'package:postgres/postgres.dart';

Future<Connection> createConnection(Map<String, String> env) async {
  final connection = await Connection.open(
    Endpoint(
      host: env['DB_HOST']!,
      port: int.parse(env['DB_PORT']!),
      database: env['DB_NAME'] !,
      username: env['DB_USER']!,
      password: env['DB_PASSWORD']!,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  print('✅ Подключение к базе данных установлено');
  return connection;
}
