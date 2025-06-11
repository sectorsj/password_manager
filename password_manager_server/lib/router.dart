import 'package:dotenv/dotenv.dart';
import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'api/login_route.dart';
import 'api/register_route.dart';
import 'api/account_routes.dart';
import 'api/user_routes.dart';
import 'api/email_routes.dart';
import 'api/website_routes.dart';
import 'api/network_connection_routes.dart';

Handler buildHandler(Connection connection, DotEnv env) {
  final router = Router()
    ..mount('/login', LoginRoute(connection, env).router)
    ..mount('/register', RegisterRoute(connection, env).router)
    ..mount('/accounts', AccountRoutes(connection).router)
    ..mount('/users', UserRoutes(connection).router)
    ..mount('/emails', EmailRoutes(connection, env).router)
    ..mount('/websites', WebsiteRoutes(connection, env).router)
    ..mount('/network-connections',
        NetworkConnectionRoutes(connection, env).router);

  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      }))
      .addHandler(router);
}
