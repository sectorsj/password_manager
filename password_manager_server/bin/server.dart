import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:password_manager_server/db/connection_to_db.dart';
import 'package:password_manager_server/router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

Future<void> main() async {
  final DotEnv dotEnv = DotEnv();
  if (File('.env').existsSync()) {
    dotEnv.load();
    print('📄 .env загружен');
  } else {
    print('❌ .env файл не найден');
    return;
  }


  // Приводим к типу Map<String, String> вручную
  final env = <String, String>{
    ...Platform.environment,
    ...dotEnv.map
        .map((key, value) => MapEntry(key.toString(), value.toString())),
  };

  print('Переходим к подключению...');
  try {
    final connection = await createConnection(env);
    final handler = buildHandler(connection, env);

    final port = int.parse(env['PORT'] ?? '8080');
    print('🧪 Попытка запустить сервер на ${env['PORT'] ?? '8080'}');
    final server = await shelf_io.serve(handler, '0.0.0.0', port);
    print('🚀 Сервер запущен на https://${server.address.host}:${server.port}');
  } catch (e) {
    print('❌ Не удалось запустить сервер: $e');
  }
}
