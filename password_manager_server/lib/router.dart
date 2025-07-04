import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:common_utility_package/base_auth_middleware.dart';

import 'api/login_route.dart';
import 'api/register_route.dart';
import 'api/account_routes.dart';
import 'api/user_routes.dart';
import 'api/email_routes.dart';
import 'api/website_routes.dart';
import 'api/network_connection_routes.dart';

Handler buildHandler(Connection connection, Map<String, String> env) {
  final router = Router()
    ..mount('/login', LoginRoute(connection).router)
    ..mount('/register', RegisterRoute(connection).router)
    ..mount('/accounts', AccountRoutes(connection).router)
    ..mount('/users', UserRoutes(connection).router)
    ..mount(
      '/emails',
      Pipeline()
          .addMiddleware(baseAuthMiddleware()) // 🔒
          .addHandler(EmailRoutes(connection).router),
    )
    ..mount(
      '/websites',
      Pipeline()
          .addMiddleware(baseAuthMiddleware()) // 🔒
          .addHandler(WebsiteRoutes(connection).router),
    )
    ..mount(
        '/network-connections',
        Pipeline()
            .addMiddleware(baseAuthMiddleware()) // 🔒
            .addHandler(NetworkConnectionRoutes(connection).router));

  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      }))
      .addHandler(router);
}
