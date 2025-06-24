import 'package:postgres/postgres.dart';

Future<Connection> createConnection(Map<String, String> env) async {
  try {
    final connection = await Connection.open(
      Endpoint(
        host: env['DB_HOST']!,
        port: int.parse(env['DB_PORT']!),
        database: env['DB_NAME']!,
        username: env['DB_USER']!,
        password: env['DB_PASSWORD']!,
      ),
      settings: const ConnectionSettings(sslMode: SslMode.disable),
    );

    print('✅ Подключение к базе данных установлено');
    return connection;
  } catch (e) {
    print('❌ Ошибка при подключении к базе данных: $e');
    rethrow; // Перехватываем и повторно выбрасываем ошибку
  }
}
