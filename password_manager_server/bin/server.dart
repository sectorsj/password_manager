import 'package:dotenv/dotenv.dart' show DotEnv, load;
import 'package:password_manager_server/db/connection_to_db.dart';
import 'package:password_manager_server/router.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  final dotenv = DotEnv()..load();
  final connection = await createConnection(dotenv);
  final handler = buildHandler(connection, dotenv);

  final server = await shelf_io.serve(handler, 'localhost', 8080);
  print(
      'Сервер запущен по адресу: http://${server.address.host}:${server.port}');
}
