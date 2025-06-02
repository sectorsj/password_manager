import 'package:postgres/postgres.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'api/auth_routes.dart';
import 'api/account_routes.dart';
import 'api/user_routes.dart';
import 'api/email_routes.dart';
import 'api/website_routes.dart';
import 'api/network_connection_routes.dart';

Handler buildHandler(Connection connection) {
  final router = Router()
    ..mount('/auth', AuthRoutes(connection).router)
    ..mount('/accounts', AccountRoutes(connection).router)
    ..mount('/users', UserRoutes(connection).router)
    ..mount('/emails', EmailRoutes(connection).router)
    ..mount('/websites', WebsiteRoutes(connection).router)
    ..mount('/network-connections', NetworkConnectionRoutes(connection).router);

  return Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
      }))
      .addHandler(router);
}
